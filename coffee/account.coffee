timeTracker.factory("$account", () ->

  ACCOUNTS = "ACCOUNTS"
  PHRASE = "hello, redmine time traker."
  NULLFUNC = () ->


  _decrypt = () ->
    @apiKey = CryptoJS.AES.decrypt(@apiKey, PHRASE)
    @id     = CryptoJS.AES.decrypt(@id, PHRASE)
    @pass   = CryptoJS.AES.decrypt(@pass, PHRASE)


  _encrypt = () ->
    @apiKey = CryptoJS.AES.encrypt(@apiKey, PHRASE).ciphertext.words.join('')
    @id     = CryptoJS.AES.encrypt(@id, PHRASE).ciphertext.words.join('')
    @pass   = CryptoJS.AES.encrypt(@pass, PHRASE).ciphertext.words.join('')


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
          for a in item[ACCOUNTS]
            a.decrypt = _decrypt
          callback item[ACCOUNTS]


    ###
     add a account data using chrome local
    ###
    addAccount: (account, callback) ->
      if not account? then callback false; return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        newArry = []
        # merge accounts.
        for a in accounts when a.host isnt account.host
          newArry.push a
        accounts = newArry
        _encrypt.apply(account)
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
