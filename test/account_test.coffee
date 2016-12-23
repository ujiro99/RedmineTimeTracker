expect = chai.expect

describe 'account.coffee', ->

  Account = null
  $rootScope = null
  $q = null
  Platform = null

  _auth = {
    url:  'http://demo.redmine.org'
    id:   'id_RedmineTimeTracker'
    pass: 'pass_RedmineTimeTracker'
  }

  beforeEach () ->
    angular.mock.module('timeTracker')
    # initialize object
    inject (_Account_, _$rootScope_, _$q_, _Platform_) ->
      Account = _Account_
      $rootScope = _$rootScope_
      $q = _$q_
      Platform = _Platform_

  ###
   test for isValid()
  ###
  describe 'create(param)', ->

    it 'should return AccountModel which has name.', () ->
      param = {
        url:         'http://github.com'
        id:          'test_id'
        apiKey:      'test_apiKey'
        pass:        'test_pass'
        name:        'test_name'
        numProjects: 1
        projectList: '1,2,5,8,11'
      }
      model = Account.create(param)
      expect(model.url).to.equal(param.url)
      expect(model.id).to.equal(param.id)
      expect(model.apiKey).to.equal(param.apiKey)
      expect(model.pass).to.equal(param.pass)
      expect(model.name).to.equal(param.name)
      expect(model.numProjects).to.equal(param.numProjects)
      expect(model.projectList).to.eql([1,2,5,8,11])

    it 'should return AccountModel which doesn\'t has name.', () ->
      param = {
        url:         'http://github.com'
        id:          'test_id'
        apiKey:      'test_apiKey'
        pass:        'test_pass'
        numProjects: 1
        projectList: '1,2,5,8,11'
      }
      model = Account.create(param)
      expect(model.url).to.equal(param.url)
      expect(model.id).to.equal(param.id)
      expect(model.apiKey).to.equal(param.apiKey)
      expect(model.pass).to.equal(param.pass)
      expect(model.name).to.equal(param.url)
      expect(model.numProjects).to.equal(param.numProjects)
      expect(model.projectList).to.eql([1,2,5,8,11])


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

    # Range is not support.
    # it 'should return [[1-3]]', () ->
    #   str = "1-3"
    #   model = Account.create(_auth)
    #   parsed = model.parseProjectList(str)
    #   expect(parsed).to.eql([[1,3]])

    # it 'should return [1, [3-5], 10]', () ->
    #   str = "1, 3-5, 10"
    #   model = Account.create(_auth)
    #   parsed = model.parseProjectList(str)
    #   expect(parsed).to.eql([1, [3, 5], 10])

    # it 'should return [[1-3], [100-102]]', () ->
    #   str = "1-3, 100-102"
    #   model = Account.create(_auth)
    #   parsed = model.parseProjectList(str)
    #   expect(parsed).to.eql([[1, 3], [100, 102]])

    it 'should return null', () ->
      str = null
      model = Account.create(_auth)
      parsed = model.parseProjectList(str)
      expect(parsed).to.be.null


  ###
   test for load()
  ###
  describe 'load', ->

    it 'should not returns accounts.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      # exec
      Account.load().then (accounts) ->
        expect(accounts).to.be.empty
        done()


    it 'should returns a account.', (done) ->
      auth = {
        url:  'http://demo.redmine.org'
        id:   'id_RedmineTimeTracker'
        pass: 'pass_RedmineTimeTracker'
        apiKey: 'apiKey_RedmineTimeTracker'
      }
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        obj = Account.create(auth).encrypt()
        deferred.resolve([obj])
        $rootScope.$apply()
      # exec
      Account.load().then (accounts) ->
        expect(accounts[0].id).to.equal(auth.id)
        expect(accounts[0].apiKey).to.equal(auth.apiKey)
        expect(accounts[0].pass).to.equal(auth.pass)
        done()


    it 'should returns two accounts.', (done) ->
      auth1 = {
        url:  'http://demo.redmine.org1'
        id:   'id_RedmineTimeTracker1'
        pass: 'pass_RedmineTimeTracker1'
      }
      auth2 = {
        url:  'http://demo.redmine.org2'
        id:   'id_RedmineTimeTracker2'
        pass: 'pass_RedmineTimeTracker2'
      }
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        obj1 = Account.create(auth1).encrypt()
        obj2 = Account.create(auth2).encrypt()
        deferred.resolve([obj1, obj2])
        $rootScope.$apply()
      # exec
      Account.load().then (accounts) ->
        expect(accounts[0].id).to.equal(auth1.id)
        expect(accounts[0].pass).to.equal(auth1.pass)
        expect(accounts[1].id).to.equal(auth2.id)
        expect(accounts[1].pass).to.equal(auth2.pass)
        done()


    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "load").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      Account.load().then () ->
        done(new Error())
      , () ->
        done()


  ###*
   test for addAccount(account)
  ###
  describe 'addAccount(account)', ->

    it 'should save a account.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      auth = {
        url:  'http://demo.redmine.org'
        id:   'id_RedmineTimeTracker'
        pass: 'pass_RedmineTimeTracker'
        apiKey: 'apiKey_RedmineTimeTracker'
      }
      # exec
      Account.addAccount(auth).then (res) ->
        expect(res.url).to.equal(auth.url)
        expect(res.id).to.equal(auth.id)
        expect(res.apiKey).to.equal(auth.apiKey)
        expect(res.pass).to.equal(auth.pass)
        done()


    it 'should overwrite a account to same url account.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      auths = [{
        url:  'http://demo.redmine.org1'
        id:   'id_RedmineTimeTracker1'
        pass: 'pass_RedmineTimeTracker1'
      }, {
        url:  'http://demo.redmine.org2'
        id:   'id_RedmineTimeTracker2b'
        pass: 'pass_RedmineTimeTracker2b'
      }]
      auth2 = {
        url:  'http://demo.redmine.org2'
        id:   'id_RedmineTimeTracker2'
        pass: 'pass_RedmineTimeTracker2'
      }
      # exec
      d = $q.defer()
      d.promise
      .then(-> Account.addAccount(auth2))
      .then(-> Account.addAccount(auths[0]))
      .then(-> Account.addAccount(auths[1]))
      .then (res) ->
        expect(res.url).to.equal(auths[1].url)
        expect(res.id).to.equal(auths[1].id)
        expect(res.pass).to.equal(auths[1].pass)
        accounts = Account.getAccounts()
        for a, i in auths
          data = accounts[i]
          expect(data.url).to.equal(a.url)
          expect(data.id).to.equal(a.id)
          expect(data.pass).to.equal(a.pass)
        done()
      d.resolve()

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      auth = {
        url:  'http://demo.redmine.org'
        id:   'id_RedmineTimeTracker'
        pass: 'pass_RedmineTimeTracker'
        apiKey: 'apiKey_RedmineTimeTracker'
      }
      # exec
      Account.addAccount(auth).then () ->
        done(new Error())
      , () ->
        done()


  ###*
   test for removeAccount(url)
  ###
  describe 'removeAccount(url)', ->

    it 'should remove a account.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      auths = [{
        url:  'http://demo.redmine.org1'
        id:   'id_RedmineTimeTracker1'
        pass: 'pass_RedmineTimeTracker1'
      }, {
        url:  'http://demo.redmine.org2'
        id:   'id_RedmineTimeTracker2'
        pass: 'pass_RedmineTimeTracker2'
      }]
      # exec
      d = $q.defer()
      d.promise
      .then(-> Account.addAccount(auths[0]))
      .then(-> Account.addAccount(auths[1]))
      .then(-> Account.removeAccount('http://demo.redmine.org1'))
      .then ->
        accounts = Account.getAccounts()
        expect(accounts).to.have.lengthOf(1)
        expect(accounts[0].url).to.equal(auths[1].url)
        expect(accounts[0].id).to.equal(auths[1].id)
        expect(accounts[0].pass).to.equal(auths[1].pass)
        done()
      d.resolve()

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      auth = {
        url:  'http://demo.redmine.org'
        id:   'id_RedmineTimeTracker'
        pass: 'pass_RedmineTimeTracker'
        apiKey: 'apiKey_RedmineTimeTracker'
      }
      # exec
      Account.addAccount(auth)
      .then(-> Account.removeAccount('pass_RedmineTimeTracker2'))
      .then () ->
        done(new Error())
      , () ->
        done()


  ###*
   test for clearAccount()
  ###
  describe 'clearAccount()', ->

    it 'should remove all account.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.resolve()
        $rootScope.$apply()
      auths = [{
        url:  'http://demo.redmine.org1'
        id:   'id_RedmineTimeTracker1'
        pass: 'pass_RedmineTimeTracker1'
      }, {
        url:  'http://demo.redmine.org2'
        id:   'id_RedmineTimeTracker2'
        pass: 'pass_RedmineTimeTracker2'
      }]
      # exec
      d = $q.defer()
      d.promise
      .then(-> Account.addAccount(auths[0]))
      .then(-> Account.addAccount(auths[1]))
      .then(-> Account.clearAccount())
      .then ->
        accounts = Account.getAccounts()
        expect(accounts).to.have.lengthOf(0)
        done()
      d.resolve()

    it 'should reject if Platform has anything error.', (done) ->
      deferred = $q.defer()
      sinon.stub(Platform, "save").returns(deferred.promise)
      setTimeout () ->
        deferred.reject()
        $rootScope.$apply()
      # exec
      Account.clearAccount().then () ->
        done(new Error())
      , () ->
        done()
