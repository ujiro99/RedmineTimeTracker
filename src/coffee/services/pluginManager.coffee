timeTracker.factory "PluginManager", ($window, EventDispatcher, Analytics, Platform, Log) ->

  ###*
   Service for management plugins.
   @class PluginManager
  ###
  class PluginManager extends EventDispatcher

    INITIALIZED:    "rtt_initialized"
    UPDATED_PLUGIN: "update_plugin"
    LOAD_FAILED:    "load_failed"
    EXEC_FAILED:    "exec_failed"


    # Interface for plugin which access to this app.
    RTT: null


    # If events fired, plugin's event handler will be called.
    _events: [
      "sendTimeEntry"
      "sendedTimeEntry"
    ]
    # Event name for accessed by other module.
    events: { ### generate automatically ### }


    # Registered plugins
    _plugins: {}


    ###*
     Constructor.
     @constructor
    ###
    constructor: (@window, @Analytics, @Log) ->
      @_initRTT()
      @_bindEvents()


    ###*
     Register new plugins. This method will be called by plugin first.
     @param {String} name - Plugin name, must be unique.
     @param {Object} pluginClass - Plugin class. Plugin instance is created from this class, and it has event handlers.
    ###
    registerPlugin: (name, pluginClass) =>
      @_plugins[name] = new pluginClass(Platform)
      @fireEvent(@UPDATED_PLUGIN)
      @Log.debug("Registered: " + name)


    ###*
     Unregister plugins. This method will be called by plugin.
     @param {String} name - Plugin name.
    ###
    unregisterPlugin: (name) =>
      delete @_plugins[name]
      @fireEvent(@UPDATED_PLUGIN)
      @Log.debug("Unregistered: " + name)


    ###*
     List up registered plugins.
     @return {Object} plugins - Hashmap of plugins.
     @return {String} plugins.key - Plugin name.
     @return {Object} plugins.value - Plugin object.
    ###
    listPlugins: () =>
      return @_plugins


    ###*
     Load plugin from url.
     Currently, only in app file is allowed by Chrome app CSP.
     @param {String} url - Url of plugin's source code.
     @param {Function} cb - Load completed callback.
    ###
    loadPluginUrl: (url, cb) =>
      script = document.createElement('script')
      script.setAttribute('src', url)
      script.setAttribute('type', 'text/javascript')
      loaded = false
      loadedCallback = () ->
        return if loaded
        loaded = true
        script.onload = null
        script.onreadystatechange = null
        cb and cb(url)
      script.onload = loadedCallback
      script.onreadystatechange = loadedCallback
      document.getElementsByTagName("head")[0].appendChild(script)


    ###*
     Notify event to plugins.
     @param {String} event - Event name.
     @param {Any} args - Arguments which passed into plugin's event handler.
    ###
    notify: (event, args...) =>
      @fireEvent(event, null, event, args...)


    ###*
     Initialize RTT global/internal object.
    ###
    _initRTT: () =>
      pluginInterface = {
        registerPlugin:   @registerPlugin
        unregisterPlugin: @unregisterPlugin
        listPlugins: @listPlugins
      }
      $window.RTT = pluginInterface #grobal
      @RTT = {} #internal
      event = new Event(@INITIALIZED)
      $window.dispatchEvent(event)
      @Log.debug("RTT initialized.")


    ###*
     Bind events and generate eventName.
    ###
    _bindEvents: () =>
      @_events.map (event) =>
        @addEventListener event, @_exec
        key = event.underscore().toUpperCase()
        @events[key] = event


    ###*
     Execute plugin's event handlers.
     Handler method which prefixed "on" to eventName is called.
     @param {String} event - Event name.
     @param {Any} args - Arguments which passed into plugin's event handler.
    ###
    _exec: (event, args...) =>
      handlerName = 'on' + event.camelize()
      @Log.debug("start " + handlerName)
      for name, plugin of @_plugins
        try
          @Log.info("  exec " + name)
          handler = plugin[handlerName] or ()->
          handler.apply(plugin, [@RTT, args...])
        catch error
          @Log.error(error)
          @fireEvent(@EXEC_FAILED, null, name)
        finally
          @Log.info("  execed " + name)
      @Log.debug("finish " + handlerName)


  return new PluginManager($window, Analytics, Log)
