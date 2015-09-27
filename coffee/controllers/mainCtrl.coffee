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
        _loadStatuses(a)
          .then(_loadIssues(a))
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
      Message.toast Resource.string("msgLoadProjectSuccess").format(data.account.name), 2000
    else
      _errorLoadProject data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Log.debug("_errorLoadProjects() start")
    Message.toast Resource.string("msgLoadProjectFail").format(data.account.name), 3000


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
      .then(_updateQuery, _errorLoadQuery)


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
    Message.toast Resource.string("msgLoadQueryFail").format(data.account.name), 2000


  ###
   load statuses for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadStatuses = (account) =>
    Redmine.get(account).loadStatuses()
      .then((data) ->
        DataAdapter.setStatuses(data.url, data.issue_statuses)
      , (data, status) ->
        if status is STATUS_CANCEL then return
        Message.toast(Resource.string("msgLoadStatusesFail").format(data.account.name), 2000))

  ###
   load issues for account.
   @param account {AccountModel} - load from this account.
  ###
  _loadIssues = (account) -> () ->
    for t in DataAdapter.tickets when account.url is t.url
      Redmine.get(account).getIssuesById t.id, _upsateIssue(t), _issueNotFound(account)

  ###
   when issue found, update according to it.
  ###
  _upsateIssue = (target) -> (issue) ->
    for k, v of issue then target[k] = v
    # remove closed issues.
    statuses = DataAdapter.getStatuses(target.url)
    status = statuses.find (n) -> n.id is target.status.id
    if status?.is_closed
      DataAdapter.toggleIsTicketShow(target)
      Message.toast(Resource.string("msgIssueClosed").format(target.text), 3000)

  ###
   when issue not found, remove issue.
  ###
  _issueNotFound = (account) -> (issue, status) ->
    if status is NOT_FOUND or status is UNAUTHORIZED
      DataAdapter.toggleIsTicketShow(issue)
      Message.toast(Resource.string("msgIssueMissing").format(target.text, account.name), 3000)

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
    Project.load().then () ->
      Log.debug "Project.load() success"
      deferred.resolve()
    return deferred.promise


  ###
   Initialize issues status.
  ###
  _initializeIssues = () ->
    deferred = $q.defer()
    Log.debug "start Ticket.load()"
    Ticket.load (tickets) ->
      Log.groupCollapsed "Ticket.load() success"
      Log.debug tickets
      Log.groupEnd "Ticket.load() success"
      DataAdapter.toggleIsTicketShow(tickets)
      deferred.resolve()
    return deferred.promise


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

