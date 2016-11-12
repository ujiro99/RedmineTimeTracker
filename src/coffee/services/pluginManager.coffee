timeTracker.factory "PluginManager", ($window, EventDispatcher, Analytics, Platform, Log) ->

  ###
   Management plugins.
  ###
  class PluginManager extends EventDispatcher

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
     @class PluginManager
     @constructor
    ###
    constructor: (@window, @Analytics, @Log) ->
      @initRTT()
      @bindEvents()


    ###*
     Initialize RTT grobal/internal object.
    ###
    initRTT: () =>
      pluginInterface = {
        registerPlugin:   @registerPlugin
        unregisterPlugin: @unregisterPlugin
      }
      $window.RTT = pluginInterface #grobal
      @RTT = {} #internal


    ###*
     Bind events and generate eventName.
    ###
    bindEvents: () =>
      @_events.map (event) =>
        @addEventListener event, @exec
        key = event.underscore().toUpperCase()
        @events[key] = event


    ###*
     Register new plugins. This method will be called by plugin first.
     @param name        {String} Plugin name, must be unique.
     @param pluginClass {Object} Plugin class. Plugin instance is created from this class, and it has event handlers.
    ###
    registerPlugin: (name, pluginClass) =>
      @_plugins[name] = new pluginClass(Platform)
      @fireEvent(@UPDATED_PLUGIN)


    ###*
     Unregister plugins. This method will be called by plugin.
     @param name {String} Plugin name.
    ###
    unregisterPlugin: (name) =>
      delete @_plugins[name]
      @fireEvent(@UPDATED_PLUGIN)


    ###*
     List up registered plugins.
     @return plugins       {Object} Hashmap of plugins.
     @return plugins.key   {String} Plugin name.
     @return plugins.value {Object} Plugin object.
    ###
    listPlugins: () =>
      return @_plugins


    ###*
     Load plugin from url.
     Currently, only in app file is allowed by Chrome app CSP.
     @param url {String}   Url of plugin's source code.
     @param cb  {Function} Load completed callback.
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
     @param event {String} Event name.
     @param args  {Any}    Arguments which passed into plugin's event handler.
    ###
    notify: (event, args...) =>
      @fireEvent(event, null, event, args...)


    ###*
     Execute plugin's event handlers.
     Handler method which prefixed "on" to eventName is called.
     @param event {String} Event name.
     @param args  {Any}    Arguments which passed into plugin's event handler.
    ###
    exec: (event, args...) =>
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
