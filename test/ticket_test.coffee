expect = chai.expect

describe 'ticket.coffee', ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  Ticket = null
  Project = null
  Chrome = null
  TestData = null

  ticketList = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Ticket_, _Project_, _Chrome_, _TestData_) ->
      Ticket = _Ticket_
      Project = _Project_
      Chrome = _Chrome_
      TestData = _TestData_()
      ticketList = TestData.ticketList


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
      Ticket.set(ticketList)
      expect(Ticket.get()).to.not.be.empty


  describe 'getSelectable()', ->

    it 'be empty', () ->
      tickets = Ticket.getSelectable()
      expect(tickets).to.be.empty

    it 'should have 1 ticket', () ->
      expect(Ticket.get()).to.be.empty
      Ticket.set(ticketList)
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

