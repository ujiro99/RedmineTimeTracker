expect = chai.expect

describe 'account.coffee', ->

  Account = null

  _auth = {
    url:  'http://demo.redmine.org'
    id:   'RedmineTimeTracker'
    pass: 'RedmineTimeTracker'
  }

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Account_) ->
      Account = _Account_

  ###
   test for isValid()
  ###
  describe 'AccountModel.isValid()', ->

    it 'should return true', () ->
      auth = {
        url: 'http://github.com'
        id:  'test_id'
        pass: 'test_pass'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.true

    it 'should return true', () ->
      auth = {
        url: 'http://github.com'
        apiKey: 'api key'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.true

    it 'should return false if url missing.', () ->
      auth = {
        # url: 'http://github.com'
        apiKey: 'api key'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.false

    it 'should return false if apiKey is missing.', () ->
      auth = {
        url: 'http://github.com'
        # apiKey: 'api key'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.false

    it 'should return false if id is missing', () ->
      auth = {
        url: 'http://github.com'
        # id:  'test_id'
        pass: 'test_pass'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.false

    it 'should return false if password is missing', () ->
      auth = {
        url: 'http://github.com'
        id:  'test_id'
        # pass: 'test_pass'
      }
      model = Account.create(auth)
      expect(model.isValid()).to.be.false
