angular.module('chrome', []).factory 'Chrome', ($q, $log) ->

  ###
   Chrome app api wrapper.
  ###
  class Chrome extends chrome

    ###*
     Load data from `storage`.
     @param storage  {Object}   Storage area on chrome.
     @param key      {String}   Key of data.
     @param callback {Function} Call on exit.
    ###
    @_load: (storage, key, callback) ->
      callback or callback = -> #noop
      if not storage? then callback(null); return
      storage.get key, (data) =>
        if chrome.runtime.lastError? then callback(null); return
        if not data[key]? then callback(null); return
        callback(data[key])

    ###*
     Load data from chrome storage area.
     @param key {String} Key of data.
    ###
    @load: (key) =>
      deferred = $q.defer()
      @_load chrome.storage.local, key, (local) =>
        if local?
          $log.info key + ' loaded from local.'
          $log.debug local
          deferred.resolve(local)
        else
          @_load chrome.storage.sync, key, (sync) =>
            if chrome.runtime.lastError?
              $log.info key + ' cannot load.'
              deferred.reject(null)
            $log.info key + ' loaded from sync.'
            $log.debug sync
            deferred.resolve(sync)
      return deferred.promise


  if chrome?
    return Chrome
  else
    $log.error "chrome api not exists."
    return null
