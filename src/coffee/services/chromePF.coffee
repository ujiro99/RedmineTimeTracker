angular.module('chrome', []).provider 'Platform', () ->

  ###*
   Platform api wrapper for chrome app.
  ###
  class Platform

    # key on storage
    @SELECTED_PROJECT: "SELECTED_PROJECT"

    ###*
     @constructor
    ###
    constructor: (@$q, @$log) ->

    ###*
     Load data from chrome storage area.
     @param {String} key - Key of data.
     @return {Object} promise
    ###
    load: (key) =>
      deferred = @$q.defer()

      chrome.storage.local.get key, (local) =>
        if not chrome.runtime.lastError? and local[key]?
          @$log.info key + ' loaded from local.'
          @$log.debug local
          deferred.resolve(local[key])
        else

          chrome.storage.sync.get key, (sync) =>
            if chrome.runtime.lastError?
              @$log.info key + ' cannot load.'
              deferred.reject(null)
            @$log.info key + ' loaded from sync.'
            @$log.debug sync[key]
            deferred.resolve(sync[key])

      return deferred.promise

    ###*
     Save data to both `local` and `sync` chrome storage area.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Object} promise
    ###
    save: (key, value) =>
      deferred = @$q.defer()

      obj = {}
      obj[key] = value
      chrome.storage.local.set obj, =>
        if chrome.runtime.lastError?
          @$log.info key + ' failed to save to local.'
        else
          @$log.info key + ' saved to local.'

        chrome.storage.sync.set obj, =>
          if chrome.runtime.lastError?
            @$log.info key + ' failed to save to sync.'
            deferred.reject()
          else
            @$log.info key + ' saved to sync.'
            deferred.resolve()
          @$log.debug value

      return deferred.promise

    ###*
     Save data to chrome storage `local` area.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Object} promise
    ###
    saveLocal: (key, value) =>
      deferred = @$q.defer()

      obj = {}
      obj[key] = value
      chrome.storage.local.set obj, =>
        if chrome.runtime.lastError?
          @$log.info key + ' failed to save to local.'
          deferred.reject()
        else
          @$log.info key + ' saved to local.'
          deferred.resolve()

      return deferred.promise

    ###*
     Gets the browser UI language of the browser.
     @return {String} language
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
