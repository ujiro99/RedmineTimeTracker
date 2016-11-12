angular.module('chrome', []).provider 'Platform', () ->

  ###
   Platform api wrapper for chrome app.
  ###
  class Platform

    # key on storage
    @SELECTED_PROJECT: "SELECTED_PROJECT"

    constructor: (@$q, @$log) ->

    ###*
     Load data from `storage`.
     @param storage  {Object}   Storage area on chrome.
     @param key      {String}   Key of data.
     @param callback {Function} Call on exit.
    ###
    _load: (storage, key, callback) ->
      callback or callback = -> #noop
      if not storage? then callback(null); return
      storage.get key, (data) =>
        if chrome.runtime.lastError? then callback(null); return
        if not data[key]? then callback(null); return
        callback(data[key])

    ###*
     Save data to `storage`.
     @param storage  {Object}   Storage area on chrome.
     @param key      {String}   Key of data.
     @param value    {Object}   Value which to be saved.
     @param callback {Function} Call on exit.
    ###
    _save: (storage, key, value, callback) ->
      callback or callback = -> #noop
      if not storage? then callback(false); return
      obj = {}
      obj[key] = value
      storage.set obj, ->
        if chrome.runtime.lastError? then callback(false); return
        callback(true)

    ###*
     Load data from chrome storage area.
     @param key {String} Key of data.
     @return {Object} promise
    ###
    load: (key) =>
      deferred = @$q.defer()
      @_load chrome.storage.local, key, (local) =>
        if local?
          @$log.info key + ' loaded from local.'
          @$log.debug local
          deferred.resolve(local)
        else
          @_load chrome.storage.sync, key, (sync) =>
            if chrome.runtime.lastError?
              @$log.info key + ' cannot load.'
              deferred.reject(null)
            @$log.info key + ' loaded from sync.'
            @$log.debug sync
            deferred.resolve(sync)
      return deferred.promise

    ###*
     Save data to chrome storage area.
     @param key   {String} Key of data.
     @param value {Object} Value which to be saved.
     @return {Object} promise
    ###
    save: (key, value) =>
      deferred = @$q.defer()
      @_save chrome.storage.local, key, value, (res) =>
        if res
          @$log.info key + ' saved to local.'
        else
          @$log.info key + ' failed to save to local.'
        @_save chrome.storage.sync, key, value, (res) =>
          if res
            @$log.info key + ' saved to sync.'
            deferred.resolve()
          else
            @$log.info key + ' failed to save to sync.'
            deferred.reject()
          @$log.debug value
      return deferred.promise

    ###*
     Save data to chrome storage `local` area.
     @param key   {String} Key of data.
     @param value {Object} Value which to be saved.
     @return {Object} promise
    ###
    saveLocal: (key, value) =>
      deferred = @$q.defer()
      @_save chrome.storage.local, key, value, (res) =>
        if res
          @$log.info key + ' saved to local.'
          deferred.resolve()
        else
          @$log.info key + ' failed to save to local.'
          deferred.reject()
      return deferred.promise

    ###*
     Gets the browser UI language of the browser.
     @return {string} language
     {@link https://developer.chrome.com/webstore/i18n?csw=1#localeTable Supported Locale}
    ###
    getLanguage: () ->
      lang = chrome.i18n.getUILanguage()
      @$log.debug("Language: " + lang)
      return lang

  return {
    getLanguage: () -> chrome.i18n.getUILanguage()
    $get: ($q, $log) ->
      if chrome?
        return new Platform($q, $log)
      else
        $log.error "chrome api not exists."
        return null
  }
