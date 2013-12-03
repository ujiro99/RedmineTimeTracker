timeTracker.controller 'TimerCtrl', ($scope, $account, $redmine, $ticket, $message, state) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255

  $scope.state = state
  $scope.projects = {}
  $scope.selectedActivity = []
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX
  $scope.mode = "auto"
  $scope.tickets = []
  $scope.selectedTicket = []


  ###
   Initialize.
  ###
  init = () ->
    $account.getAccounts (accounts) ->
      if not accounts then return
      for account in accounts
        loadActivities account
      $scope.tickets = $ticket.getSelectable()
      $scope.selectedTicket = $ticket.getSelected()

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
    $redmine(account).getActivities(getActivitiesSuccess)


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
  ###
  $scope.changeMode = () ->
    if $scope.mode is "auto"
      $scope.mode = "manual"
    else
      $scope.mode = "auto"


  ###
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    if not $scope.selectedTicket[0] then return
    if state.isTracking
      state.isTracking = false
      $scope.$broadcast 'timer-stop'
    else
      state.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on clicked manual post button, send time entry.
  ###
  $scope.clickManual = () ->
    postEntry($scope.time.hours * 60)


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    postEntry(time.minutes)


  ###
   send time entry.
  ###
  postEntry = (minutes) ->
    if minutes >= ONE_MINUTE
      hours = minutes / 60
      hours = Math.floor(hours * 100) / 100
      $scope.selectedTicket[0].total += hours
      conf =
        issueId:    $scope.selectedTicket[0].id
        hours:      hours
        comment:    $scope.comment
        activityId: $scope.selectedActivity[0].id
      url = $scope.selectedTicket[0].url
      account = $scope.projects[url].account
      redmine = $redmine(account)
      redmine.submitTime(conf, submitSuccess, submitError)
      $message.toast "Submitting #{$scope.selectedTicket[0].subject}: #{hours} hr"
    else
      $message.toast 'Too short time entry.'


  ###
   show success message.
  ###
  submitSuccess = (msg) ->
    if msg?.time_entry?.id?
      $message.toast "Time Entry Saved."
    else
      submitError msg


  ###
   show failed message.
  ###
  submitError = (msg) ->
    $message.toast "Save Failed."

