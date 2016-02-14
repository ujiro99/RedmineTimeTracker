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
    @_options: @DEFAULT_OPTION
    @_events: []
    @_eventsWithKey: {}

    ###
     constructor.
    ###
    constructor: () ->
      Object.observe(Option._options, _onChanged)

    ###
     get all option data.
    ###
    getOptions: () ->
      return Option._options

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
    syncOptions: (change) ->
      deferred = $q.defer()

      saveData = {}
      saveData[Const.OPTIONS] = Option._options
      Chrome.storage.sync.set saveData, () ->
        if Chrome.runtime.lastError?
          deferred.reject(false)
        else
          Log.info "option synced."
          Log.debug saveData
          deferred.resolve(change)

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
    # on changed lister.
    # @param {Array} changes - parameter of changes.
    # @param {String} changes[n].name: The name of the property which was changed.
    # @param {Object} changes[n].object: The changed object after the change was made.
    # @param {String} changes[n].type: A string indicating the type of change taking place. One of "add", "update", or "delete".
    # @param {Object} changes[n].oldValue: Only for "update" and "delete" types. The value before the change.
    ###
    _onChanged = (changes) ->
      changes.map (e) ->
        Option._events.map (f) -> f(e)
        Option._eventsWithKey[e.name]?.map (f) ->
          f(e.object[e.name], e.oldValue[e.name])

  return new Option()

)
