storage = {

  get: (key, callback) ->
    console.log(key)
    setTimeout () -> callback undefined
  set: (key, data, callback) ->
    console.log(key)
    setTimeout () -> callback true
  clear: (callback) ->
    setTimeout () -> callback true

}
