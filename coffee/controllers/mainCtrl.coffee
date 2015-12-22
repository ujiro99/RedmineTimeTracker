timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, $q, Ticket, Project, Redmine, Account, State, DataAdapter, Message, Chrome, Resource, Option, Log, Analytics) ->

  DATA_SYNC = "DATA_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5
  NOT_FOUND = 404
  UNAUTHORIZED = 401
  # http request canceled.
  STATUS_CANCEL = 0
  # don't use query
  QUERY_ALL_ID = 0

  # list for toast Message.
  $rootScope.messages = []

  State.title = Resource.string("extName")
  $scope.state = State

  ###
   Initialize.
  ###
  init = () ->
    deferred = $q.defer()
    deferred.promise
      .then(_initializeGoogleAnalytics)
      .then(_initializeDataFromChrome)
      .then(_initializeDataFromRedmine)
      .then(_initializeEvents)
      .then(_setDataSyncAlarms)
    deferred.resolve()

  ###
   initialize events.
  ###
  _initializeEvents = () ->
    Log.debug "[4] initializeEvents start"
    DataAdapter.addEventListener DataAdapter.ACCOUNT_ADDED, _loadRedmine
    DataAdapter.addEventListener DataAdapter.PROJECTS_CHANGED, () ->
      Project.syncLocal(DataAdapter.getProjects())
    DataAdapter.addEventListener DataAdapter.TICKETS_CHANGED, () ->
      Ticket.syncLocal(DataAdapter.tickets)
    Option.onChanged('reportUsage', (e) -> Analytics.setPermission(e) )
    Option.onChanged('hideNonTicketProject',  _toggleProjectHidden)
    Log.debug "[4] initializeEvents success"

  ###
   load projects from redmine.
  ###
  _loadRedmine = (accounts) ->
    for a in accounts
      _loadActivities(a)
      _loadQueries(a)
      $q.all([_loadProjects(a), _loadStatuses(a)])
        .then(_loadIssues(a))
        .then(_loadIssueCount(a))


  ###
   load projects from redmine.
  ###
  _loadProjects = (a) ->
    redmine = Redmine.get(a)
    promises = []
    # fetch projects according to numProjects.
    if a.numProjects isnt 0
      promises.push(redmine.loadProjectsRange({}, 0, a.numProjects))
    # fetch projects according to projectList.
    if a.projectList
      promises.add a.projectList.map (id) -> redmine.loadProjectById(id)
    # if nothing to fetch...
    if promises.length is 0
      Message.toast Resource.string("msgCannotFetchProject").format(a.name), 5000
      Log.warn "loadProjects: account.numProjects: #{a.numProjects}\taccount.projectList: #{a.projectList}"
      return
    promises = promises.map (p) -> p.then(_successLoadProject, _errorLoadProject)
    $q.all(promises).then(_updateProjects)


  ###
   show success message.
  ###
  _successLoadProject = (data) =>
    if not data.project and not data.projects and data.projects.length is 0
      _errorLoadProject data
      return null
    data.projects = data.projects or [data.project]
    Message.toast Resource.string("msgLoadProjectSuccess").format(data.account.name, data.projects.length), 3000
    return data.projects


  ###
   show error message.
  ###
  _errorLoadProject = (data) =>
    if data.status is STATUS_CANCEL then return
    if data.targetId
      message = Resource.string("msgLoadProjectFailId").format(data.account.name, data.targetId) + Resource.string("status").format(data.status)
    else
      message = Resource.string("msgLoadProjectFaild").format(data.account.name, data.account.numProjects or '') + Resource.string("status").format(data.status)
    Message.toast message, 5000
    return null


  ###
   update projects and remove projects which was not fetched.
   @param projectsList {Array} - array of fetched projects.
  ###
  _updateProjects = (projectsList) =>
    projects = projectsList.compact().flatten().unique("id")

    # update settings specified by user, using saved data on chrome.
    saved = DataAdapter.getProjects(projects[0].url)
    projects.map (p) ->
      s = saved.find (n) -> n.equals p
      return if not s
      p.show = s.show
      p.queryId = s.queryId
      # On chrome, project doesn't have text. Update it here.
      if p.equals DataAdapter.selectedProject
        DataAdapter.selectedProject.text = p.text

    # update
    DataAdapter.removeProjects(saved)
    DataAdapter.addProjects(projects)


  ###
   load activities for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadActivities = (account) ->
    Redmine.get(account).loadActivities()
      .then((data) ->
        if not data?.time_entry_activities? then return
        Log.info "Redmine.loadActivities success"
        DataAdapter.setActivities(data.account.url, data.time_entry_activities))

  ###
   load queries for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadQueries = (account) ->
    params =
      page: 1
      limit: 50
    Redmine.get(account).loadQueries(params)
      .then((data) ->
        data.queries.add({id: QUERY_ALL_ID, name: 'All'}, 0)
        DataAdapter.setQueries(data.account.url, data.queries)
      , (data, status) =>
        if status is STATUS_CANCEL then return
        Message.toast Resource.string("msgLoadQueryFail").format(data.account.name), 3000)

  ###
   load statuses for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadStatuses = (account) =>
    Redmine.get(account).loadStatuses()
      .then((data) ->
        DataAdapter.setStatuses(data.account.url, data.issue_statuses)
      , (data, status) ->
        if status is STATUS_CANCEL then return
        Message.toast(Resource.string("msgLoadStatusesFail").format(data.account.name), 3000))

  ###
   load issues for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadIssues = (account) -> () ->
    for t in DataAdapter.tickets when account.url is t.url
      Redmine.get(account).getIssuesById t.id, _upsateIssue(t), _issueNotFound(t)

  ###
   when issue found, update according to it.
  ###
  _upsateIssue = (target) -> (issue) ->
    for k, v of issue then target[k] = v
    return if not Option.getOptions().removeClosedTicket
    # remove closed issues.
    statuses = DataAdapter.getStatuses(target.url)
    status = statuses.find (n) -> n.id is target.status.id
    if status?.is_closed
      DataAdapter.toggleIsTicketShow(target)
      Message.toast(Resource.string("msgIssueClosed").format(target.text), 3000)

  ###
   when issue not found, remove issue.
  ###
  _issueNotFound = (target) -> (issue, status) ->
    if status is NOT_FOUND or status is UNAUTHORIZED
      DataAdapter.toggleIsTicketShow(issue)
      Message.toast(Resource.string("msgIssueMissing").format(target.text, account.name), 3000)

  ###
   count project's issues count.
  ###
  _loadIssueCount = (account) -> () ->
    return if not Option.getOptions().hideNonTicketProject
    projects = DataAdapter.getProjects(account.url)
    promises = projects.map (p) ->
      params = limit: 1, project_id: p.id, status_id: "open"
      Redmine.get(account).getIssuesPararell(params)
        .then((d) ->
          p.ticketCount = d.total_count
          Log.debug("project: " + p.text + "\tticketCount: " + p.ticketCount))
    $q.all(promises).then(() -> DataAdapter.updateProjects())

  ###
   count project's issues count on all accounts.
  ###
  _toggleProjectHidden = (enableHide) ->
    if not enableHide
      DataAdapter.updateProjects()
    else
      for a in Account.getAccounts()
        _loadIssueCount(a)()

  ###
   request a setup of redmine account to user.
  ###
  _requestAddAccount = () ->
    $timeout () ->
      State.isAdding = true
      State.isCollapseSetting = false
    , 500
    $timeout () ->
      $location.hash('accounts')
      $anchorScroll()
    , 1000
    $timeout () ->
      Message.toast(Resource.string("msgRequestAddAccount_0"), 5000)
    , 1500
    $timeout () ->
      Message.toast(Resource.string("msgRequestAddAccount_1"), 5000)
    , 2500

  ###
   initialize GoogleAnalytics.
  ###
  _initializeGoogleAnalytics = () ->
    Log.debug "[1] initializeGoogleAnalytics start"
    Analytics.init {
      serviceName:   "RedmineTimeTracker"
      analyticsCode: "UA-32234486-7"
    }
    Analytics.sendView("/app/")
    Log.debug "[1] initializeGoogleAnalytics success"

  ###
   initialize Data from chrome storage.
  ###
  _initializeDataFromChrome = () ->
    Log.debug "[2] initializeDataFromChrome start"
    Option.loadOptions()
      .then(_initializeAccount)
      .then(_initializeProject)
      .then(_initializeIssues)
      .then(() ->
        Log.debug "[2] initializeDataFromChrome success."
      , () ->
        Log.warn "[2] initializeDataFromChrome failed")

  ###
   Initialize account from chrome storage.
  ###
  _initializeAccount = () ->
    Account.load().then (accounts) ->
      if accounts
        DataAdapter.addAccounts(accounts)
      else if not accounts?
        _requestAddAccount()

  ###
   Initialize project from chrome storage.
  ###
  _initializeProject = () ->
    Project.load()
      .then((projects) -> DataAdapter.addProjects(projects))

  ###
   Initialize issues status.
  ###
  _initializeIssues = () ->
    Ticket.load()
      .then((tickets) -> DataAdapter.toggleIsTicketShow(tickets))

  ###
   initialize Data from Redmine.
  ###
  _initializeDataFromRedmine = () ->
    Log.debug "[3] initializeDataFromRedmine start "
    accounts = DataAdapter.getAccount()
    $q.all(_loadRedmine(accounts))
      .finally(-> Log.debug "[3] initializeDataFromRedmine success")

  ###
   set datasync event to chrome alarms.
  ###
  _setDataSyncAlarms = () ->
    alarmInfo =
      when: Date.now() + 1
      periodInMinutes: MINUTE_5
    Chrome.alarms.create(DATA_SYNC, alarmInfo)
    Chrome.alarms.onAlarm.addListener (alarm) ->
      return if not alarm.name is DATA_SYNC
      Ticket.sync(DataAdapter.tickets)
      Project.sync(DataAdapter.getProjects())

  ###
   Start Initialize.
  ###
  init()

