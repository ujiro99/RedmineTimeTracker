timeTracker.factory("$account", () ->

  ACCOUNTS = "ACCOUNTS"
  HOST     = "HOST"
  API_KEY  = "API_KEY"
  USER_ID  = "USER_ID"
  NULLFUNC = () ->

  return {

    ###
     get all account data using chrome sync
    ###
    getAccounts: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.get ACCOUNTS, (item) ->
        if chrome.runtime.lastError? or not item[ACCOUNTS]?
          callback null
        else
          callback item[ACCOUNTS]


    ###
     add a account data using chrome sync
    ###
    addAccount: (account, callback) ->
      if not account? then return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        newArry = []
        for a in accounts when a.host isnt account.host
          newArry.push a
        accounts = newArry
        accounts.push account
        chrome.storage.sync.set ACCOUNTS: accounts, () ->
          if chrome.runtime.lastError?
            callback false
          else
            callback true


    ###
      clear all account data
    ###
    clearAccount: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.clear () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
