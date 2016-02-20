timeTracker.factory "PluginManager", ($window, EventDispatcher, Analytics, Log, Const) ->

  ###
   Management plugins.
  ###
  class PluginManager extends EventDispatcher

    # Interface for plugin access to application.
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
    constructor: (@window, @Analytics, @Log, @Const) ->
      @initRTT()
      @bindEvents()


    initRTT: () =>
      pluginInterface = {
        addPlugin:    @addPlugin
        removePlugin: @removePlugin
      }
      $window.RTT = pluginInterface


    addPlugin: (name, plugin) =>
      @_plugins[name] = plugin


    removePlugin: (name) =>
      delete @_plugins[name]


    bindEvents: () =>
      @_events.map (event) =>
        @addEventListener event, @exec
        key = event.underscore().toUpperCase()
        @events[key] = event


    notify: (event, args) =>
      @fireEvent(event, null, event, args)


    exec: (event, params...) =>
      handlerName = 'on' + event.camelize()
      @Log.debug("start " + handlerName)
      for name, plugin of @plugins
        try
          @Log.debug("  exec " + name)
          handler = plugin[handlerName] or @Const.NULLFUNC
          args = [@RTT, params...]
          handler.apply(plugin, arg)
        catch error
          throw new PluginError(name, error)
        finally
          @Log.debug("  execed " + name)
      @Log.debug("finish " + handlerName)


  class PluginError extends Error

    constructor: (@plugin, @message) ->

    toString: () =>
      return "PluginError: " + @plugin + "\treason: " + @message


  return new PluginManager($window, Analytics, Log)
