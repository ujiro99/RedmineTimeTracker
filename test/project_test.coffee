expect = chai.expect

describe 'project.coffee', ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  Project = null
  Chrome = null


  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Project_, _Chrome_) ->
      Project = _Project_   # underscores are a trick for resolving references.
      Chrome = _Chrome_


  it 'shoud have working Project service', () ->
    expect(Project.add).not.to.equal null


  ###
    set: (newProjects) ->
    setParam: (url, id, params) ->
    remove: (url, id) ->
    removeUrl: (url) ->
    load: (callback) ->
    sync: (callback) ->
    new: (params) ->
    clear: (callback) ->
  ###


  ###
   test for get()
  ###
  describe 'get()', ->

    it 'be empty', () ->
      projects = Project.get()
      expect(projects).to.be.empty

  ###
   test for getSelectable()
  ###
  describe 'getSelectable()', ->

    it 'be empty', () ->
      projects = Project.getSelectable()
      expect(projects).to.be.empty

    it 'SHOW.NOT expect to be empty', () ->
      prj =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: ""
        show: SHOW.NOT
      Project.add(prj)

      projects = Project.getSelectable()
      expect(projects).to.be.empty

    it 'SHOW.DEFAULT expect to not be empty', () ->
      prj =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: ""
        show: SHOW.DEFAULT
      Project.add(prj)

      projects = Project.getSelectable()
      expect(projects).to.not.be.empty

    it 'SHOW.SHOW expect to not be empty', () ->
      prj =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: ""
        show: SHOW.SHOW
      Project.add(prj)

      projects = Project.getSelectable()
      expect(projects).to.not.be.empty

  ###
   test for add()
  ###
  describe 'add()', ->

    it 'add 1 project', () ->
      expect(Project.get()).to.be.empty
      prj =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: ""
        show: SHOW.DEFAULT
      Project.add(prj)
      added = Project.get()
      expect(added[prj.url].index).to.be.equal(prj.urlIndex)
      expect(added[prj.url][prj.id].text).to.be.equal(prj.text)
      expect(added[prj.url][prj.id].show).to.be.equal(prj.show)

    it 'update a project', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2   # same url and urlIndex
        id: 0         # same id
        text: "second"
        show: SHOW.SHOW

      # execute
      Project.add(prj1)
      Project.add(prj2)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.not.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.not.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)

    it 'add 2 projects on same redmine server', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 1
        text: "second"
        show: SHOW.DEFAULT

      # execute
      Project.add(prj1)
      Project.add(prj2)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)

    it 'add 2 projects on different redmine server', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker2"
        urlIndex: 3 # url is different from prj1.
        id: 0
        text: "second"
        show: SHOW.DEFAULT

      # execute
      Project.add(prj1)
      Project.add(prj2)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)

    it 'add 3 projects on same redmine server', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 1
        text: "second"
        show: SHOW.DEFAULT
      prj3 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 2
        text: "third"
        show: SHOW.DEFAULT

      # execute
      Project.add(prj1)
      Project.add(prj2)
      Project.add(prj3)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)
      expect(added[prj3.url].index).to.be.equal(prj3.urlIndex)
      expect(added[prj3.url][prj3.id].text).to.be.equal(prj3.text)
      expect(added[prj3.url][prj3.id].show).to.be.equal(prj3.show)

    it 'add 3 projects on same/different redmine server', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker1"
        urlIndex: 3
        id: 1
        text: "second"
        show: SHOW.DEFAULT
      prj3 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 1
        text: "third"
        show: SHOW.DEFAULT

      # execute
      Project.add(prj1)
      Project.add(prj2)
      Project.add(prj3)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)
      expect(added[prj3.url].index).to.be.equal(prj3.urlIndex)
      expect(added[prj3.url][prj3.id].text).to.be.equal(prj3.text)
      expect(added[prj3.url][prj3.id].show).to.be.equal(prj3.show)

    it 'add 3 projects on different redmine server', () ->
      expect(Project.get()).to.be.empty

      # create test data
      prj1 =
        url: "https://github.com/ujiro99/RedmineTimeTracker"
        urlIndex: 2
        id: 0
        text: "first"
        show: SHOW.DEFAULT
      prj2 =
        url: "https://github.com/ujiro99/RedmineTimeTracker1"
        urlIndex: 3
        id: 0
        text: "second"
        show: SHOW.DEFAULT
      prj3 =
        url: "https://github.com/ujiro99/RedmineTimeTracker2"
        urlIndex: 4
        id: 0
        text: "third"
        show: SHOW.DEFAULT

      # execute
      Project.add(prj1)
      Project.add(prj2)
      Project.add(prj3)

      # assert
      added = Project.get()
      expect(added[prj1.url].index).to.be.equal(prj1.urlIndex)
      expect(added[prj1.url][prj1.id].text).to.be.equal(prj1.text)
      expect(added[prj1.url][prj1.id].show).to.be.equal(prj1.show)
      expect(added[prj2.url].index).to.be.equal(prj2.urlIndex)
      expect(added[prj2.url][prj2.id].text).to.be.equal(prj2.text)
      expect(added[prj2.url][prj2.id].show).to.be.equal(prj2.show)
      expect(added[prj3.url].index).to.be.equal(prj3.urlIndex)
      expect(added[prj3.url][prj3.id].text).to.be.equal(prj3.text)
      expect(added[prj3.url][prj3.id].show).to.be.equal(prj3.show)

