timeTracker.factory("Option", ($q, Chrome, Const, Log) ->

  class Option

    # class variables
    @DEFAULT_OPTION:
      reportUsage: true
      isProjectStarEnable: true
      removeClosedTicket: true
      itemsPerPage: 20
    @_options: @DEFAULT_OPTION
    @_events: []

    ###
     constructor.
    ###
    constructor: () ->
      for k, v of Option.DEFAULT_OPTION
        @addOptionKey(k)

    ###
     get all option data.
    ###
    getOptions: () ->
      return Option._options

    ###
     add a option's key name.
     @param {String} key - option's key.
    ###
    addOptionKey: (key) ->
      value = Option._options[key]
      Object.defineProperty Option._options, key,
        get: -> value
        set: (n) ->
          value = n
          obj = {}
          obj[key] = n
          Option._events.map (e) -> e(obj)

    ###
     add a event listner for change value.
    ###
    onChanged: (f) -> Option._events.push f

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
    syncOptions: () ->
      deferred = $q.defer()

      saveData = {}
      saveData[Const.OPTIONS] = Option._options
      Chrome.storage.sync.set saveData, () ->
        if Chrome.runtime.lastError?
          deferred.reject(false)
        else
          Log.info "option synced."
          Log.debug saveData
          deferred.resolve(true)

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


  return new Option()

)
