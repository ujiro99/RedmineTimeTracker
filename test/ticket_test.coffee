expect = chai.expect

describe 'ticket.coffee', ->

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4
  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  Ticket = null
  Chrome = null
  TestData = null
  $rootScope = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Ticket_, _Chrome_, _TestData_, _$rootScope_) ->
      Ticket = _Ticket_
      Chrome = _Chrome_
      TestData = _TestData_()
      $rootScope = _$rootScope_


  it 'shoud have working Ticket service', () ->
    expect(Ticket.load).not.to.equal null


  describe 'sync(ticketList)', ->

    _setUpChrome = ->
      Chrome.storage.local.get = (arg, callback) ->
        setTimeout () ->
          callback PROJECT: TestData.prjObj
          $rootScope.$apply()


    it 'sould sync 1 project, 3 ticket.', (done) ->
      _setUpChrome()

      Chrome.storage.sync.set = (arg, callback) ->
        obj = arg.TICKET
        expect(obj[0][TICKET_SHOW]).to.equal(SHOW.DEFAULT)
        expect(obj[1][TICKET_SHOW]).to.equal(SHOW.NOT)
        expect(obj[2][TICKET_SHOW]).to.equal(SHOW.SHOW)
        done()

      #exec
      Ticket.sync(TestData.ticketList)


    it 'shuld return error message of Chrome.', (done) ->
      _setUpChrome()
      Chrome.storage.sync.set = (arg, callback) ->
        Chrome.runtime.lastError = true
        callback()
      #exec
      Ticket.sync(TestData.ticketList)
        .then((msg)->
          expect(true).to.be.false #failed.
        , (msg)->
          expect(msg.message).to.be.exists
          done()
        )


    it 'should clear old list.', (done) ->
      _setUpChrome()

      # sync old data.
      Chrome.storage.sync.set = (arg, callback) -> callback()
      Ticket.sync(TestData.ticketList).then ->

        Chrome.storage.sync.set = (arg, callback) ->
          obj = arg.TICKET
          expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
          expect(obj[1][TICKET_URL_INDEX]).to.equal(1)
          expect(obj[2][TICKET_URL_INDEX]).to.equal(2)
          done()

        # sync new data.
        Ticket.sync(TestData.ticketList2)


    it 'should return a missing ticket if 1 project not found.', (done) ->
      _setUpChrome()
      tickets = [
        {
          id: 0,
          text: "ticket0",
          url: "http://redmine.com",
          project:
            id: 0
            text: "prj1_0",
          show: SHOW.DEFAULT
        }, {
          id: 0,
          text: "ticket1",
          url: "http://redmine.com4",
          project:
            id: 0
            text: "prj1_0",
          show: SHOW.NOT
        }
      ]

      Chrome.storage.sync.set = (arg, callback) ->
        setTimeout ->
          obj = arg.TICKET
          expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
          expect(obj[1][TICKET_URL_INDEX]).to.not.equal(3)
          callback()
          $rootScope.$apply()

      Ticket.sync(tickets).then((msg) ->
        expect(msg.message).to.not.be.empty
        expect(msg.missing).to.have.length(1)
        done())


    it 'should retrun missing tickets if 2 projects not found.', (done) ->
      _setUpChrome()
      tickets = [
        {
          id: 0,
          text: "ticket0",
          url: "http://redmine.com",
          project:
            id: 0
            text: "prj1_0",
          show: SHOW.DEFAULT
        }, {
          id: 0,
          text: "ticket1",
          url: "http://redmine.com4",
          project:
            id: 0
            text: "prj1_0",
          show: SHOW.NOT
        }, {
          id: 2,
          text: "ticket1",
          url: "http://redmine.com5",
          project:
            id: 0
            text: "prj1_0",
          show: SHOW.NOT
        }
      ]
      Chrome.storage.sync.set = (arg, callback) ->
        setTimeout ->
          obj = arg.TICKET
          expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
          expect(obj[1][TICKET_URL_INDEX]).to.not.equal(3)
          expect(obj[2][TICKET_URL_INDEX]).to.equal(-1)
          callback()
          $rootScope.$apply()

      Ticket.sync(tickets).then((msg) ->
        expect(msg.message).to.not.be.empty
        expect(msg.missing).to.have.length(2)
        done())


  describe 'load()', ->

    _setUpChrome = () ->
      Chrome.storage.local.get = (arg, callback) ->
        setTimeout () ->
          if arg is "TICKET"
            callback TICKET: TestData.ticketOnChrome
          else if arg is "PROJECT"
            callback PROJECT: TestData.prjObj
          $rootScope.$apply()


    it 'should return 3 tickets', (done) ->
      _setUpChrome()
      Ticket.load().then (tickets) ->
        expect(tickets).to.have.length(3)
        expect(tickets[0].text).to.be.equals("ticket0")
        expect(tickets[1].show).to.be.equals(SHOW.NOT)
        expect(tickets[2].url).to.be.equals("http://redmine.com3")
        done()


    it 'should be empty.', (done) ->
      # setup chrome
      getData = (arg, callback) ->
        setTimeout () ->
          if arg is "TICKET"
            callback TICKET: null
          else if arg is "PROJECT"
            callback PROJECT: TestData.prjObj
          else
            callback null
          $rootScope.$apply()
      Chrome.storage.local.get = getData
      Chrome.storage.sync.get = getData

      # exec
      Ticket.load().then (tickets) ->
        expect(tickets).to.be.empty
        done()


    it 'error: project not found.', (done) ->
      # put test data.
      Chrome.storage.local.get = (arg, callback) ->
        setTimeout () ->
          if arg is "TICKET"
            callback TICKET: TestData.ticketOnChrome.add [[ 0, "ticket4", 3, 0, SHOW.SHOW]]
          else if arg is "PROJECT"
            callback PROJECT: TestData.prjObj
          $rootScope.$apply()
      # exec
      Ticket.load().then (loaded, msg) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded.missing[0]).to.equal(3)
        done()


    it 'compatibility (version <= 0.5.7): index start changed.', (done) ->
      # put test data.
      Chrome.storage.local.get = (arg1, callback) ->
        setTimeout () ->
          if arg1 is "PROJECT"
            callback PROJECT: TestData.prjOldFormat
          else
            callback TICKET: TestData.ticketOnChromeOld
          $rootScope.$apply()
      # exec
      Ticket.load().then (loaded) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[2].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[2].url)
        expect(loaded.missing).to.have.length(0)
        done()

