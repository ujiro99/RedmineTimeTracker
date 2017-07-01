expect = chai.expect

describe 'eventDispather.coffee', ->

  _eventDispather = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_EventDispatcher_) ->
      EventDispatcher = _EventDispatcher_
      _eventDispather = new EventDispatcher()

  # hasEventListener(eventName) ->
  # addEventListener(eventName, callback) ->
  # removeEventListener(eventName, callback) ->
  # fireEvent(eventName, opt_this, opt_arg) ->


  ###
   test for hasEventListener()
  ###
  describe 'hasEventListener(eventName)', ->

    it 'return false, if event is empty.', () ->
      res = _eventDispather.hasEventListener("some events")
      expect(res).to.be.false

    it 'return true, if eventName is exists.', () ->
      _eventDispather.addEventListener("some events", ()->)
      res = _eventDispather.hasEventListener("some events")
      expect(res).to.be.true


  ###
   test for addEventListener(eventName, callback)
  ###
  describe 'addEventListener(eventName, callback)', ->

    it 'add a listner.', () ->
      callback = ()->
      _eventDispather.addEventListener("some events", callback)
      res = _eventDispather._events["some events"][0]
      expect(res).to.be.equal(callback)

    it 'not add same listner.', () ->
      callback = ()->
      _eventDispather.addEventListener("some events", callback)
      _eventDispather.addEventListener("some events", callback)
      res = _eventDispather._events["some events"]
      expect(res).to.have.lengthOf(1)

    it 'add 2 listner to same event.', () ->
      callback1 = ()->
      callback2 = ()->
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("some events", callback2)
      res = _eventDispather._events["some events"]
      expect(res).to.have.lengthOf(2)

    it 'add 2 listner to other event.', () ->
      callback1 = ()->
      callback2 = ()->
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("other events", callback2)
      res = _eventDispather._events["some events"]
      expect(res).to.have.lengthOf(1)
      res = _eventDispather._events["other events"]
      expect(res).to.have.lengthOf(1)


  ###
   test for removeEventListener(eventName, callback)
  ###
  describe 'removeEventListener(eventName, callback)', ->

    it 'remove all listeners.', () ->
      callback1 = ()->
      callback2 = ()->
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("some events", callback2)
      _eventDispather.removeEventListener("some events")
      res = _eventDispather._events["some events"]
      expect(res).to.be.undefined

    it 'remove a listener.', () ->
      callback1 = ()->
      callback2 = ()->
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("some events", callback2)
      _eventDispather.removeEventListener("some events", callback1)
      res = _eventDispather._events["some events"]
      expect(res).to.have.lengthOf(1)

    it 'does nothing, if event is empty.', () ->
      callback1 = ()->
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.removeEventListener("other events", callback1)
      res = _eventDispather._events["some events"]
      expect(res).to.have.lengthOf(1)


  ###
   test for fireEvent(eventName, opt_this, opt_arg)
  ###
  describe 'fireEvent(eventName, opt_this, opt_arg)', ->

    it 'does nothing, if event isn\'t exists.', () ->
      _eventDispather.fireEvent("some events")

    it 'exec listener', (done) ->
      callback1 = () -> done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.fireEvent("some events")

    it 'exec multiple listeners', (done) ->
      callback1 = () ->
      callback2 = () -> done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("some events", callback2)
      _eventDispather.fireEvent("some events")

    it 'exec listener with this', (done) ->
      callback1 = () ->
        expect(this).to.equal(_eventDispather)
        done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.fireEvent("some events")

    it 'exec listener with other this', (done) ->
      otherThis = {}
      callback1 = () ->
        expect(this).to.equal(otherThis)
        done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.fireEvent("some events", otherThis)

    it 'exec listener with a arguments', (done) ->
      arg1 = 1
      callback1 = (_arg1) ->
        expect(_arg1).to.equal(arg1)
        done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.fireEvent("some events", null, arg1)

    it 'exec listener with arguments', (done) ->
      arg1 = 1
      arg2 = 2
      arg3 = 3
      arg4 = 4
      arg5 = 5
      callback1 = (_arg1, _arg2, _arg3, _arg4, _arg5) ->
        expect(_arg1).to.equal(arg1)
        expect(_arg2).to.equal(arg2)
        expect(_arg3).to.equal(arg3)
        expect(_arg4).to.equal(arg4)
        expect(_arg5).to.equal(arg5)
        done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.fireEvent("some events", null, arg1, arg2, arg3, arg4, arg5)

    it 'argument changes do not propagate to the next listener.', (done) ->
      arg = [0]
      callback1 = (_arg) ->
        _arg = [false]
        # _arg[0] = false     # this changes will propagate.
      callback2 = (_arg) ->
        expect(_arg[0]).to.equal(0)
        done()
      _eventDispather.addEventListener("some events", callback1)
      _eventDispather.addEventListener("some events", callback2)
      _eventDispather.fireEvent("some events", null, arg)
