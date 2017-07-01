# http://kimizuka.hatenablog.com/entry/2014/07/06/000000

###*
 Dispatcher for event.
 @class EventDispatcher
###
class EventDispatcher

  _toArray = (array) -> return [].slice.call(array)

  ###*
   @constructor
  ###
  constructor: () ->
    @_events = {}


  ###*
   Check if an event listener is registered.
   @param {String} eventName - event name
   @return true: registered / false: not registered
  ###
  hasEventListener: (eventName) ->
    !!@_events[eventName]


  ###*
   Register the listener to the event.
   If it is already registered, do not register the listener.
   @param {String} eventName - event name
   @param {Function} listener - listener function to be registered.
  ###
  addEventListener: (eventName, listener) ->
    if @hasEventListener(eventName)
      events = @_events[eventName]
      # if already registered, does not register.
      for event in events when event is listener then return
      events.push listener
    else
      @_events[eventName] = [ listener ]
    return


  ###*
   Remove the listener from the event.
   @param {String} eventName - event name
   @param {Function} [listener] - listener function to be removed.
                                  If omitted, delete all listeners including events.
  ###
  removeEventListener: (eventName, listener) ->
    if !@hasEventListener(eventName)
      return
    else
      if not listener?
        delete @_events[eventName]
      else
        events = @_events[eventName]
        for event, i in events when event is listener
          events.splice i, 1
          break
    return


  ###*
   Fire the event.
   @param {String} eventName - event name
   @param {Object} [_this] - value of `this` to be used by listeners.
   @param {Object} [_arg] - value of arguments to be used by listeners.
  ###
  fireEvent: (eventName, _this, _arg) ->
    if !@hasEventListener(eventName)
      return
    else
      events = @_events[eventName]
      copyEvents = _toArray(events)
      # remove eventName and _this from `arguments`.
      arg = _toArray(arguments)
      arg.splice 0, 2
      for events in copyEvents
        events.apply _this or this, arg
    return


timeTracker.factory("EventDispatcher", () -> return EventDispatcher)
