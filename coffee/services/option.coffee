timeTracker.factory("Option", (Chrome) ->

  OPTIONS = "OPTIONS"
  NULLFUNC = () ->

  return {

    ###
     get all option data.
    ###
    getOptions: (callback) ->
      callback = callback or NULLFUNC
      Chrome.storage.sync.get OPTIONS, (item) ->
        if Chrome.runtime.lastError? or not item[OPTIONS]?
          callback null
        else
          callback item[OPTIONS]


    ###
     set all option data.
    ###
    setOptions: (options, callback) ->
      callback = callback or NULLFUNC
      Chrome.storage.sync.set OPTIONS: options, () ->
        if Chrome.runtime.lastError?
          callback false
        else
          callback true


    ###
     clear all data.
    ###
    clearAllData: (callback) ->
      callback = callback or NULLFUNC
      Chrome.storage.local.clear()
      Chrome.storage.sync.clear () ->
        if Chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
