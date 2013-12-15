timeTracker.factory("option", () ->

  OPTIONS = "OPTIONS"
  NULLFUNC = () ->

  return {

    ###
     get all option data.
    ###
    getOptions: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.get OPTIONS, (item) ->
        if chrome.runtime.lastError? or not item[OPTIONS]?
          callback null
        else
          callback item[OPTIONS]


    ###
     set all option data.
    ###
    setOptions: (options, callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.set OPTIONS: options, () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true


    ###
     clear all data.
    ###
    clearAllData: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.local.clear()
      chrome.storage.sync.clear () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
