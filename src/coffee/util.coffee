###
 return true if this contains targetStr from searchStartIndex.
###
if not ('contains' in String.prototype)
  String.prototype.contains = (targetStr, searchStartIndex) ->
    return -1 isnt String.prototype.indexOf.call(this, targetStr, searchStartIndex)


###
 return true if this is null or undefined or '' or '  '.
###
if not ('isBlank' in String.prototype)
  String.prototype.isBlank = () ->
    return !this? || this.trim?() is ''


###
 test this string is URL.
###
if not ('isUrl' in String.prototype)
  String.prototype.isUrl = () ->
    return /^(https?):\/\/((?:[a-z0-9.-]|%[0-9A-F]{2}){3,})(?::(\d+))?((?:\/(?:[a-z0-9-._~!$&'()*+,;=:@]|%[0-9A-F]{2})*)*)(?:\?((?:[a-z0-9-._~!$&'()*+,;=:\/?@]|%[0-9A-F]{2})*))?(?:#((?:[a-z0-9-._~!$&'()*+,;=:\/?@]|%[0-9A-F]{2})*))?$/i.test(this)


###
 clear array.
###
if not ('clear' in Array.prototype)
  Array.prototype.clear = () ->
    while (this.length > 0) then this.pop()
    return


###
 remove all elements in array, and insert new array's all element.
###
if not ('set' in Array.prototype)
  Array.prototype.set = (newArray) ->
    [].splice.apply(this, [0, this.length].concat(newArray))
    return


###
 XOR to using hash() of each object in the Array.
###
if not ('xor' in Array.prototype)
  Array.prototype.xor = (arr) ->
    obj = {}
    for x in this then obj[x.hash()] = x
    for y in arr
      continue if not y or not y.hash
      if obj[y.hash()]
        delete obj[y.hash()]
      else
        obj[y.hash()] = y
    return (for key, value of obj then value)


###
 union to using hash() of each object in the Array.
###
if not ('union' in Array.prototype)
  Array.prototype.union = (arr) ->
    obj = {}
    for x in this then obj[x.hash()] = x
    for y in arr  then obj[y.hash()] = y
    return (for key, value of obj then value)


###
 change object to array.
###
if not ('toKeyValuePair' in Object)
  Object.toKeyValuePair = (obj, keyValueNamePair) ->
    arry = []
    keyValueNamePair or keyValueNamePair = {key: "key", value: "value"}
    for k, v of obj
      pair = {}
      pair[keyValueNamePair.key] = k
      pair[keyValueNamePair.value] = v
      arry.push pair
    return arry


###
 define getter, setter.
 @ref http://stackoverflow.com/questions/11587231/coffeescript-getter-setter-in-object-initializers
###
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc


@util = {

  ###
   get url
   @ref http://stackoverflow.com/questions/736513/how-do-i-parse-a-url-into-hostname-and-path-in-javascript
  ###
  getUrl: (href) ->
    l = document.createElement('a')
    l.href = href
    if l.protocol is "chrome-extension:"
      l.href = "http://" + href
    return (l.protocol + "//" + l.host + l.pathname).replace(/\/$/, '')

  ###
   escape Regular Expression token in String.
  ###
  escapeRegExp: (str) ->
    str = "" + str
    return str.replace(/([\\\/\'*+?|()\[\]{}.^$-])/g,'\\$1')

  ###
   deep compare object.
  ###
  equals: (x, y) ->
    paramName = undefined
    compare = (objA, objB, param) ->
      paramObjA = objA[param]
      paramObjB = (if (typeof objB[param] is "undefined") then false else objB[param])
      switch typeof objA[param]
        when "object"
          return util.equals paramObjA, paramObjB
        when "function"
          return paramObjA.toString() is paramObjB.toString()
        else
          return paramObjA is paramObjB
    for paramName of x
      if typeof y[paramName] is "undefined" or not compare(x, y, paramName)
        return false
    for paramName of y
      if typeof x[paramName] is "undefined" or not compare(x, y, paramName)
        return false
    return true


  ###*
   Search items which matches query.
   this function is for typeahead.js.
   @param objects {Array}  Array of object which being searched.
   @param keys {Array}  Array of key which will be searched in object.
  ###
  substringMatcher: (objects, keys) ->
    keys = [keys] if not Array.isArray(keys)

    ###
     @param query {String} Search query. Multiple queries are separated with space.
     @param cb {Function} Callback for result.
    ###
    return findMatches = (query, cb) ->
      matches = []
      substrRegexs = []
      queries = []
      for q in query.split(' ') when not q.isBlank()
        queries.push q
        substrRegexs.push new RegExp(util.escapeRegExp(q), 'i')

      for obj in objects
        isAllMatch = true
        for r in substrRegexs
          isMatch = false
          for key in keys
            target = {}
            for k in key.split('.')
              target = target[k] or obj[k]
              if target is undefined then break
            isMatch |= r.test(target)
          isAllMatch &= isMatch

        if isAllMatch then matches.push(obj)

      cb(matches, queries)


  ###*
   Format time to `hh:mm:ss`.
   @param millis {Number} millisecond
   @return {String} formatted string.
  ###
  formatMillis: (millis) ->
    time = {}
    time.s = Math.floor((millis / 1000) % 60)
    time.m = Math.floor((millis / (60000)) % 60)
    time.h = Math.floor(millis / (3600000))

    for key, num of time
      num = '' + parseInt(num, 10)
      num = '0' + num while num.length < 2
      time[key] = num

    return "#{time.h}:#{time.m}:#{time.s}"


  ###*
   Format time to `hh:mm`.
   @param minutes {Number} minutes
   @return {String} formatted string.
  ###
  formatMinutes: (minutes) ->
    time = {}
    time.m = Math.floor(minutes % 60)
    time.h = Math.floor(minutes / 60)

    for key, num of time
      num = '' + parseInt(num, 10)
      num = '0' + num while num.length < 2
      time[key] = num

    return "#{time.h}:#{time.m}"

}
