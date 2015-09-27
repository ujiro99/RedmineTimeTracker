expect = chai.expect

describe 'DataAdapter.coffee', ->

  DataAdapter = null
  TestData = null

  _auth = {
    url:  'http://demo.redmine.org'
    id:   'RedmineTimeTracker'
    pass: 'RedmineTimeTracker'
  }

  _props = [
    "Account"
    "Projects"
    "Tickets"
    "Activities"
    "Queries"
    "Statuses"
  ]

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_DataAdapter_, _TestData_) ->
      DataAdapter = _DataAdapter_
      TestData = _TestData_()

  ###
   test for loadTimeEntries(params)
  ###
  describe 'getter for DataModel properties', ->

    it 'should be binded.', () ->
      _props.map (p) ->
        method = "get" + p
        expect(DataAdapter[method]).exists

    it 'should be return _data[url]["statuses"] on account.', () ->
      DataAdapter.addAccounts([_auth])
      DataAdapter.setStatuses(_auth.url, TestData.statuses)
      statuses = DataAdapter.getStatuses(_auth.url)
      expect(statuses).to.have.length(TestData.statuses.length)
      for s, index in statuses
        expect(s).to.deep.equal(TestData.statuses[index])
