# refer: https://github.com/angular/angular.js/blob/master/src/ng/filter/limitTo.js

timeTracker.filter 'limitTo', () ->

  isNumber = (x) ->
    if typeof(x) != 'number' && typeof(x) != 'string'
      return false
    else
      return (x == parseFloat(x) && isFinite(x))

  isString = (obj) ->
    typeof(obj) == "string" || obj instanceof String

  return (input, limit, begin) ->
    if Math.abs(Number(limit)) == Infinity
      limit = Number(limit)
    else
      limit = parseInt(limit, 10)
    if isNaN(limit) then return input
    if isNumber(input) then input = input.toString()
    if !Array.isArray(input) and !isString(input)
      return input
    begin = if !begin or isNaN(begin) then 0 else parseInt(begin, 10)
    begin = if begin < 0 and begin >= - input.length then input.length + begin else begin
    if limit >= 0
      input.slice begin, begin + limit
    else
      if begin == 0
        input.slice limit, input.length
      else
        input.slice Math.max(0, begin + limit), begin
