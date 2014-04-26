expect = chai.expect

describe 'ticket.coffee', ->

  Ticket = null
  Project = null
  Chrome = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Ticket_, _Project_, _Chrome_) ->
      Ticket = _Ticket_


  it 'shoud have working Ticket service', () ->
    expect(Ticket.add).not.to.equal null


  ###
   test for get()
  ###
  describe 'get()', ->

    it 'be empty', () ->
      tickets = Ticket.get()
      expect(tickets).to.be.empty

    it 'should be have 1 ticket', () ->
      expect(Ticket.get()).to.be.empty

