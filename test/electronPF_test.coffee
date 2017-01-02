expect = chai.expect

describe 'electronPF.js', ->

  Platform = null
  $rootScope = null
  $q = null
  stub = null

  before () ->
    sinon.stub(window, 'require')
      .withArgs('electron-json-storage').returns(storage)
      .withArgs('electron').returns(electron)

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_$rootScope_, _$q_) ->
      $rootScope = _$rootScope_
      $q = _$q_
    inj = angular.injector(['ng', 'electron'])
    Platform = inj.get('Platform')

  afterEach () ->
    stub and stub.restore()

  describe 'load(key)', ->

    data = { test: true }

    it 'returns data from storage.', (done) ->
      stub = sinon.stub(storage, 'get')
      stub.callsArgWith(1, null, data.test)

      Platform.load('test').then (res) ->
        expect(res).to.equal(data.test)
        done()
      , () ->
        done(new Error('Expect resolve, but rejected.'))
      setTimeout -> $rootScope.$apply()

    it 'returns undefined, if data doesn\'t exists.', (done) ->
      stub = sinon.stub(storage, 'get')
      stub.callsArgWith(1, null, undefined)

      Platform.load('test').then (res) ->
        expect(res).to.be.undefined
        done()
      , () ->
        done(new Error('Expect resolve, but rejected.'))
      setTimeout -> $rootScope.$apply()

    it 'rejects, if storage has errors.', (done) ->
      stub = sinon.stub(storage, 'get')
      stub.callsArgWith(1, "something error", null)

      Platform.load('test').then () ->
        done(new Error('Expect reject, but resolved.'))
      , () ->
        done()
      setTimeout -> $rootScope.$apply()


  describe 'save(key, value)', ->

    it 'saves data to storage.', (done) ->
      stub = sinon.stub(storage, 'set').callsArg(2)
      Platform.save('test', 'testdata').then () ->
        done()
      , () ->
        done(new Error('Expect resolve, but rejected.'))
      setTimeout -> $rootScope.$apply()

    it 'rejects, if storage has errors.', (done) ->
      stub = sinon.stub(storage, 'set').callsArgWith(2, "some error")
      Platform.save('test', 'testdata').then () ->
        done(new Error('Expect reject, but resolved.'))
      , () ->
        done()
      setTimeout -> $rootScope.$apply()


  describe 'clear()', ->

    it 'clears all data.', (done) ->
      stub = sinon.stub(storage, 'clear').callsArgWith(0, null)
      Platform.clear().then () ->
        done()
      , () ->
        done(new Error('Expect resolve, but rejected.'))
      setTimeout -> $rootScope.$apply()

    it 'rejects, if storage has errors.', (done) ->
      stub = sinon.stub(storage, 'clear').callsArgWith(0, "some error")
      Platform.clear().then () ->
        done(new Error('Expect reject, but resolved.'))
      , () ->
        done()
      setTimeout -> $rootScope.$apply()


  describe 'getLanguage()', ->

    it 'returns en', () ->
      lang = Platform.getLanguage()
      expect(lang).to.equal('en')


  describe 'showAppWindow()', ->

    it 'calls show() on AppWindow.', () ->
      Platform.showAppWindow()


  describe 'Notification', ->

    it 'calls Notification.create(options).', () ->
      mock = sinon.mock(window)
      mock.expects('Notification').once()
      Platform.createNotification({
        icon: "/images/icon_notification.png",
        items: [{ message: "testTicket", title: "Ticket" }, { message: "02:00", title: "Hours" }, { message: 400, title: "HTTP STATUS" }],
        title: "Sending failed...",
      })
      mock.verify()

    it 'calls Notification.close().', () ->
      notify = { close: () -> }
      stub = sinon.stub(window, 'Notification').returns(notify)
      spy = sinon.spy(notify, "close")
      Platform.createNotification({ items: [] })
      Platform.clearNotification()
      expect(spy.called).to.be.true

    it 'doesn\'t calls Notification.close(), if notification doesn\'t exists.', () ->
      notify = { close: () -> }
      stub = sinon.stub(window, 'Notification').returns(notify)
      spy = sinon.spy(notify, "close")
      Platform.clearNotification()
      expect(spy.called).to.be.false

    it 'uses Notification.onclick.', () ->
      spy = sinon.spy(()->)
      notify = {
        onclick: () ->
      }
      stub = sinon.stub(window, 'Notification').returns(notify)
      Platform.createNotification({ items: [] })
      Platform.addOnClickedListener(spy)
      notify.onclick()
      expect(spy.called).to.be.true

    it 'doesn\'t uses Notification.onclick.', () ->
      spy = sinon.spy(()->)
      notify = {
        onclick: () ->
      }
      stub = sinon.stub(window, 'Notification').returns(notify)
      Platform.addOnClickedListener(spy)
      notify.onclick()
      expect(spy.called).to.be.false

