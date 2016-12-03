expect = chai.expect

describe 'chrome.coffee', ->

  Platform = null
  $rootScope = null
  $q = null


  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Platform_, _$rootScope_, _$q_) ->
      Platform = _Platform_
      $rootScope = _$rootScope_
      $q = _$q_


  describe 'load(key)', ->

    data = { test: true }
    stubLocal = null
    stubSync = null

    it 'returns data from chrome.storage.local.', (done) ->
      stubLocal = sinon.stub(chrome.storage.local, 'get')
      stubLocal.callsArgWith(1, data)

      Platform.load('test').then (res) ->
        expect(res).to.equal(data.test)
        done()
      , () ->
        done(new Error())
      setTimeout -> $rootScope.$apply()

    it 'returns data from chrome.storage.sync.', (done) ->
      stubLocal.callsArgWith(1, {})
      stubSync = sinon.stub(chrome.storage.sync, 'get')
      stubSync.callsArgWith(1, data)

      Platform.load('test').then (res) ->
        expect(res).to.equal(data.test)
        done()
      , () ->
        done(new Error())
      setTimeout -> $rootScope.$apply()

    it 'returns undefined, if data doesn\'t exists.', (done) ->
      stubSync.callsArgWith(1, {})

      Platform.load('test').then (res) ->
        expect(res).to.be.undefined
        done()
      , () ->
        done(new Error())
      setTimeout -> $rootScope.$apply()

    it 'rejects, if chrome.runtime has errors.', (done) ->
      chrome.runtime.lastError = true

      Platform.load('test').then () ->
        done(new Error())
      , () ->
        done()
      setTimeout ->
        chrome.runtime.lastError = null
        $rootScope.$apply()


  describe 'save(key, value)', ->

    it 'saves data to chrome.storage.', (done) ->
      sinon.stub(chrome.storage.local, 'set').callsArg(1)
      sinon.stub(chrome.storage.sync, 'set').callsArg(1)
      Platform.save('test', 'testdata').then () ->
        done()
      , () ->
        done(new Error())
      setTimeout -> $rootScope.$apply()

    it 'rejects, if chrome.runtime has errors.', (done) ->
      chrome.runtime.lastError = true

      Platform.save('test', 'testdata').then () ->
        done(new Error())
      , () ->
        done()

      setTimeout ->
        chrome.runtime.lastError = null
        $rootScope.$apply()


  describe 'saveLocal(key, value)', ->

    it 'saves data to chrome.storage.local.', (done) ->
      Platform.saveLocal('test', 'testdata').then () ->
        done()
      , () ->
        done(new Error())
      setTimeout -> $rootScope.$apply()

    it 'rejects, if chrome.runtime has errors.', (done) ->
      chrome.runtime.lastError = true

      Platform.saveLocal('test', 'testdata').then () ->
        done(new Error())
      , () ->
        done()

      setTimeout ->
        chrome.runtime.lastError = null
        $rootScope.$apply()


  describe 'getLanguage()', ->

    it 'returns en', () ->
      lang = Platform.getLanguage()
      expect(lang).to.equal('en')
