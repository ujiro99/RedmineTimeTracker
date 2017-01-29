timeTracker.factory "Message", ($rootScope, $timeout) ->

  MESSAGE_DURATION = 1500
  ANIMATION_DURATION = 1000
  H_PADDING = 8
  STYLE_HIDDEN = 'height': 0

  _ruler = document.querySelector("#ruler")
  _message_ruler = document.querySelector(".message__ruler span")

  _strScale = (str) ->
    _ruler.textContent = str
    width = _ruler.offsetWidth
    height = _ruler.offsetHeight
    _ruler.textContent = null
    return w: width, h: height

  _getMessageWidth = ->
    return _message_ruler.offsetWidth

  return {

    ###
     show message page bottom.
    ###
    toast: (text, duration) ->
      duration = duration or MESSAGE_DURATION
      msg = {
        text: text
        style: STYLE_HIDDEN
      }
      scale = _strScale(text)
      rows = Math.ceil(scale.w / _getMessageWidth())

      $rootScope.messages.push msg
      $timeout ->
        msg.style = 'height': H_PADDING + rows * scale.h
      , 50
      $timeout ->
        msg.style = STYLE_HIDDEN
      , duration
      $timeout ->
        $rootScope.messages.shift()
      , duration + ANIMATION_DURATION

  }
