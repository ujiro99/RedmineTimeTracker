timeTracker.factory("Account", ($rootScope, $q, Analytics, Platform, Log) ->

  ACCOUNTS = "ACCOUNTS"
  PHRASE = "hello, redmine time traker."

  ###*
   Account information for login to redmine.
   @class AccountModel
  ###
  class AccountModel

    ###*
     @constructor
     @param {String} url - Redmine server's url.
     @param {String} apiKey - Redmine server's apiKey.
     @param {String} id - User id.
     @param {String} pass - User password.
     @param {String} name - Redmine's name for identify by user.
     @param {Number} numProjects - Number of projects to fetch.
     @param {Array}  projectList - Project id which will be fetched.
    ###
    constructor: (@url, @apiKey, @id, @pass, @name, @numProjects, projectList) ->
      if not @name or @name.isBlank()
        @name = @url

      if Object.isString(projectList)
        @projectList = @parseProjectList(projectList)
      else
        @projectList = projectList


    ###*
     Create new AccountModel instance from Object with parameters.
     @param {Object} obj - New parameters.
     @returns new AccountModel instance.
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

    ###*
     Check this model has valid parameters.
     @return True is valid parameters.
    ###
    isValid: () ->
      return false if not @url?
      if @apiKey?
        return true
      else
        return @id? and @pass?

    ###*
     Update parameters.
     @param {Object} newModel - New parameters.
    ###
    update: (newModel) ->
      @url         = newModel.url
      @apiKey      = newModel.apiKey
      @id          = newModel.id
      @pass        = newModel.pass
      @name        = newModel.name
      @numProjects = newModel.numProjects
      @projectList = newModel.projectList

    ###*
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

    ###*
     decrypt object. this is used for compatibility.
    ###
    _decryptObject: (obj) ->
      return CryptoJS.AES.decrypt(obj, PHRASE).toString(CryptoJS.enc.Utf8)

    ###*
     decrypt string.
    ###
    _decryptString: (str) ->
      return CryptoJS.AES.decrypt(@_Json.parse(str), PHRASE).toString(CryptoJS.enc.Utf8)

    ###*
     decrypt according it type.
    ###
    _decrypt: (any) ->
      if typeof any is "string"
        return @_decryptString(any)
      else
        return @_decryptObject(any)

    ###*
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

    ###*
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

    ###*
     parse projectList string to array.
    ###
    parseProjectList: (str) ->
      return null if not str
      reNum = /\d+/
      tmp = str.split(',')
      res = tmp.map (n) ->
        found = n.match(reNum)
        if found and found.length is 1
          return found[0]-0
      return res.compact()


  ###*
   all account.
  ###
  _accounts = []


  ###*
   Class for managing AccountModels.
   @class Account
  ###
  class Account

    NULLFUNC = ->

    ###*
     Create new AccountModel instance.
     @param {Object} param - account parameters.
     @return {AccountModel} created instance.
    ###
    create: (param) ->
      return AccountModel.fromObject(param)


    ###*
     Load all account data.
     @return {Promise.<AccountModel[]>} A promise for result of account data loading.
    ###
    load: () ->
      Log.debug "Account.load() start"

      return Platform.load(ACCOUNTS).then (items) ->
        Log.debug "Account.load() success."
        if not items
          Log.info 'account was not created ever.'
          return
        else
          Log.info 'account loaded'
          _accounts.clear()
          for a in items
            _accounts.push AccountModel.fromObject(a).decrypt()
          return _accounts
      , ->
        Log.debug "Account.load() failed."
        $q.reject("Platform Error")


    ###*
     Get all account data.
     @return {Array} AccountModel[]
    ###
    getAccounts: () ->
      return _accounts

    ###*
     Add a account data to storage. A account.url must be unique.
     @param {Object} account - Account data object.
     @return {Promise.<AccountModel>} Promise for saved data.
    ###
    addAccount: (account) ->
      account = AccountModel.fromObject(account)
      if not account? then $q.reject("Parameter Error"); return
      accounts = @getAccounts() or []
      # merge accounts.
      accounts = for a in accounts when a.url isnt account.url
        a.encrypt()
      accounts.push account.encrypt()
      Platform.save(ACCOUNTS, accounts).then () ->
        for a, i in _accounts when a.url is account.url
          _accounts.splice i, 1
          break
        _accounts.push account
        $rootScope.$broadcast 'accountAdded', account
        Analytics.sendEvent 'account', 'count', 'onAdd', _accounts.length
        return account
      , ->
        $q.reject("Platform Error")


    ###*
     Remove account by url.
     @param {String} url - Url of target account.
     @return {Promise.<undefined>}
    ###
    removeAccount: (url) ->
      if not url? then $q.reject("Parameter Error"); return
      accounts = @getAccounts() or []
      # select other url account
      accounts = for a in accounts when a.url isnt url
        a.encrypt()
      Platform.save(ACCOUNTS, accounts).then () ->
        for a, i in _accounts when a.url is url
          _accounts.splice i, 1
          break
        $rootScope.$broadcast 'accountRemoved', url
        Analytics.sendEvent 'account', 'count', 'onRemove', _accounts.length
      , () ->
        $q.reject("Platform Error")


    ###*
     Clear all account data.
     @return {Promise.<undefined>}
    ###
    clearAccount: () ->
      Platform.save(ACCOUNTS, null)
      return Platform.save(ACCOUNTS, null).then () ->
        while _accounts.length > 0
          a = _accounts.pop()
          $rootScope.$broadcast 'accountRemoved', a.url


  return new Account()

)
