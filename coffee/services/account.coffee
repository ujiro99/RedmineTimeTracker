timeTracker.factory("Account", ($rootScope, $q, Analytics, Chrome, Log) ->

  ACCOUNTS = "ACCOUNTS"
  PHRASE = "hello, redmine time traker."
  NULLFUNC = () ->

  ###*
   Account infomation for login to redmine.
   @class AccountModel
  ###
  class AccountModel

    ###*
     @constructor
     @param url {String} Redmine server's url.
     @param apiKey {String} Redmine server's apiKey.
     @param id {String} User id.
     @param pass {String} User password.
     @param name {String} Redmine's name for identify by user.
     @param numProjects {Number} Number of projects to fetch.
     @param @projectList {Array} Project id which will be fetched.
    ###
    constructor: (@url, @apiKey, @id, @pass, @name, @numProjects, @projectList) ->
      if not @name or @name.isBlank()
        @name = @url

    ###
     set parameters from Object.
    ###
    @fromObject: (obj) ->
      return new AccountModel(
        obj.url
        obj.apiKey
        obj.id
        obj.pass
        obj.name
        obj.numProjects
        obj.projectList
      )

    ###
     is valid prameters.
    ###
    isValid: () ->
      return false if not @url?
      if @apiKey?
        return true
      else
        return @id? and @pass?

    ###
     update prameters.
    ###
    update: (newModel) ->
      @url         = newModel.url
      @apiKey      = newModel.apiKey
      @id          = newModel.id
      @pass        = newModel.pass
      @name        = newModel.name
      @numProjects = newModel.numProjects
      @projectList = newModel.projectList

    ###
     JSON formatter for cipherParams.
    ###
    _Json:
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
    _decryptObject: (obj) ->
      return CryptoJS.AES.decrypt(obj, PHRASE).toString(CryptoJS.enc.Utf8)

    ###
     decrypt string.
    ###
    _decryptString: (str) ->
      return CryptoJS.AES.decrypt(@_Json.parse(str), PHRASE).toString(CryptoJS.enc.Utf8)

    ###
     decrypt according it type.
    ###
    _decrypt: (any) ->
      if typeof any is "string"
        return @_decryptString(any)
      else
        return @_decryptObject(any)

    ###
     decrypt the account data, only to sync on chrome.
    ###
    decrypt: () ->
      return new AccountModel(
        @url
        @_decrypt @apiKey
        @_decrypt @id
        @_decrypt @pass
        @name
        @numProjects
        @projectList
      )

    ###
     encrypt the account data, only to sync on chrome.
    ###
    encrypt: () ->
      return new AccountModel(
        @url
        @_Json.stringify CryptoJS.AES.encrypt(@apiKey, PHRASE)
        @_Json.stringify CryptoJS.AES.encrypt(@id, PHRASE)
        @_Json.stringify CryptoJS.AES.encrypt(@pass, PHRASE)
        @name
        @numProjects
        @projectList
      )


  ###
   all account.
  ###
  _accounts = []

  return {

    ###
     create new AccountModel instance.
     @param {Object} param - account parameters.
     @return {AccountModel} created instance.
    ###
    create: (param) ->
      return AccountModel.fromObject(param)


    ###
     load all account data from chrome sync.
     @return {Array} AccountModel[]
    ###
    load: () ->
      Log.debug "Account.load() start"
      deferred = $q.defer()

      Chrome.storage.sync.get ACCOUNTS, (item) ->
        if Chrome.runtime.lastError?
          Log.info 'account load failed.'
          deferred.reject()
        else if not item[ACCOUNTS]
          Log.info 'account was not created ever.'
          deferred.resolve()
        else
          Log.info 'account loaded'
          _accounts.clear()
          for a in item[ACCOUNTS]
            _accounts.push AccountModel.fromObject(a).decrypt()
          deferred.resolve(_accounts)

      return deferred.promise


    ###
     get all account data.
     @return {Array} AccountModel[]
    ###
    getAccounts: () ->
      return _accounts


    ###
     add a account data using chrome sync. url is unique.
    ###
    addAccount: (account, callback) ->
      account = AccountModel.fromObject(account)
      if not account? then callback false; return
      callback = callback or NULLFUNC
      accounts = @getAccounts() or []
      # merge accounts.
      newArry = []
      newArry = for a in accounts when a.url isnt account.url
        a.encrypt()
      accounts = newArry
      accounts.push account.encrypt()
      Chrome.storage.sync.set ACCOUNTS: accounts, () ->
        if Chrome.runtime.lastError?
          callback false
        else
          for a, i in _accounts when a.url is account.url
            _accounts.splice i, 1
            break
          _accounts.push account
          callback true, account
          $rootScope.$broadcast 'accountAdded', account
          Analytics.sendEvent 'internal', 'account', 'add', _accounts.length


    ###
     remove by url.
    ###
    removeAccount: (url, callback) ->
      if not url? then callback false; return
      callback = callback or NULLFUNC
      accounts = @getAccounts() or []
      # select other url account
      accounts = for a in accounts when a.url isnt url
        a.encrypt()
      Chrome.storage.sync.set ACCOUNTS: accounts, () ->
        if Chrome.runtime.lastError?
          callback false
        else
          for a, i in _accounts when a.url is url
            _accounts.splice i, 1
            break
          callback true
          $rootScope.$broadcast 'accountRemoved', url
          Analytics.sendEvent 'internal', 'account', 'remove', _accounts.length


    ###
      clear all account data
    ###
    clearAccount: (callback) ->
      callback = callback or NULLFUNC
      Chrome.storage.local.clear()
      Chrome.storage.sync.clear () ->
        if Chrome.runtime.lastError?
          callback false
        else
          while _accounts.length > 0
            a = _accounts.pop()
            $rootScope.$broadcast 'accountRemoved', a.url
          callback true
  }
)
