expect = chai.expect

describe 'project.coffee', ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $rootScope = null
  Project = null
  Chrome = null
  TestData = null

  prjObj = null
  prj1 = null
  prj2 = null
  prj3 = null


  beforeEach () ->
    angular.mock.module('timeTracker')
    # underscores are a trick for resolving references.
    inject (_Project_, _Chrome_, _TestData_, _$rootScope_) ->
      $rootScope = _$rootScope_
      Project = _Project_
      Chrome = _Chrome_
      TestData = _TestData_()
      prjObj = TestData.prjObj
      prj1 = TestData.prj1.map (p) -> Project.create(p)
      prj2 = TestData.prj2.map (p) -> Project.create(p)
      prj3 = TestData.prj3.map (p) -> Project.create(p)


  it 'shoud have working Project service', (done) ->
    Chrome.storage.local.get = (arg1, callback) ->
      setTimeout () ->
        callback(PROJECT: [])
        # Propagate promise resolution to 'then' functions using $apply().
        $rootScope.$apply()
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

    it 'loads data from local.', (done) ->
      Chrome.storage.local.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: prjObj
          $rootScope.$apply()
      # exec test.
      Project.load().then (projects) ->
        expect(projects[0].equals(prj1[0])).to.be.true
        expect(projects[1].equals(prj2[0])).to.be.true
        expect(projects[2].equals(prj3[0])).to.be.true
        done()

    it 'loads data from sync.', (done) ->
      Chrome.storage.local.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: null
          $rootScope.$apply()
      Chrome.storage.sync.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: prjObj
          $rootScope.$apply()
      # exec test.
      Project.load().then (projects) ->
        expect(projects[0].equals(prj1[0])).to.be.true
        expect(projects[1].equals(prj2[0])).to.be.true
        expect(projects[2].equals(prj3[0])).to.be.true
        done()

    it 'if data not exists, call error callback.', (done) ->
      # put test data.
      Chrome.storage.local.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: null
          $rootScope.$apply()
      Chrome.storage.sync.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: null
          $rootScope.$apply()
      # exec test.
      Project.load()
        .then (projects) ->
          expect(true).to.be.false # fail!
        , (prjects) ->
          expect(prjects).to.be.null
          done()

    it 'compatibility (version <= 0.5.7): index start changed.', (done) ->
      # put test data.
      # this data is old format (version <= 0.5.7).
      Chrome.storage.local.get = (arg1, callback) ->
        setTimeout () ->
          callback PROJECT: TestData.prjOldFormat
          $rootScope.$apply()
      Project.load().then (projects) ->
        expect(projects[0].equals(prj1[0])).to.be.true
        expect(projects[1].equals(prj2[0])).to.be.true
        expect(projects[2].equals(prj3[0])).to.be.true
        done()


  ###
   test for set(newProjects)
  ###
  describe 'sync(projects)', ->

    it '1 project.', (done) ->
      prj = [{
        url: "http://redmine.com"
        urlIndex: 0
        id: 0
        text: "prj1_0"
        show: SHOW.DEFAULT
        queryId: 1
      }]
      Chrome.storage.sync.set = (arg, callback) ->
        setTimeout ->
          obj = arg.PROJECT
          expect(obj[prj[0].url].index).to.be.equal(prj[0].urlIndex)
          expect(obj[prj[0].url][prj[0].id].show).to.be.equal(prj[0].show)
          expect(obj[prj[0].url][prj[0].id].queryId).to.be.equal(prj[0].queryId)
          callback()
          $rootScope.$apply()
      Project.sync(prj).then (result) ->
        expect(result).to.be.true
        done()

    it '3 projects.', (done) ->
      Chrome.storage.sync.set = (arg, callback) ->
        obj = arg.PROJECT
        prj1.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()
      Project.sync(prj1)

    it '2 different server\'s projects.', (done) ->
      projects = prj1.concat(prj2)
      Chrome.storage.sync.set = (arg, callback) ->
        obj = arg.PROJECT
        projects.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()
      Project.sync(projects)

    it '3 different server\'s project', (done) ->
      projects = prj1.concat(prj2).concat(prj3)
      Chrome.storage.sync.set = (arg, callback) ->
        obj = arg.PROJECT
        projects.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()
      Project.sync(projects)


  describe 'syncLocal(projects)', ->
    it '3 projects.', (done) ->
      Chrome.storage.local.set = (arg, callback) ->
        obj = arg.PROJECT
        prj1.map (p) ->
          expect(obj[p.url].index).to.be.equal(p.urlIndex)
          expect(obj[p.url][p.id].show).to.be.equal(p.show)
          expect(obj[p.url][p.id].queryId).to.be.equal(p.queryId)
        done()
      Project.syncLocal(prj1)


  describe 'create(params)', ->
    it 'a ProjectModel.', () ->
      p = Project.create(prj1[0])
      expect(p.equals(prj1[0])).to.be.true
