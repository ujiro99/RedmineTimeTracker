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


  describe 'AccountModel.parseProjectList()', ->

    _auth = {
      url: 'http://github.com'
      apiKey: 'api key'
    }

    it 'should return [1, 2, 3]', () ->
      str = "1, 2, 3"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([1,2,3])

    it 'should return [1]', () ->
      str = "1"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([1])

    it 'should return [100000000000000000]', () ->
      str = "100000000000000000"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([100000000000000000])

    it 'should return [[1-3]]', () ->
      str = "1-3"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([[1,3]])

    it 'should return [1, [3-5], 10]', () ->
      str = "1, 3-5, 10"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([1, [3, 5], 10])

    it 'should return [[1-3], [100-102]]', () ->
      str = "1-3, 100-102"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([[1, 3], [100, 102]])

    it 'should return []', () ->
      str = "-1"
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.eql([])

    it 'should return null', () ->
      str = null
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.be.null
