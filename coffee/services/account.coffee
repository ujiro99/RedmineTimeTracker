timeTracker.factory("$account", () ->

  ACCOUNTS = "ACCOUNTS"
  PHRASE = "hello, redmine time traker."
  NULLFUNC = () ->


  ###
   decrypt the account data, only to sync on chrome.
  ###
  _decrypt = () ->
    @apiKey = CryptoJS.AES.decrypt(@apiKey, PHRASE).toString(CryptoJS.enc.Utf8)
    @id     = CryptoJS.AES.decrypt(@id, PHRASE).toString(CryptoJS.enc.Utf8)
    @pass   = CryptoJS.AES.decrypt(@pass, PHRASE).toString(CryptoJS.enc.Utf8)


  ###
   encrypt the account data, only to sync on chrome.
  ###
  _encrypt = () ->
    @apiKey = CryptoJS.AES.encrypt(@apiKey, PHRASE)
    @id     = CryptoJS.AES.encrypt(@id, PHRASE)
    @pass   = CryptoJS.AES.encrypt(@pass, PHRASE)


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
          for a in item[ACCOUNTS]
            _decrypt.apply(a)
          callback item[ACCOUNTS]


    ###
     add a account data using chrome sync
    ###
    addAccount: (account, callback) ->
      if not account? then callback false; return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        newArry = []
        # merge accounts.
        for a in accounts when a.url isnt account.url
          newArry.push a
        accounts = newArry
        _encrypt.apply(account)
        accounts.push account
        chrome.storage.sync.set ACCOUNTS: accounts, () ->
          if chrome.runtime.lastError?
            callback false
          else
            callback true


    ###
     remove by url.
    ###
    removeAccount: (url, callback) ->
      if not url? then callback false; return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        # select other url account
        accounts = for a in accounts when a.url isnt url
          _encrypt.apply(a); a
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
      chrome.storage.local.clear()
      chrome.storage.sync.clear () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)
