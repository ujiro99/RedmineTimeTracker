# http://kimizuka.hatenablog.com/entry/2014/07/06/000000

###*
 Dispatcher for event.
 @class EventDispatcher
###
class EventDispatcher

  _events: {}

  ###*
   イベントが登録されているか調べます
   @param {String} eventName - イベント名
  ###
  hasEventListener: (eventName) ->
    !!@_events[eventName]


  ###*
   イベントを登録します
   @param {String}   eventName - イベント名
   @param {Function} callback  - 追加する関数
  ###
  addEventListener: (eventName, callback) ->
    if @hasEventListener(eventName)
      events = @_events[eventName]
      # すでに登録されているときはしない
      for event in events when event is callback then return
      events.push callback
    else
      @_events[eventName] = [ callback ]
    return


  ###*
   イベントを削除します
   @param {String}   eventName - イベント名
   @param {Function} callback  - 削除する関数
  ###
  removeEventListener: (eventName, callback) ->
    if !@hasEventListener(eventName)
      return
    else
      events = @_events[eventName]
      for event, i in events when event is callback
        events.splice i, 1
        break
    return


  ###*
   イベントを発火します
   @param {String} eventName - イベント名
   @param {Object} opt_this  - thisの値
   @param {Object} opt_arg   - 引数
  ###
  fireEvent: (eventName, opt_this, opt_arg) ->
    _copyArray = (array) ->
      newArray = []
      i = 0
      try
        newArray = [].slice.call(array)
      catch e
        while i < array.length
          newArray.push array[i]
          i++
      newArray

    if !@hasEventListener(eventName)
      return
    else
      events = @_events[eventName]
      copyEvents = _copyArray(events)
      # eventNameとopt_thisを削除
      arg = _copyArray(arguments)
      arg.splice 0, 2
      for events in copyEvents
        events.apply opt_this or this, arg
    return


timeTracker.factory("EventDispatcher", () -> return EventDispatcher)
