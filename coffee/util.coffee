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
 clear array.
###
if not ('clear' in Array.prototype)
  Array.prototype.clear = () ->
    while (this.length > 0) then this.pop()
    return


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

}
