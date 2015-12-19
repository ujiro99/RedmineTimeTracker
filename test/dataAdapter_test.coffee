expect = chai.expect

describe 'DataAdapter.coffee', ->

  DataAdapter = null
  TestData = null
  Account = null
  Project = null
  Ticket = null
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
    inject (_DataAdapter_, _TestData_, _Account_, _Project_, _Ticket_, _Option_) ->
      DataAdapter = _DataAdapter_
      TestData = _TestData_()
      Account = _Account_
      Project = _Project_
      Ticket = _Ticket_
      Option = _Option_

    auth = [Account.create({
      url:  'http://redmine.com'
      id:   'RedmineTimeTracker'
      pass: 'RedmineTimeTracker'
    }), Account.create({
      url:  'http://redmine.com2'
      id:   'RedmineTimeTracker'
      pass: 'RedmineTimeTracker'
    })]
    DataAdapter.addAccounts(auth)


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
      expectPrjs = TestData.prj1.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs)
      projects = DataAdapter.getProjects(_auth.url)
      expect(projects).to.have.length(expectPrjs.length)
      for s, index in projects
        expect(s).to.deep.equal(expectPrjs[index])

    it 'should be return "projects" on all account.', () ->
      expectPrjs1 = TestData.prj1.map (p) -> Project.create(p)
      expectPrjs2 = TestData.prj2.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs1)
      DataAdapter.addProjects(expectPrjs2)
      expectPrjs = expectPrjs1.concat(expectPrjs2)
      projects = DataAdapter.getProjects()
      expect(projects).to.have.length(expectPrjs.length)
      for s, index in projects
        expect(s).to.deep.equal(expectPrjs[index])

  ###
   test for excludeNonTicketProject(params)
  ###
  describe 'excludeNonTicketProject()', ->

    it "should not return projects.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.create(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(0)

    it "should return 1 project.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.create(p)
      projects[0].ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(1)

    it "should return 2 project if DataAdapter has 2 accounts.", () ->
      Option.getOptions().hideNonTicketProject = true
      prj1 = TestData.prj1.map (p) -> Project.create(p)
      prj2 = TestData.prj2.map (p) -> Project.create(p)
      prj1[0].ticketCount = 1
      prj2[0].ticketCount = 1
      DataAdapter.addProjects(prj1)
      DataAdapter.addProjects(prj2)
      allProjects = DataAdapter.getProjects()
      expect(allProjects).to.have.length(6)
      filtered = []
      DataAdapter.accounts.map (a) -> filtered.push a.projects
      expect(filtered).to.have.length(2)

    it "should return 1 project if update ticketCount after addProjects.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.create(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      allProjects[0].ticketCount = 1
      DataAdapter.updateProjects()
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(1)

    it "should return all project. [option = false]", () ->
      Option.getOptions().hideNonTicketProject = false
      projects = TestData.prj1.map (p) -> Project.create(p)
      projects[0].ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(3)

    it "should return all project. [option = true]", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.create(p)
      projects.map (p) -> p.ticketCount = 1
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      expect(allProjects).to.have.length(3)
      filtered = DataAdapter.accounts[0].projects
      expect(filtered).to.have.length(3)

    it "update selected project.", () ->
      Option.getOptions().hideNonTicketProject = true
      projects = TestData.prj1.map (p) -> Project.create(p)
      DataAdapter.addProjects(projects)
      allProjects = DataAdapter.getProjects(_auth.url)
      allProjects[1].ticketCount = 1
      expect(DataAdapter.selectedProject).to.equals(allProjects[0])
      DataAdapter.updateProjects()
      expect(DataAdapter.selectedProject).to.equals(allProjects[1])


  ###
   test for addProjects
  ###
  describe "addProjects(projects)", () ->

    it "should add 3 projects.", () ->
      expectPrjs1 = TestData.prj1.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs1)
      expect(DataAdapter.getProjects()).to.have.length(3)

    it "should add 3 projects twice.", () ->
      expectPrjs1 = TestData.prj1.map (p) -> Project.create(p)
      expectPrjs2 = TestData.prj2.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs1)
      DataAdapter.addProjects(expectPrjs2)
      expect(DataAdapter.getProjects(expectPrjs1[0].url)).to.have.length(3)
      expect(DataAdapter.getProjects(expectPrjs2[0].url)).to.have.length(3)
      expect(DataAdapter.getProjects()).to.have.length(6)

    it "should add 6 projects on 2 accounts.", () ->
      expectPrjs1 = TestData.prj1.map (p) -> Project.create(p)
      expectPrjs2 = TestData.prj2.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs1.concat(expectPrjs2))
      expect(DataAdapter.getProjects(expectPrjs1[0].url)).to.have.length(3)
      expect(DataAdapter.getProjects(expectPrjs2[0].url)).to.have.length(3)
      expect(DataAdapter.getProjects()).to.have.length(6)

    it "should not add null", () ->
      DataAdapter.addProjects(null)
      expect(DataAdapter.getProjects()).to.have.length(0)

    it "should not add if not have account.", () ->
      expectPrjs = TestData.prj3.map (p) -> Project.create(p)
      DataAdapter.addProjects(expectPrjs)
      expect(DataAdapter.getProjects()).to.have.length(0)


  describe "addAccounts(accounts)", () ->

    it "should store 2 accounts.", () ->
      expect(DataAdapter.getAccount()).to.have.length(2)

    it "add same url account, then should update a account.", () ->
      auth = Account.create({
        url:  'http://redmine.com'
        id:   'RedmineTimeTracker2'
        pass: 'RedmineTimeTracker2'
      })
      DataAdapter.addAccounts(auth)
      expect(DataAdapter.getAccount()).to.have.length(2)
      expect(DataAdapter.getAccount(auth.url).id).to.equal(auth.id)

    it "add null object, then should not change state.", () ->
      before = DataAdapter.getAccount()
      auth = null
      DataAdapter.addAccounts(auth)
      after = DataAdapter.getAccount()
      expect(after).to.deep.equal(before)

    it "add empty object, then should not change state.", () ->
      before = DataAdapter.getAccount()
      auth = Account.create {}
      DataAdapter.addAccounts(auth)
      after = DataAdapter.getAccount()
      expect(after).to.deep.equal(before)

    it "should store 3 accounts.", () ->
      auth = [Account.create({
        url:  'http://redmine.com3'
        id:   'RedmineTimeTracker'
        pass: 'RedmineTimeTracker'
      })]
      DataAdapter.addAccounts(auth)
      expect(DataAdapter.getAccount()).to.have.length(3)


  describe "updateAccounts(accounts)", () ->

    it "should update a account.", () ->
      auth = Account.create({
        url:  'http://redmine.com'
        id:   'RedmineTimeTracker2'
        pass: 'RedmineTimeTracker2'
      })
      DataAdapter.updateAccounts(auth)
      expect(DataAdapter.getAccount()).to.have.length(2)
      expect(DataAdapter.getAccount(auth.url).id).to.equal(auth.id)

    it "should not change state, if url not exists.", () ->
      before = DataAdapter.getAccount()
      auth = Account.create({
        url:  'http://redmine.com3'
        id:   'RedmineTimeTracker2'
        pass: 'RedmineTimeTracker2'
      })
      DataAdapter.updateAccounts(auth)
      after = DataAdapter.getAccount()
      expect(after).to.deep.equal(before)

    it "should not change state, if param is null.", () ->
      before = DataAdapter.getAccount()
      auth = null
      DataAdapter.updateAccounts(auth)
      after = DataAdapter.getAccount()
      expect(after).to.deep.equal(before)

    it "should not change state, if param is empty.", () ->
      before = DataAdapter.getAccount()
      auth = Account.create({})
      DataAdapter.updateAccounts(auth)
      after = DataAdapter.getAccount()
      expect(after).to.deep.equal(before)


  describe "removeAccounts(accounts)", () ->

    it "should remove a account.", () ->
      auth = DataAdapter.getAccount()
      DataAdapter.removeAccounts(auth[0])
      expect(DataAdapter.getAccount()).to.have.length(1)
      expect(DataAdapter.getAccount()[0].url).to.equals(auth[1].url)

    it "should remove a account and update selected ticket/project.", () ->
      auth = DataAdapter.getAccount()

      # add project
      projects1 = TestData.prj1.map (p) -> Project.create(p)
      projects2 = TestData.prj2.map (p) -> Project.create(p)
      projects1[0].ticketCount = 1
      projects2[0].ticketCount = 1
      DataAdapter.addProjects(projects1)
      DataAdapter.addProjects(projects2)

      # add ticket
      tickets = TestData.ticketList2.map (n) -> Ticket.create(n)
      DataAdapter.toggleIsTicketShow tickets

      # exec
      DataAdapter.removeAccounts(auth[0])

      # check
      expect(DataAdapter.selectedProject.url).to.equals(auth[1].url)
      expect(DataAdapter.selectedTicket.url).to.equals(TestData.ticketList2[1].url)

    it "should remove two account.", () ->
      auth = DataAdapter.getAccount()
      DataAdapter.removeAccounts(auth)
      expect(DataAdapter.getAccount()).to.have.length(0)


  describe "isAccountExists(account)", () ->

    it "should be true.", () ->
      auth = DataAdapter.getAccount()
      res = DataAdapter.isAccountExists(auth[0])
      expect(res).to.be.true

    it "should be false.", () ->
      auth = Account.create({
        url:  'http://redmine.com3'
      })
      res = DataAdapter.isAccountExists(auth)
      expect(res).to.be.false

    it "should be false if param is null.", () ->
      auth = null
      res = DataAdapter.isAccountExists(auth)
      expect(res).to.be.false

    it "should be false if param is empty.", () ->
      auth = Account.create({})
      res = DataAdapter.isAccountExists(auth)
      expect(res).to.be.false
