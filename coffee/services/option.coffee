timeTracker.factory("Option", (Chrome, Const) ->

  DEFAULT_OPTION = { reportUsage: true , showNavigation: true }

  _options = null

  return {

    ###
     get all option data.
    ###
    getOptions: () ->
      return _options


    ###
     load all option data.
    ###
    loadOptions: (callback) ->
      callback = callback or Const.NULLFUNC
      if _options isnt null then callback _options; return

      Chrome.storage.sync.get Const.OPTIONS, (item) ->
        if Chrome.runtime.lastError?
          callback null
        else
          _options = item[Const.OPTIONS] or DEFAULT_OPTION
          callback _options


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
