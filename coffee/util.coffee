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
 format string.
###
if not ('format' in String.prototype)
  String.prototype.format = (arg) ->
    rep_fn = undefined
    if typeof arg is "object"
        rep_fn = (m, k) -> return arg[k]
    else
        args = arguments
        rep_fn = (m, k) ->  return args[parseInt(k)]
    return this.replace /\{(\w+)\}/g, rep_fn


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
 define getter, setter.
 @ref http://stackoverflow.com/questions/11587231/coffeescript-getter-setter-in-object-initializers
###
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc


@util = {

  ###
   get url
  ###
  getUrl: (url) ->
    return $.trim(url).replace(/\?.*$/, '').replace(/\/$/, '')

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


  ###
   Search items which matches query.
   this function is for typeahead.js.
  ###
  substringMatcher: (objects, key) ->
    return findMatches = (query, cb) ->
      matches = []
      substrRegexs = []
      queries = []
      for q in query.split(' ') when not q.isBlank()
        queries.push q
        substrRegexs.push new RegExp(q, 'i')

      for obj in objects
        isAllMatch = true
        for r in substrRegexs
          isAllMatch = isAllMatch and r.test(obj[key])

        matches.push(obj) if isAllMatch

      cb(matches, queries)



}
