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


  $rootScope.messages = []

  ###
   Initialize.
  ###
  init = () ->
    deferred = $q.defer()
    deferred.promise
      .then(_initializeEvents)
      .then(_initializeData)
      .then(_setDataSyncAlarms)
    deferred.resolve()


  ###
   initialize GoogleAnalytics.
  ###
  _initializeGoogleAnalytics = () ->
    Log.debug "start initialize GoogleAnalytics."
    Analytics.init {
      serviceName:   "RedmineTimeTracker"
      analyticsCode: "UA-32234486-7"
    }
    Log.debug("GoogleAnalytics is " + $scope.options.reportUsage)
    Analytics.setPermission $scope.options.reportUsage
    Analytics.sendView("/app/")


  ###
   initialize events.
  ###
  _initializeEvents = () ->
    Log.debug "start initialize Event."
    DataAdapter.addEventListener DataAdapter.ACCOUNT_ADDED, (accounts) ->
      for a in accounts
        _loadProjects(a)
        _loadActivities(a)
        _loadQueries(a)
    DataAdapter.addEventListener DataAdapter.TICKETS_CHANGED, () ->
      Ticket.set(DataAdapter.tickets)
    Log.debug "finish initialize Event."


  ###
   load projects from redmine.
  ###
  _loadProjects = (a) ->
    Redmine.get(a).loadProjects(page: 1, limit: 50)
      .then(_successLoadProject, _errorLoadProject)


  ###
   load projects from redmine.
  ###
  _successLoadProject = (data, status) =>
    if data.projects?
      projects = Project.get()
      data.projects.map (p) ->
        if projects[p.url] and projects[p.url][p.id]
          p.show = projects[p.url][p.id].show
        Project.add(p)
      DataAdapter.addProjects(data.projects)
      Message.toast Resource.string("msgLoadProjectSuccess").format(data.projects[0].url)
    else
      _errorLoadProject data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Log.debug("_errorLoadProjects() start")
    Message.toast Resource.string("msgLoadProjectFail")


  ###
   load activities for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadActivities = (account) ->
    Redmine.get(account).loadActivities (data) ->
      if not data?.time_entry_activities? then return
      Log.info "Redmine.loadActivities success"
      DataAdapter.setActivities(data.url, data.time_entry_activities)


  ###
   load queries for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadQueries = (account) ->
    params =
      page: 1
      limit: 50
    Redmine.get(account).loadQueries(params)
      .success(_updateQuery)
      .error(_errorLoadQuery)


  ###
   update query by redmine's data.
  ###
  _updateQuery = (data) =>
    data.queries.add({id: QUERY_ALL_ID, name: 'All'}, 0)
    DataAdapter.setQueries(data.url, data.queries)


  ###
   show error messaga.
  ###
  _errorLoadQuery = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadQueryFail")


  ###
   request a setup of redmine account to user.
  ###
  _requestAddAccount = () ->
    $timeout () ->
      State.isAdding = true
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
   initialize Data from chrome storage.
  ###
  _initializeData = () ->
    deferred = $q.defer()
    Log.debug "start initialize data."
    Option.loadOptions()
      .then((options) -> $scope.options = options)
      .then(_initializeGoogleAnalytics)
      .then(_initializeAccount)
      .then(_initializeProject)
      .then(_initializeIssues)
      .then(() -> DataAdapter.addAccounts(Account.getAccounts()))
      .then(() -> Log.debug "finish initialize data.")
      .then(() -> deferred.resolve())
    return deferred.promise


  ###
   Initialize account from chrome storage.
  ###
  _initializeAccount = () ->
    deferred = $q.defer()
    Log.debug "start Account.load()"
    Account.load().then (accounts) ->
      Log.debug "Account.load() success"
      if not accounts? or not accounts?[0]?
        _requestAddAccount()
        deferred.reject()
      deferred.resolve()
    return deferred.promise


  ###
   Initialize project from chrome storage.
  ###
  _initializeProject = () ->
    deferred = $q.defer()
    Log.debug "start Project.load()"
    Project.load().then (projects) ->
      Log.debug "Project.load() success"
      Project.set Project.sanitize(projects)
      deferred.resolve()
    return deferred.promise


  ###
   Initialize issues status.
  ###
  _initializeIssues = () ->
    deferred = $q.defer()
    Log.debug "start Ticket.load()"
    Ticket.load () ->
      Log.debug "Ticket.load() success"
      DataAdapter.tickets = Ticket.get()
      for t in DataAdapter.tickets
        for account in Account.getAccounts() when account.url is t.url
          Redmine.get(account).getIssuesById t.id, _issueFound, _issueNotFound
          break
      deferred.resolve()
    return deferred.promise


  ###
   when issue found, update according to status.
  ###
  _issueFound = (issue) ->
    if issue?.status.id is TICKET_CLOSED
      DataAdapter.removeTicket(issue)
      return
    target = DataAdapter.tickets.find (n) -> n.equals(issue)
    target.text        = issue.subject
    target.assigned_to = issue.assigned_to
    target.priority    = issue.priority
    target.status      = issue.status
    if issue.spent_hours?
      target.total = Math.floor(issue.spent_hours * 100) / 100


  ###
   when issue not found, remove issue.
  ###
  _issueNotFound = (issue, status) ->
    if status is NOT_FOUND or status is UNAUTHORIZED
      DataAdapter.tickets.removeTicket(issue)
      return


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
      Ticket.set(DataAdapter.tickets)
      Ticket.sync()
      Project.sync()


  ###
   Start Initialize.
  ###
  init()

