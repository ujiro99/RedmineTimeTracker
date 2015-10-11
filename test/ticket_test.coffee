expect = chai.expect

describe 'ticket.coffee', ->

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
    expect(Ticket.add).not.to.equal null


  _setUpProject = ->
    Chrome.storage.local.get = (arg, callback) ->
      setTimeout () ->
        callback PROJECT: TestData.prjObj
        $rootScope.$apply()


  ###
   test for get()
  ###
  describe 'get()', ->

    it 'be empty', () ->
      tickets = Ticket.get()
      expect(tickets).to.be.empty

    it 'should have 1 ticket', () ->
      expect(Ticket.get()).to.be.empty
      _setUpProject()
      Ticket.set(TestData.ticketList)
      expect(Ticket.get()).to.not.be.empty


  describe 'set(ticketList)', ->

    it '1 project, 3 ticket.', () ->
      expect(Ticket.get()).to.be.empty
      _setUpProject()
      Ticket.set(TestData.ticketList)
      tickets = Ticket.get()
      expect(tickets[0].id).to.equal(0) # SHOW.DEFAULT
      expect(tickets[1].id).to.equal(1) # SHOW.NOT
      expect(tickets[2].id).to.equal(2) # SHOW.SHOW

    it 'clear old list.', () ->
      expect(Ticket.get()).to.be.empty
      _setUpProject()
      Ticket.set(TestData.ticketList)
      Ticket.set(TestData.ticketList2)
      tickets = Ticket.get()
      expect(tickets[0].url).to.equal("http://redmine.com")
      expect(tickets[1].url).to.equal("http://redmine.com2")
      expect(tickets[2].url).to.equal("http://redmine.com3")

    it 'error: 1 project not found.', () ->
      expect(Ticket.get()).to.be.empty
      _setUpProject()
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
      Ticket.set(tickets, (res, msg) ->
        tickets = Ticket.get()
        expect(tickets[0].url).to.equal("http://redmine.com")
        expect(tickets[1].url).to.not.equal("http://redmine.com4")
        expect(res).to.be.false
        expect(msg.message).to.not.be.empty
        expect(msg.param).to.have.length(1)
      )

    it 'error: 2 project not found.', () ->
      expect(Ticket.get()).to.be.empty
      _setUpProject()
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
      Ticket.set(tickets, (res, msg) ->
        tickets = Ticket.get()
        expect(tickets[0].url).to.equal("http://redmine.com")
        expect(tickets[1].url).to.not.equal("http://redmine.com4")
        expect(res).to.be.false
        expect(msg.message).to.not.be.empty
        expect(msg.param).to.have.length(2)
      )

  describe 'setParam(url, id, param)', ->

    it 'SHOW.SHOW to SHOW.NOT', () ->
      _setUpProject()
      Ticket.add(
        id: 0
        text: "ticket0"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.SHOW
      )

    it 'SHOW.NOT to SHOW.SHOW', () ->
      _setUpProject()
      Ticket.add(
        id: 0
        text: "ticket0"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.NOT
      )


  describe 'load(callback)', ->

    _setupChrome = () ->
      Chrome.storage.local.set = (arg, callback) ->
        callback true
      Chrome.storage.local.get = (arg, callback) ->
        setTimeout () ->
          if arg is "TICKET"
            callback TICKET: TestData.ticketOnChrome
          else if arg is "PROJECT"
            callback PROJECT: TestData.prjObj
          $rootScope.$apply()

    it 'callback called by chrome.', (done) ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      _setupChrome()
      # exec
      Ticket.load (tickets) ->
        expect(true).is.true
        done()

    it 'load data.', (done) ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      _setupChrome()
      # exec
      callback = (loaded, msg) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[2].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[2].url)
        expect(msg).to.be.empty
        done()
      Ticket.load callback

    it 'error: project not found.', (done) ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      Chrome.storage.local.set = (arg, callback) ->
        callback true
      Chrome.storage.local.get = (arg, callback) ->
        setTimeout () ->
          if arg is "TICKET"
            callback TICKET: TestData.ticketOnChrome.add [[ 0, "ticket4", 3, 0, SHOW.SHOW]]
          else if arg is "PROJECT"
            callback PROJECT: TestData.prjObj
          $rootScope.$apply()
      # exec
      callback = (loaded, msg) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(msg.missing[0]).to.equal(3)
        done()
      Ticket.load callback

    it 'compatibility (version <= 0.5.7): index start changed.', () ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      sinon.stub Chrome.storage.local, 'set', (arg1, callback) ->
        callback true
      sinon.stub Chrome.storage.local, 'get', (arg1, callback) ->
        if arg1 is "PROJECT"
          callback PROJECT: TestData.prjOldFormat
          return true
        else
          callback TICKET: TestData.ticketOnChromeOld
          return true
      # exec
      Ticket.load (loaded) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[2].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[2].url)

