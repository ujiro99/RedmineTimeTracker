timeTracker.filter 'numLength', () ->

  return (n, len) ->
    num = parseInt(n, 10)
    len = parseInt(len, 10)
    if isNaN(num) || isNaN(len) then return n
    num = '' + num
    num = '0' + num while num.length < len
    return num

