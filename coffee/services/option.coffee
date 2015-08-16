timeTracker.factory("Option", ($q, Chrome, Const, Log) ->

  DEFAULT_OPTION = { reportUsage: true , itemsPerPage: 20}

  _options = DEFAULT_OPTION

  return {

    ###
     get all option data.
    ###
    getOptions: () ->
      return _options


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
          _options = item[Const.OPTIONS] or DEFAULT_OPTION
          deferred.resolve(_options)

      return deferred.promise


    ###
     set all option data.
    ###
    setOptions: (options, callback) ->
      callback = callback or Const.NULLFUNC
      _options = options
      saveData = {}
      saveData[Const.OPTIONS] = options
      Chrome.storage.sync.set saveData, () ->
        if Chrome.runtime.lastError?
          callback false
        else
          callback true


    ###
     clear all data.
    ###
    clearAllData: (callback) ->
      callback = callback or Const.NULLFUNC
      Chrome.storage.local.clear()
      Chrome.storage.sync.clear () ->
        if Chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
