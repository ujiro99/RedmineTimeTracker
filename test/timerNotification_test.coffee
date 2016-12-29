expect = chai.expect

describe 'timerNotification.coffee', ->

  Platform = null
  PluginManager = null
  url = '../app/scripts/plugins/timerNotification.js'
  if not location.hostname.isBlank() # on karma
    url = './base/app/scripts/plugins/timerNotification.js'


  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Platform_, _PluginManager_) ->
      Platform = _Platform_
      PluginManager = _PluginManager_


  describe 'constructor', ->
    it 'create instance.', (done) ->
      sinon.stub(Platform.notifications, "addOnClickedListener").returns(undefined)

      PluginManager.loadPluginUrl(url, () ->
        plugin = PluginManager.listPlugins()["TimerNotification"]
        expect(plugin).to.be.ok
        done()
      )


  describe 'onSendedTimeEntry(RTT, timeEntry, status, ticket, mode)', ->

    timeEntry = {
      hours: 2.0
      activity: {
        name: 'test'
      }
    }
    ticket = { text: 'testTicket' }
    mode = 'pomodoro'
    name = "TimerNotification"


    it 'shows a notification: success.', (done) ->
      status = 200

      sinon.stub(Platform.notifications, "addOnClickedListener").returns(undefined)
      mock = sinon.mock(Platform.notifications).expects("create")
      mock.once().withArgs(null, {
        iconUrl: "/images/icon_notification.png",
        isClickable: true,
        items: [{ message: "testTicket", title: "Ticket" }, { message: "02:00", title: "Hours" }, { message: "test", title: "Activity" }],
        message: "Pomodoro finished.",
        title: "Tracking finished",
        type: "list"
      })

      PluginManager.loadPluginUrl(url, () ->
        expect(PluginManager.listPlugins()[name]).to.be.ok
        PluginManager.notify(PluginManager.events.SENDED_TIME_ENTRY, timeEntry, status, ticket, mode)
        mock.verify()
        done()
      )


    it 'shows a notification: failed.', (done) ->
      status = 400

      sinon.stub(Platform.notifications, "addOnClickedListener").returns(undefined)
      mock = sinon.mock(Platform.notifications).expects("create")
      mock.once().withArgs(null, {
        iconUrl: "/images/icon_notification.png",
        isClickable: true,
        items: [{ message: "testTicket", title: "Ticket" }, { message: "02:00", title: "Hours" }, { message: 400, title: "HTTP STATUS" }],
        message: "Pomodoro finished.",
        title: "Sending failed...",
        type: "list"
      })

      PluginManager.loadPluginUrl(url, () ->
        expect(PluginManager.listPlugins()[name]).to.be.ok
        PluginManager.notify(PluginManager.events.SENDED_TIME_ENTRY, timeEntry, status, ticket, mode)
        mock.verify()
        done()
      )
