timeTracker.factory("$account", () ->

  ACCOUNTS = "ACCOUNTS"
  HOST     = "HOST"
  API_KEY  = "API_KEY"
  USER_ID  = "USER_ID"
  NULLFUNC = () ->

  return {

    ###
     get all account data using chrome local
    ###
    getAccounts: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.local.get ACCOUNTS, (item) ->
        if chrome.runtime.lastError? or not item[ACCOUNTS]?
          callback null
        else
          callback item[ACCOUNTS]


    ###
     add a account data using chrome local
    ###
    addAccount: (account, callback) ->
      if not account? then return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        newArry = []
        # merge accounts.
        for a in accounts when a.host isnt account.host
          newArry.push a
        accounts = newArry
        accounts.push account
        chrome.storage.local.set ACCOUNTS: accounts, () ->
          if chrome.runtime.lastError?
            callback false
          else
            callback true


    ###
      clear all account data
    ###
    clearAccount: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.local.clear () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
