expect = chai.expect

describe 'redmine.coffee', ->

  Redmine = null
  TestData = null
  $httpBackend = null

  _auth = {
    url:  'http://demo.redmine.org'
    id:   'RedmineTimeTracker'
    pass: 'RedmineTimeTracker'
  }

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_$httpBackend_, _Redmine_, _TestData_) ->
      Redmine = _Redmine_
      TestData = _TestData_()
      $httpBackend = _$httpBackend_


  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()


  it 'should have working Redmine service', () ->
    expect(Redmine.get).not.to.equal null


  ###
   test for get(auth)
  ###
  describe 'get(auth)', ->

    it '1', () ->
      auth = {
        url: 'http://github.com'
        id:  'test_id'
        pass: 'test_pass'
      }
      expect(Redmine.get(auth)).exists

    it '2', () ->
      auth1 = {
        url: 'http://github.com1'
        id:  'test_id'
        pass: 'test_pass'
      }
      auth2 = {
        url: 'http://github.com2'
        id:  'test_id'
        pass: 'test_pass'
      }
      expect(Redmine.get(auth1)).exists
      expect(Redmine.get(auth2)).exists


  ###
   test for remove(auth)
  ###
  describe 'remove(auth)', ->

    it 'remove account', () ->
      auth = {
        url: 'http://github.com'
        id:  'test_id'
        pass: 'test_pass'
      }
      expect(Redmine.get(auth)).exists
      Redmine.remove(auth)
      expect(Redmine.get(auth)).not.exists


  ###
   test for findUser(success, error)
  ###
  describe 'findUser(success, error)', ->

    it 'should load user', (done) ->
      $httpBackend
        .expectGET(_auth.url + '/users/current.json?include=memberships')
        .respond(TestData.user)
      success = (data) ->
        expect(data.user).to.exist
        done()
      error = () ->
        expect(false).to.be.true
        done()
      Redmine.get(_auth).findUser(success, error)
      $httpBackend.flush()


  ###
   test for loadQueries(params)
  ###
  describe 'loadQueries(params)', ->

    it 'should load queries', (done) ->
      $httpBackend
        .expectGET(_auth.url + '/queries.json?limit=25&page=0')
        .respond(TestData.queries)
      Redmine.get(_auth).loadQueries(page: 0, limit: 25).then(
        (data) -> expect(data.queries).to.exist; done()
      , () -> expect(false).to.be.true; done())
      $httpBackend.flush()


  ###
   test for loadTimeEntries(params)
  ###
  describe 'loadTimeEntries(params)', ->

    it 'should load time entries', (done) ->
      $httpBackend
        .expectGET(_auth.url + '/time_entries.json?limit=100')
        .respond(TestData.time_entries)
      Redmine.get(_auth).loadTimeEntries().then(
        (data) -> expect(data.time_entries).to.exist; done()
      , () -> expect(false).to.be.true; done())
      $httpBackend.flush()

