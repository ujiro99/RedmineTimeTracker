timeTracker.controller 'TimerCtrl', ($scope, $timeout, Account, Redmine, Ticket, Message, State, Resource) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255
  SWITCHING_TIME = 300

  $scope.state = State
  $scope.projects = {}
  $scope.selectedActivity = []
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX
  $scope.mode = "auto"
  $scope.time = { min: 0 }
  $scope.tickets = []
  $scope.selectedTicket = []

  trackedTime = {}

  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      if not accounts then return
      for account in accounts
        loadActivities account
    $scope.tickets = Ticket.getSelectable()
    $scope.selectedTicket = Ticket.getSelected()

  init()


  ###
   load activities for new account.
  ###
  $scope.$on 'accountAdded', (e, account) ->
    loadActivities account


  ###
   load activities for account.
  ###
  loadActivities = (account) ->
    $scope.projects[account.url] = $scope.projects[account.url] or {}
    $scope.projects[account.url].account = account
    Redmine.get(account).getActivities(getActivitiesSuccess)


  ###
   on first, set selectedActivity.
  ###
  _getActivitiesSuccessFirst = (data, status, headers, config) ->
    _getActivitiesSuccess(data, status, headers, config)
    getActivitiesSuccess = _getActivitiesSuccess
    $scope.selectedActivity[0] = $scope.projects[data.url].activities[0]


  ###
   show loaded activities.
  ###
  _getActivitiesSuccess = (data, status, headers, config) ->
    if not data?.time_entry_activities? then return
    $scope.projects[data.url].activities = for a in data.time_entry_activities
      a.text = a.name; a


  ###
   show loaded activities.
  ###
  getActivitiesSuccess = _getActivitiesSuccessFirst


  ###
   change activity according to selected ticket
  ###
  $scope.$watch 'selectedTicket[0].url', ->
    if not $scope.selectedTicket[0]? then return
    url = $scope.selectedTicket[0].url
    $scope.selectedActivity[0] = $scope.projects[url].activities?[0]


  ###
   change post mode.
   if tracking, restore tracked time.
  ###
  $scope.changeMode = () ->
    if $scope.mode is "auto"
      if State.isTracking
        $scope.$broadcast 'timer-stop'
      $scope.mode = "manual"
    else
      $scope.mode = "auto"
      if State.isTracking
        # wait for complete switching
        $timeout () ->
          $scope.$broadcast 'timer-start', new Date() - trackedTime.millis
        , SWITCHING_TIME


  ###
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    if not $scope.selectedTicket[0] then return
    if State.isTracking
      State.isTracking = false
      $scope.$broadcast 'timer-stop'
    else
      State.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on clicked manual post button, send time entry.
  ###
  $scope.clickManual = () ->
    postEntry($scope.time.min)


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    trackedTime = time
    if not State.isTracking
      postEntry(time.minutes)


  ###
   send time entry.
  ###
  postEntry = (minutes) ->
    if minutes >= ONE_MINUTE
      hours = minutes / 60
      hours = Math.floor(hours * 100) / 100
      total = $scope.selectedTicket[0].total + hours
      $scope.selectedTicket[0].total = Math.floor(total * 100) / 100
      conf =
        issueId:    $scope.selectedTicket[0].id
        hours:      hours
        comment:    $scope.comment
        activityId: $scope.selectedActivity[0].id
      url = $scope.selectedTicket[0].url
      account = $scope.projects[url].account
      redmine = Redmine.get(account)
      redmine.submitTime(conf, submitSuccess, submitError)
      Message.toast Resource.string("msgSubmitTimeEntry").format($scope.selectedTicket[0].subject, hours)
    else
      Message.toast Resource.string("msgShortTime")


  ###
   show success message.
  ###
  submitSuccess = (msg) ->
    if msg?.time_entry?.id?
      Message.toast Resource.string("msgSubmitTimeSuccess")
    else
      submitError msg


  ###
   show failed message.
  ###
  submitError = (msg) ->
    Message.toast Resource.string("msgSubmitTimeFail")

