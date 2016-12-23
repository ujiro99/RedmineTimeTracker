expect = chai.expect

describe 'ticket.coffee', ->

  TICKET = "TICKET"
  PROJECT = "PROJECT"
  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4
  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  Ticket = null
  Platform = null
  TestData = null
  $rootScope = null
  $q = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Ticket_, _Platform_, _TestData_, _$rootScope_, _$q_) ->
      Ticket = _Ticket_
      Platform = _Platform_
      TestData = _TestData_()
      $rootScope = _$rootScope_
      $q = _$q_


  it 'should have working Ticket service', () ->
    expect(Ticket.load).not.to.equal null


  describe 'sync(ticketList)', ->

    getStubPlatformSave = ->
      deferred = $q.defer()
      stub = sinon.stub(Platform, "save")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve({})
        $rootScope.$apply()
      return stub

    getStubPlatformLoad = ->
      deferred = $q.defer()
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(TestData.prjObj)
        $rootScope.$apply()
      return stub


    it 'should sync 1 project, 3 ticket.', (done) ->
      stub = getStubPlatformSave()
      getStubPlatformLoad()

      #exec
      Ticket.sync(TestData.ticketList).then ->
        obj = stub.args[0][1]
        expect(obj[0][TICKET_SHOW]).to.equal(SHOW.DEFAULT)
        expect(obj[1][TICKET_SHOW]).to.equal(SHOW.NOT)
        expect(obj[2][TICKET_SHOW]).to.equal(SHOW.SHOW)
        done()


    it 'should return error message if projects not found.', (done) ->
      deferred = $q.defer()
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()

      #exec
      Ticket.sync(TestData.ticketList)
        .then(()->
          expect(true).to.be.false # failed.
          done()
        , (msg)->
          expect(msg.message).to.equal("Couldn't sync with project.")
          done())


    it 'should return error message if failed to sync.', (done) ->
      deferred = $q.defer()
      stub = sinon.stub(Platform, "save")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      getStubPlatformLoad()

      #exec
      Ticket.sync(TestData.ticketList)
      .then(()->
        expect(true).to.be.false # failed.
        done()
      , (msg)->
        expect(msg.message).to.equal("Couldn't save tickets.")
        done())


    it 'should clear old list.', (done) ->
      stub = getStubPlatformSave()
      getStubPlatformLoad()

      # sync old data.
      Ticket.sync(TestData.ticketList).then ->
        # sync new data.
        Ticket.sync(TestData.ticketList2).then ->
          obj = stub.args[1][1]
          expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
          expect(obj[1][TICKET_URL_INDEX]).to.equal(1)
          expect(obj[2][TICKET_URL_INDEX]).to.equal(2)
          done()


    it 'should return a missing ticket if 1 project not found.', (done) ->
      stub = getStubPlatformSave()
      getStubPlatformLoad()

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

      Ticket.sync(tickets).then((msg) ->
        obj = stub.args[0][1]
        expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
        expect(obj[1][TICKET_URL_INDEX]).to.not.equal(3)
        expect(msg.message).to.not.be.empty
        expect(msg.missing).to.have.length(1)
        done())


    it 'should return missing tickets if 2 projects not found.', (done) ->
      stub = getStubPlatformSave()
      getStubPlatformLoad()

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

      Ticket.sync(tickets).then((msg) ->
        obj = stub.args[0][1]
        expect(obj[0][TICKET_URL_INDEX]).to.equal(0)
        expect(obj[1][TICKET_URL_INDEX]).to.not.equal(3)
        expect(obj[2][TICKET_URL_INDEX]).to.equal(-1)
        expect(msg.message).to.not.be.empty
        expect(msg.missing).to.have.length(2)
        done())


  describe 'load()', ->

    _setUpPlatform = (ticket, project) ->
      d1 = $q.defer()
      d2 = $q.defer()
      stub = sinon.stub(Platform, "load")
      stub.withArgs(TICKET).returns(d1.promise)
      stub.withArgs(PROJECT).returns(d2.promise)
      setTimeout () ->
        d1.resolve(ticket)
        d2.resolve(project)
        $rootScope.$apply()


    it 'should return 3 tickets', (done) ->
      _setUpPlatform(TestData.ticketOnChrome, TestData.prjObj)
      Ticket.load().then (obj) ->
        tickets = obj.tickets
        expect(tickets).to.have.length(3)
        expect(tickets[0].text).to.be.equals("ticket0")
        expect(tickets[1].show).to.be.equals(SHOW.NOT)
        expect(tickets[2].url).to.be.equals("http://redmine.com3")
        done()


    it 'should return empty array, if tickets are null.', (done) ->
      # setup data
      _setUpPlatform(null, TestData.prjObj)
      # exec
      Ticket.load().then (obj) ->
        expect(obj.tickets).to.be.empty
        done()


    it 'should return missing array, if projects are null.', (done) ->
      # setup data
      _setUpPlatform(TestData.ticketOnChrome, null)
      # exec
      Ticket.load().then (obj) ->
        expect(obj.tickets).to.be.empty
        expect(obj.missing).to.have.lengthOf(3)
        done()


    it 'error: if project not found, returns missing tickets.', (done) ->
      # put test data.
      _setUpPlatform(
        TestData.ticketOnChrome.add([[ 0, "ticket4", 3, 0, SHOW.SHOW]]),
        TestData.prjObj
      )
      # exec
      Ticket.load().then (obj) ->
        loaded = obj.tickets
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(obj.missing[0]).to.equal(3)
        done()


    it 'error: should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      # exec
      Ticket.load().then () ->
        done(new Error())
      , (obj) ->
        expect(obj).to.be.null
        done()


    it 'compatibility (version <= 0.5.7): index start changed.', (done) ->
      # put test data.
      _setUpPlatform(
        TestData.ticketOnChromeOld,
        TestData.prjOldFormat
      )
      # exec
      Ticket.load().then (obj) ->
        loaded = obj.tickets
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[2].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[2].url)
        expect(obj.missing).to.have.length(0)
        done()


  describe 'clear()', ->

    it 'should delete all tickets.', (done) ->
      deferred = $q.defer()
      stub = sinon.stub(Platform, "save")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(TestData.prjObj)
        $rootScope.$apply()
      # exec
      Ticket.clear().then () ->
        done()
      , () ->
        done(new Error())

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      # exec
      Ticket.clear().then () ->
        done(new Error())
      , () ->
        done()
