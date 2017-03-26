angular.module('browser', []).provider 'Platform', () ->

  _getLanguage = () ->
    lang = (window.navigator.languages && window.navigator.languages[0]) ||
      window.navigator.language ||
      window.navigator.userLanguage ||
      window.navigator.browserLanguage
    return lang

  ###*
   Platform api wrapper for electron app.
   @class Platform
  ###
  class Platform

    # key on storage
    SELECTED_PROJECT: "SELECTED_PROJECT"

    ###*
     @constructor
     @param {Object} $q - Service for Promise.
     @param {Object} $log - Service for Log.
    ###
    constructor: (@$q, @$log) ->
      @_notification = null
      @DB_NAME = "keyval-store"
      @DB_VERSION = 1
      @STORE_NAME = "keyval"


    ###*
     Returns platform name.
     @return {string} platform name.
    ###
    getPlarform: () -> return 'browser'


    _getDB: () =>
      deferred = @$q.defer()
      req = indexedDB.open(@DB_NAME, @DB_VERSION)
      req.onsuccess = =>
        @$log.debug(req.result)
        deferred.resolve(req.result)
      req.onerror = =>
        @$log.debug(req.error)
        deferred.reject(req.error)
      req.onupgradeneeded = =>
        @$log.info("_getDB onupgradeneeded")
        # First time setup: create an empty object store
        req.result.createObjectStore(
          @STORE_NAME
        )
      return deferred.promise


    _withStore: (type, callback) =>
      deferred = @$q.defer()
      return @_getDB().then((db) =>
          transaction = db.transaction(@STORE_NAME, type)
          transaction.oncomplete = () =>
            deferred.resolve()
          transaction.onerror = () =>
            @$log.debug transaction.error
            deferred.reject(transaction.error)
          callback(transaction.objectStore(@STORE_NAME))
      )


    ###*
     @typedef LoadedObject
     @property {Object} Loaded object.
    ###

    ###*
     Load data from storage area.
     @param {String} key - Key of data.
     @returns {Promise.<LoadedObject>} A promise for result of loading .
    ###
    load: (key) =>
      req = null
      return @_withStore('readonly', (store) =>
        req = store.get(key)
      ).then(() =>
        @$log.info key + ' loaded.'
        @$log.debug req.reult
        return req.reult)


    ###*
     Save data to storage area.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    save: (key, value) =>
      return @_withStore('readwrite', (store) =>
        store.put(value, key)
        @$log.info key + ' saved.')


    ###*
     Save data to storage `local` area. Same as `save()`.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    saveLocal: (key, value) =>
      return @save(key, value)


    ###*
     Clear data from storage area.
     @return {Promise.<undefined>} A promise for result.
    ###
    clear: () =>
      return @_withStore('readwrite', (store) =>
        store.clear())


    ###*
     Gets the system locale.
     @return {String} language
     {@link http://electron.atom.io/docs/api/locales/}
    ###
    getLanguage: () =>
      lang = _getLanguage()
      @$log.debug("Language: " + lang)
      return lang


    ###*
     Show the application window.
    ###
    showAppWindow: () =>
      ## chrome only
      ## If the window is minimized, restore the size of the window
      window.open().close()
      window.focus()


    ###*
     Message which used on type = list.
     @typedef {object} listMessage
     @prop {string} title - list message title.
     @prop {string} message - list message body.
    ###

    ###*
     @typedef {object} NotificationOptions
     @prop {string} icon - Icon's url.
     @prop {string} iconUrl - Alias for icon.
     @prop {string} title - Notification title.
     @prop {listMessage[]} items - messages.
    ###

    ###*
     Creates and displays a notification.
     @param {NotificationOptions} options - Contents of the notification.
    ###
    createNotification: (options) =>
      # options.icon = options.icon or options.iconUrl
      # options.icon = __dirname + "/.." + options.icon
      options.body = ""
      for item in options.items
        options.body += "\n#{item.title}: #{item.message}"
      @_notification = new Notification(options.title, options)


    ###*
     Clears the notification.
    ###
    clearNotification: () =>
      if @_notification?
        @_notification.onclick = undefined
        @_notification.close()
        @_notification = null
      else
        @$log.log("Notification doesn't exist.")


    ###*
     @callback onClickedListener
    ###

    ###*
     Add on clicked lister to notification.
     @param {onClickedListener} listener - be called when the user clicked in a non-button area of the notification.
    ###
    addOnClickedListener: (listener) =>
      if @_notification?
        @_notification.onclick = listener
      else
        @$log.log("Notification doesn't exist.")


    ###*
     Get path.
     @param {string} path - Platform specified path.
    ###
    getPath: (path) ->
      return  path


    ###*
     Open url.
     @param {string} url - Url to be opened.
    ###
    openExternalLink: (url) =>
      return @$log.log("Invalid url.") if not url?
      a = document.createElement('a')
      a.href = url
      a.target='_blank'
      a.click()


    ###*
     Set proxy login event lister.
     @param {function} func - Function which will be called when fired app's 'login' event.
    ###
    setLoginLister: (func) =>
      return @$log.log("There is no implementation.")


  return {
    getLanguage: () -> return _getLanguage()
    openDevTools: () -> console.log("No support DevTools.")
    $get: ($q, $log) -> return new Platform($q, $log)
  }
