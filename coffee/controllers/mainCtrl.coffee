timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, Ticket, Project, Redmine, Account, State, DataAdapter, Message, Analytics, Chrome, Resource, Option, Log) ->

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

    # load options frome chrome storage.
    Option.loadOptions (options) -> $scope.options = options

    # initialize events.
    DataAdapter.addEventListener DataAdapter.ACCOUNT_ADDED, (accounts) ->
      for a in accounts
        params =
          page: 1
          limit: 50
        Redmine.get(a).loadProjects _updateProjects, _errorLoadProject, params
        _loadActivities(a)
        _loadQueries(a)
    DataAdapter.addEventListener DataAdapter.TICKETS_CHANGED, () ->
      Ticket.set(DataAdapter.tickets)
      Ticket.sync()
    _setDataSyncAlarms()

    # initialize data.
    Account.getAccounts (accounts) ->
      Log.debug "Account.getAccounts success"
      if not accounts? or not accounts?[0]?
        _requestAddAccount()
        return
      DataAdapter.addAccounts(accounts)
      Ticket.load(_updateIssues)

    # initialize others.
    _initializeGoogleAnalytics()


  ###
   update projects by redmine's data.
  ###
  _updateProjects = (data) =>
    Log.debug("_updateProjects() start")
    if data.projects?
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
   update issues status.
  ###
  _updateIssues = () ->
    DataAdapter.tickets = Ticket.get()
    for t in DataAdapter.tickets
      for account in DataAdapter.accounts when account.url is t.url
        Redmine.get(account).getIssuesById t.id, _issueFound, _issueNotFound
        break


  ###
   when issue found, update according to status.
  ###
  _issueFound = (issue) ->
    if issue?.status.id is TICKET_CLOSED
      DataAdapter.tickets.removeTicket(issue)
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
   initialize GoogleAnalytics.
  ###
  _initializeGoogleAnalytics = () ->
    Analytics.init {
      serviceName:   "RedmineTimeTracker"
      analyticsCode: "UA-32234486-7"
    }
    Analytics.sendView("/app/")


  ###
   Start Initialize.
  ###
  init()

