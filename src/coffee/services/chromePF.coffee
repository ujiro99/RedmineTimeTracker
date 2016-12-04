angular.module('chrome', []).provider 'Platform', () ->

  ###*
   Platform api wrapper for chrome app.
   @class Platform
  ###
  class Platform

    # key on storage
    @SELECTED_PROJECT: "SELECTED_PROJECT"

    ###*
     @constructor
     @param {Object} $q - Service for Promise.
     @param {Object} $log - Service for Log.
    ###
    constructor: (@$q, @$log) ->

    ###*
     @typedef LoadedObject
     @property {Object} Loaded object.
    ###

    ###*
     Load data from chrome storage area.
     @param {String} key - Key of data.
     @returns {Promise.<LoadedObject|undefined>} A promise for result of loading .
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
     @return {Promise.<undefined>} A promise for result of saving.
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
     @return {Promise.<undefined>} A promise for result of saving.
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
