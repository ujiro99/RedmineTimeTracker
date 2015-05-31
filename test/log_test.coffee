expect = chai.expect

describe 'log.coffee', ->

  Log = null

  beforeEach () ->
    angular.mock.module('timeTracker')

    timeTracker.config (LogProvider, StateProvider) ->
      LogProvider.options.enable = StateProvider.State.debug
      LogProvider.options.level = LogProvider.Level.DEBUG

    inject (_Log_) ->
      Log = _Log_   # underscores are a trick for resolving references.


  methods = [
    'log',
    'debug',
    'info',
    'warn',
    'error'
  ]

  describe 'Log', ->
    methods.map (m) ->
      it "#{m} be not empty", () ->
        expect(Log[m]).to.not.be.empty
        Log[m]("#{m}() is enable.")

    it "assert", () ->
      expect(Log.assert).to.not.be.empty
      Log.assert(true,  "on true.")
      Log.assert(false, "on false")

    it "group", () ->
      expect(Log.group).to.not.be.empty
      Log.groupCollapsed("logTest")
      for i in [0...5]
        Log.info("in group: #{i}")
      Log.groupEnd("logTest")

    it "time", () ->
      expect(Log.time).to.not.be.empty
      Log.time("time")
      total = 0
      for i in [0...100] then total+= i
      Log.timeEnd("time")
