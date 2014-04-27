expect = chai.expect

describe 'ticket.coffee', ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  Ticket = null
  Project = null
  Chrome = null
  TestData = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Ticket_, _Project_, _Chrome_, _TestData_) ->
      Ticket = _Ticket_
      Project = _Project_
      Chrome = _Chrome_
      TestData = _TestData_()


  it 'shoud have working Ticket service', () ->
    expect(Ticket.add).not.to.equal null


  ###
   test for get()
  ###
  describe 'get()', ->

    it 'be empty', () ->
      tickets = Ticket.get()
      expect(tickets).to.be.empty

    it 'should have 1 ticket', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      expect(Ticket.get()).to.not.be.empty


  describe 'getSelectable()', ->

    it 'be empty', () ->
      tickets = Ticket.getSelectable()
      expect(tickets).to.be.empty

    it 'should have 1 ticket', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      selectable = Ticket.getSelectable()
      expect(selectable).to.have.length(2)


  describe 'getSelected()', ->

    it 'be empty', () ->
      ticket = Ticket.getSelected()
      expect(ticket).to.be.empty

    it 'be empty, when added SHOW.NOT', () ->
      ticket = Ticket.getSelected()
      Project.set TestData.prjObj
      Ticket.add(
        id: 0
        text: "ticket0"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.NOT
      )
      expect(ticket[0]).to.be.empty

    it 'should select first ticket', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      selected = Ticket.getSelected()
      expect(selected[0].id).to.equal(0)

    it 'should not change selected ticket', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      Ticket.add(
        id: 3
        text: "ticket3"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.SHOW
      )
      selected = Ticket.getSelected()
      expect(selected[0].id).to.equal(0)


  describe 'set(ticketList)', ->

    it '1 project, 3 ticket.', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      tickets = Ticket.get()
      expect(tickets[0].id).to.equal(0) # SHOW.DEFAULT
      expect(tickets[1].id).to.equal(1) # SHOW.NOT
      expect(tickets[2].id).to.equal(2) # SHOW.SHOW
      selectable = Ticket.getSelectable()
      expect(selectable[0].id).to.equal(0)
      expect(selectable[1].id).to.equal(2)
      selected = Ticket.getSelected()
      expect(selected[0].id).to.equal(0)

    it 'clear old list.', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
      Ticket.set(TestData.ticketList)
      Ticket.set(TestData.ticketList2)
      tickets = Ticket.get()
      expect(tickets[0].url).to.equal("http://redmine.com")
      expect(tickets[1].url).to.equal("http://redmine.com2")
      expect(tickets[2].url).to.equal("http://redmine.com3")

    it 'error: 1 project not found.', () ->
      expect(Ticket.get()).to.be.empty
      Project.set(TestData.prjObj)
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
      Project.set(TestData.prjObj)
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
      Project.set(TestData.prjObj)
      Ticket.add(
        id: 0
        text: "ticket0"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.SHOW
      )
      ticket = Ticket.getSelected()
      expect(ticket[0].id).to.equal(0)
      Ticket.setParam(
        "http://redmine.com",
        0,
        show: SHOW.NOT
      )
      ticket = Ticket.getSelected()
      expect(ticket[0]).to.be.empty

    it 'SHOW.NOT to SHOW.SHOW', () ->
      Project.set(TestData.prjObj)
      Ticket.add(
        id: 0
        text: "ticket0"
        url: "http://redmine.com"
        project:
          id: 0
          text: "prj1_0"
        show: SHOW.NOT
      )
      ticket = Ticket.getSelected()
      expect(ticket).to.be.empty
      Ticket.setParam(
        "http://redmine.com",
        0,
        show: SHOW.SHOW
      )
      ticket = Ticket.getSelected()
      expect(ticket[0].id).to.equal(0)


  describe 'load(callback)', ->

    _setupChrome = () ->
      sinon.stub Chrome.storage.local, 'set', (arg1, callback) ->
        callback true
      sinon.stub Chrome.storage.local, 'get', (arg1, callback) ->
        if arg1 is "PROJECT"
          callback PROJECT: TestData.prjObj
          return true
        else
          callback TICKET: TestData.ticketOnChrome
          return true

    it 'callback called by chrome.', () ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      _setupChrome()
      # exec
      callback = sinon.spy()
      Ticket.load callback
      expect(callback.called).is.true

    it 'load data.', () ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      _setupChrome()
      # exec
      callback = sinon.spy (loaded, msg) ->
        expect(loaded[0].id).to.equal(TestData.ticketList2[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList2[0].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[1].url)
        expect(loaded[1].id).to.equal(TestData.ticketList2[2].id)
        expect(loaded[1].url).to.equal(TestData.ticketList2[2].url)
        expect(msg).to.be.empty
      Ticket.load callback
      expect(callback.called).is.true

    it 'error: project not found.', () ->
      expect(Ticket.get()).to.be.empty
      # put test data.
      sinon.stub Chrome.storage.local, 'set', (arg1, callback) ->
        callback true
      sinon.stub Chrome.storage.local, 'get', (arg1, callback) ->
        if arg1 is "PROJECT"
          callback PROJECT: TestData.prjObj
          return true
        else
          callback TICKET: TestData.ticketOnChrome.union [[ 0, "ticket4", 3, 0, SHOW.SHOW]]
          return true
      # exec
      callback = sinon.spy (loaded, msg) ->
        expect(loaded[0].id).to.equal(TestData.ticketList[0].id)
        expect(loaded[0].url).to.equal(TestData.ticketList[0].url)
        expect(loaded[2].id).to.equal(TestData.ticketList2[1].id)
        expect(loaded[2].url).to.equal(TestData.ticketList2[1].url)
        expect(msg.missing[0]).to.equal(3)
        console.log msg
      Ticket.load callback
      expect(callback.called).is.true
