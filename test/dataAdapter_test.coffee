expect = chai.expect

describe 'DataAdapter.coffee', ->

  DataAdapter = null
  TestData = null
  Project = null
  Option = null

  _props = [
    "Account"
    "Projects"
    "Tickets"
    "Activities"
    "Queries"
    "Statuses"
  ]

  _auth = url:  'http://redmine.com'

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_DataAdapter_, _TestData_, _Project_, _Option_) ->
      DataAdapter = _DataAdapter_
      TestData = _TestData_()
      Project = _Project_
      Option = _Option_

    auth = {
      url:  'http://redmine.com'
      id:   'RedmineTimeTracker'
      pass: 'RedmineTimeTracker'
    }
    DataAdapter.addAccounts([auth])


  ###
   test for getter
  ###
  describe 'getter for DataModel properties', ->

    it 'should be binded.', () ->
      _props.map (p) ->
        method = "get" + p
        expect(DataAdapter[method]).exists

    it 'should be return _data[url]["statuses"] on account.', () ->
      DataAdapter.setStatuses(_auth.url, TestData.statuses)
      statuses = DataAdapter.getStatuses(_auth.url)
      expect(statuses).to.have.length(TestData.statuses.length)
      for s, index in statuses
        expect(s).to.deep.equal(TestData.statuses[index])

    it 'should be return _data[url]["projects"] on account.', () ->
      expectPrjs = TestData.prj1.map (p) -> Project.new(p)
      DataAdapter.addProjects(expectPrjs)
      projects = DataAdapter.getProjects(_auth.url)
      expect(projects).to.have.length(expectPrjs.length)
      for s, index in projects
        expect(s).to.deep.equal(expectPrjs[index])


  ###
   test for loadTimeEntries(params)
  ###
  describe 'excludeNonTicketProject()', ->

    it "should not return projects.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.new(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(0)

    it "should return 1 project.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.new(p)
      projects[0].ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(1)

    it "should return 1 project if update ticketCount after addProjects.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.new(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      allProjects[0].ticketCount = 1
      DataAdapter.updateProjects()
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(1)

    it "should return all project. [option = false]", () ->
      Option.getOptions().hideNonTicketProject = false
      projects = TestData.prj1.map (p) -> Project.new(p)
      projects[0].ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(3)

    it "should return all project. [option = true]", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.new(p)
      projects.map (p) -> p.ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(3)

    it "update selected project.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.new(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      allProjects[1].ticketCount = 1
      expect(DataAdapter.selectedProject).to.equals(allProjects[0])
      DataAdapter.updateProjects()
      expect(DataAdapter.selectedProject).to.equals(allProjects[1])
