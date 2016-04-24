timeTracker.factory("Option", ($q, Chrome, Const, Log) ->

  class Option

    # class variables
    @DEFAULT_OPTION:
      reportUsage: true
      isProjectStarEnable: true
      removeClosedTicket: true
      hideNonTicketProject: true
      itemsPerPage: 20
      stepTime: 15                    # minutes
      pomodoroTime: 25                # minutes
      isCollapseIssues: false         # issue section collapse
      isCollapseAccounts: false       # accounts section collapse
      isCollapseOptions: false        # options section collapse
      isCollapsePlugins: false        # plugins section collapse
      plugins: [                      # only app internal path are allowed by CSP.
        "/scripts/plugins/notification.js"
      ]
    @_options: @DEFAULT_OPTION
    @_optionProxy: null
    @_events: []
    @_eventsWithKey: {}

    ###
     constructor.
    ###
    constructor: () ->
      Option._optionProxy = new Proxy(Option._options, @_onChanged)

    ###
     get all option data.
    ###
    getOptions: () ->
      return Option._optionProxy

    ###
     add a event listner for change value.
    ###
    onChanged: (key, f) ->
      if Object.isString(key)
        Option._eventsWithKey[key] = Option._eventsWithKey[key] or []
        Option._eventsWithKey[key].push f
      else
        Option._events.push key # this is function

    ###
     load all option data.
    ###
    loadOptions: () ->
      deferred = $q.defer()

      Chrome.storage.sync.get Const.OPTIONS, (item) ->
        if Chrome.runtime.lastError?
          deferred.reject()
        else
          Log.info "option loaded."
          Log.debug item
          options = Object.merge(Option.DEFAULT_OPTION, item[Const.OPTIONS])
          for k, v of options then Option._options[k] = v
          deferred.resolve(Option._options)

      return deferred.promise

    ###
     sync all option data.
    ###
    syncOptions: (propName) ->
      deferred = $q.defer()

      saveData = {}
      saveData[Const.OPTIONS] = Option._options
      Chrome.storage.sync.set saveData, () ->
        if Chrome.runtime.lastError?
          deferred.reject(false)
        else
          Log.info "option synced."
          Log.debug saveData
          deferred.resolve(propName)

      return deferred.promise

    ###
     clear all option data.
    ###
    clearAllOptions: (callback) ->
      deferred = $q.defer()

      callback = callback or Const.NULLFUNC
      Chrome.storage.local.clear()
      Chrome.storage.sync.clear () ->
        if Chrome.runtime.lastError?
          deferred.reject(false)
        else
          deferred.resolve(true)

      return deferred.promise

    ###*
    # on option changed lister.
    ###
    _onChanged: {
      # @param {Object} options: Target object.
      # @param {String} propName: Property name which will be change.
      # @param {Object} value: New value.
      set: (options, propName, value) ->
        Option._events.map (f) -> f(propName, value, options[propName])
        Option._eventsWithKey[propName]?.map (f) -> f(value, options[propName])
        options[propName] = value
        return true
    }

  return new Option()

)
