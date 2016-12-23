expect = chai.expect

describe 'option.coffee', ->

  Option = null
  $rootScope = null
  $q = null
  Platform = null


  DEFAULT_OPTION =
    reportUsage: true
    isProjectStarEnable: true
    removeClosedTicket: true
    itemsPerPage: 20


  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Option_, _$rootScope_, _$q_, _Platform_) ->
      Option = _Option_
      $rootScope = _$rootScope_
      $q = _$q_
      Platform = _Platform_


  describe 'getOptions()', ->

    it 'returns default properties.', () ->
      obj = Option.getOptions()
      for key, value of DEFAULT_OPTION
        expect(obj).to.have.property(key)

    it 'returns changed property.', () ->
      obj = Option.getOptions()
      obj.reportUsage = false
      obj = Option.getOptions()
      expect(obj.reportUsage).to.equal(false)


  describe 'onChanged', ->

    it 'calls changed callback.', (done) ->
      Option.onChanged (propName, newVal, oldVal) ->
        expect(propName).to.equals("reportUsage")
        expect(newVal).to.equals(false)
        done()
      expect(Option.getOptions().reportUsage).to.equals(true)
      Option.getOptions().reportUsage = false

    it 'calls changed 2 callbacas.', (done) ->
      Option.onChanged (propName, newVal, oldVal) ->
        if propName is "reportUsage"
          expect(newVal).to.equals(false)
      Option.onChanged (propName, newVal, oldVal) ->
        if propName is "isProjectStarEnable"
          expect(newVal).to.equals(true)
          done()
      o = Option.getOptions()
      o.reportUsage = false
      o.isProjectStarEnable = true

    it 'calls changed callback only specified key.', (done) ->
      Option.getOptions().isProjectStarEnable = true
      Option.onChanged 'isProjectStarEnable', (e) ->
        expect(e).to.equals(false)
        done()
      Option.getOptions().isProjectStarEnable = false

    it 'calls changed callback only 2 specified key.', (done) ->
      Option.getOptions().isProjectStarEnable = true
      Option.onChanged 'reportUsage', (e) ->
        expect(e).to.equals(false)
      Option.onChanged 'isProjectStarEnable', (e) ->
        expect(e).to.equals(false)
        done()
      o = Option.getOptions()
      o.reportUsage = false
      o.isProjectStarEnable = false

    it 'null check.', () ->
      Option.getOptions().reportUsage = false
      expect(Option.getOptions().reportUsage).to.equals(false)


  describe 'loadOptions()', ->

    it 'should load options, and returns options.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      # exec
      Option.loadOptions().then (options) ->
        expect(options.reportUsage).to.be.true
        done()

    it 'should returns merged options.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve({
          isProjectStarEnable: false  # not default value.
        })
        $rootScope.$apply()
      # exec
      Option.loadOptions().then (options) ->
        expect(options.reportUsage).to.be.true
        expect(options.isProjectStarEnable).to.be.false # should be `false`.
        done()

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      # exec
      Option.loadOptions().then () ->
        done(new Error())
      , () ->
        done()



  describe 'syncOptions()', ->

    it 'should sync options.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      # exec
      Option.syncOptions("prop").then (propName) ->
        expect(propName).to.equal("prop")
        done()

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      # exec
      Option.syncOptions().then () ->
        done(new Error())
      , () ->
        done()
