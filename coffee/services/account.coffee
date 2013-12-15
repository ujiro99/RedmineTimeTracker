timeTracker.factory("$account", ($rootScope, analytics) ->

  ACCOUNTS = "ACCOUNTS"
  PHRASE = "hello, redmine time traker."
  NULLFUNC = () ->

  ###
   JSON formatter for cipherParams.
  ###
  _Json =
    stringify: (cipherParams) ->
      jsonObj = ct: cipherParams.ciphertext.toString(CryptoJS.enc.Base64)
      if cipherParams.iv then jsonObj.iv = cipherParams.iv.toString()
      if cipherParams.salt then jsonObj.s = cipherParams.salt.toString()
      return JSON.stringify(jsonObj)

    parse: (jsonStr) ->
      jsonObj = JSON.parse(jsonStr)
      cipherParams = CryptoJS.lib.CipherParams.create {
          ciphertext: CryptoJS.enc.Base64.parse(jsonObj.ct)
      }
      if jsonObj.iv then cipherParams.iv = CryptoJS.enc.Hex.parse(jsonObj.iv)
      if jsonObj.s then cipherParams.salt = CryptoJS.enc.Hex.parse(jsonObj.s)
      return cipherParams


  ###
   decrypt object. this is used for compatibility.
  ###
  _decryptObject = (obj) ->
    return CryptoJS.AES.decrypt(obj, PHRASE).toString(CryptoJS.enc.Utf8)


  ###
   decrypt string.
  ###
  _decryptString = (str) ->
    return CryptoJS.AES.decrypt(_Json.parse(str), PHRASE).toString(CryptoJS.enc.Utf8)


  ###
   decrypt according it type.
  ###
  _decrypt = (any) ->
    if typeof any is "string"
      return _decryptString(any)
    else
      return _decryptObject(any)


  ###
   decrypt the account data, only to sync on chrome.
  ###
  _decryptAuth = () ->
    @apiKey = _decrypt @apiKey
    @id     = _decrypt @id
    @pass   = _decrypt @pass


  ###
   encrypt the account data, only to sync on chrome.
  ###
  _encrypt = () ->
    @apiKey = _Json.stringify CryptoJS.AES.encrypt(@apiKey, PHRASE)
    @id     = _Json.stringify CryptoJS.AES.encrypt(@id, PHRASE)
    @pass   = _Json.stringify CryptoJS.AES.encrypt(@pass, PHRASE)


  ###
   all account.
  ###
  _accounts = []

  return {

    ###
     get all account data.
     if account was not loaded, load from chrome sync.
    ###
    getAccounts: (callback) ->
      callback = callback or NULLFUNC
      if _accounts.length > 0
        callback _accounts
        return
      chrome.storage.sync.get ACCOUNTS, (item) ->
        if chrome.runtime.lastError? or not item[ACCOUNTS]?
          callback null
        else
          for a in item[ACCOUNTS]
            _decryptAuth.apply(a)
          _accounts = item[ACCOUNTS]
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
          _encrypt.apply(a)
          newArry.push a
        accounts = newArry
        _encrypt.apply(account)
        accounts.push account
        chrome.storage.sync.set ACCOUNTS: accounts, () ->
          if chrome.runtime.lastError?
            callback false
          else
            _decryptAuth.apply(account)
            for a, i in _accounts when a.url is account.url
              _accounts.splice i, 1
              break
            _accounts.push account
            callback true
            $rootScope.$broadcast 'accountAdded', account
            analytics.sendEvent 'internal', 'account', 'add', _accounts.length


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
            for a, i in _accounts when a.url is url
              _accounts.splice i, 1
              break
            callback true
            $rootScope.$broadcast 'accountRemoved', url
            analytics.sendEvent 'internal', 'account', 'remove', _accounts.length


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
          while _accounts.length > 0
            a = _accounts.pop()
            $rootScope.$broadcast 'accountRemoved', a.url
          callback true
  }
)
