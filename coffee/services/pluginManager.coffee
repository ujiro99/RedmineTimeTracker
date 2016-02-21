timeTracker.factory "PluginManager", ($window, EventDispatcher, Analytics, Log) ->

  ###
   Management plugins.
  ###
  class PluginManager extends EventDispatcher

    UPDATED_PLUGIN: "update_plugin"
    LOAD_FAILED:    "load_failed"
    EXEC_FAILED:    "exec_failed"

    # Interface for plugin which access to this app.
    RTT: {}

    # If events fired, plugin's event handler will be called.
    _events: [
      "sendTimeEntry"
      "sendedTimeEntry"
    ]
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


    initRTT: () =>
      pluginInterface = {
        addPlugin:    @addPlugin
        removePlugin: @removePlugin
      }
      $window.RTT = pluginInterface


    bindEvents: () =>
      @_events.map (event) =>
        @addEventListener event, @exec
        key = event.underscore().toUpperCase()
        @events[key] = event


    addPlugin: (name, pluginObj) =>
      @_plugins[name] = pluginObj
      @fireEvent(@UPDATED_PLUGIN)


    removePlugin: (name) =>
      delete @_plugins[name]
      @fireEvent(@UPDATED_PLUGIN)


    listPlugins: () =>
      return @_plugins


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


    notify: (event, args) =>
      @fireEvent(event, null, event, args)


    exec: (event, params...) =>
      handlerName = 'on' + event.camelize()
      @Log.debug("start " + handlerName)
      for name, plugin of @_plugins
        try
          @Log.info("  exec " + name)
          handler = plugin[handlerName] or ()->
          handler.apply(plugin, [@RTT, params...])
        catch error
          @Log.error(error)
          @fireEvent(@EXEC_FAILED, null, name)
        finally
          @Log.info("  execed " + name)
      @Log.debug("finish " + handlerName)


  return new PluginManager($window, Analytics, Log)
