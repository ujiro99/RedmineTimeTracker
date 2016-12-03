chrome = {

  storage:
    local:
      get: (key, callback) ->
        console.log(key)
        setTimeout () -> callback true
      set: (key, callback) ->
        console.log(key)
        setTimeout () -> callback true
    sync:
      get: (key, callback) ->
        console.log(key)
        setTimeout () -> callback true
      set: (key, callback) ->
        console.log(key)
        setTimeout () -> callback true

  runtime:
    lastError: null

  i18n:
    getUILanguage: -> return 'en'
}
