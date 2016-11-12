expect = chai.expect

describe 'project.coffee', ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $rootScope = null
  deferred = null
  Project = null
  Platform = null
  TestData = null

  prjObj = null
  prj1 = null
  prj2 = null
  prj3 = null


  beforeEach () ->
    angular.mock.module('timeTracker')
    # underscores are a trick for resolving references.
    inject (_Project_, _Platform_, _TestData_, _$rootScope_, _$q_) ->
      $rootScope = _$rootScope_
      deferred = _$q_.defer()
      Project = _Project_
      Platform = _Platform_
      TestData = _TestData_()
      prjObj = TestData.prjObj
      prj1 = TestData.prj1.map (p) -> Project.create(p)
      prj2 = TestData.prj2.map (p) -> Project.create(p)
      prj3 = TestData.prj3.map (p) -> Project.create(p)


  it 'shoud have working Project service', (done) ->
    stub = sinon.stub(Platform, "load")
    stub.returns(deferred.promise)
    setTimeout () ->
      deferred.resolve({})
      $rootScope.$apply() # promises are resolved/dispatched only on next $digest cycle
    Project.load()
      .then (projects) ->
        expect(projects).to.be.empty
        done()

  ###
     class Project
       _load: (storage, callback) ->
       _sync: (projects, storage, callback) ->
       _toChromeObjects: (projects) ->
       _toProjectModels: (projects) ->
       load: () ->
       sync: (projects) ->
       syncLocal: (projects) ->
       create: (params) ->
  ###


  ###
   test for load()
  ###
  describe 'load()', ->

    it 'loads data.', (done) ->
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(prjObj)
        $rootScope.$apply()
      # exec test.
      Project.load().then (projects) ->
        expect(projects[0].equals(prj1[0])).to.be.true
        expect(projects[1].equals(prj2[0])).to.be.true
        expect(projects[2].equals(prj3[0])).to.be.true
        done()

    it 'initialize result to empty array, if data does not exists.', (done) ->
      # put test data.
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(null)
        $rootScope.$apply()
      # exec test.
      Project.load().then (projects) ->
        expect(projects).to.be.empty
        done()
      , (projects) ->
        expect(true).to.be.false # fail!
        done()

    it 'calls error callback, if data does not exists.', (done) ->
      # put test data.
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.reject(null)
        $rootScope.$apply()

      # exec test.
      Project.load()
        .then (projects) ->
          expect(true).to.be.false # fail!
          done()
        , (projects) ->
          expect(projects).to.be.null
          done()

    it 'compatibility (version <= 0.5.7): index start changed.', (done) ->
      # put test data.
      # this data is old format (version <= 0.5.7).
      stub = sinon.stub(Platform, "load")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(TestData.prjOldFormat)
        $rootScope.$apply()

      Project.load().then (projects) ->
        expect(projects[0].equals(prj1[0])).to.be.true
        expect(projects[1].equals(prj2[0])).to.be.true
        expect(projects[2].equals(prj3[0])).to.be.true
        done()


  getStubPlatformSave = ->
    stub = sinon.stub(Platform, "save")
    stub.returns(deferred.promise)
    setTimeout () ->
      deferred.resolve(true)
      $rootScope.$apply()
    return stub

  ###
   test for set(newProjects)
  ###
  describe 'sync(projects)', ->

    it '1 project.', (done) ->
      stub = getStubPlatformSave()

      prj = [{
        url: "http://redmine.com"
        urlIndex: 0
        id: 0
        text: "prj1_0"
        show: SHOW.DEFAULT
        queryId: 1
      }]

      Project.sync(prj).then (result) ->
        value = stub.args[0][1]
        expect(value[prj[0].url].index).to.be.equal(prj[0].urlIndex)
        expect(value[prj[0].url][prj[0].id].show).to.be.equal(prj[0].show)
        expect(value[prj[0].url][prj[0].id].queryId).to.be.equal(prj[0].queryId)
        expect(result).to.be.true
        done()

    it '3 projects.', (done) ->
      stub = getStubPlatformSave()

      Project.sync(prj1).then () ->
        obj = stub.args[0][1]
        prj1.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()

    it '2 different server\'s projects.', (done) ->
      stub = getStubPlatformSave()

      projects = prj1.concat(prj2)
      Project.sync(projects).then () ->
        obj = stub.args[0][1]
        projects.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()

    it '3 different server\'s project', (done) ->
      stub = getStubPlatformSave()

      projects = prj1.concat(prj2).concat(prj3)
      Project.sync(projects).then ->
        obj = stub.args[0][1]
        projects.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()


  describe 'syncLocal(projects)', ->
    it '3 projects.', (done) ->
      stub = sinon.stub(Platform, "saveLocal")
      stub.returns(deferred.promise)
      setTimeout () ->
        deferred.resolve(true)
        $rootScope.$apply()

      Project.syncLocal(prj1).then ->
        obj = stub.args[0][1]
        prj1.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()


  describe 'create(params)', ->
    it 'a ProjectModel.', () ->
      p = Project.create(prj1[0])
      expect(p.equals(prj1[0])).to.be.true
