timeTracker.controller 'TimerCtrl', ($scope, $account, $redmine, $ticket, $message, state) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255

  $scope.state = state
  $scope.activities = []
  $scope.selectedActivity = []
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX

  _redmine = null


  ###
   get issues from redmine server.
  ###
  getIssues = ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      _redmine = $redmine(accounts[0])
      _redmine.issues.getOnUser(successGetIssues)
      _redmine.enumerations.getActivities(successGetActivities)



  ###
   merge ticket on strage, and update view
  ###
  successGetIssues = (data, status, headers, config) ->
    if not data?.issues? then return
    $ticket.addArray data.issues
    $scope.tickets = $ticket.getSelectable()
    $scope.selectedTicket = $ticket.getSelected()
    $ticket.sync()


  ###
   merge ticket on strage, and update view
  ###
  successGetActivities = (data, status, headers, config) ->
    if not data?.time_entry_activities? then return
    $scope.activities = for a in data.time_entry_activities
      a.text = a.name; a
    $scope.selectedActivity[0] = $scope.activities[0]


  ###
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    if state.isTracking
      state.isTracking = false
      $scope.$broadcast 'timer-stop'
    else
      state.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    if _redmine? and time.minutes >= ONE_MINUTE
      hours = time.minutes / 60
      hours = Math.floor(hours * 100) / 100
      $scope.selectedTicket[0].total += hours
      conf =
        issueId:    $scope.selectedTicket[0].id
        hours:      hours
        comment:    $scope.comment
        activityId: $scope.selectedActivity[0].id
      _redmine.issues.submitTime(conf, submitSuccess, submitError)
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


  ###
   on ticket loaded from crome storage, start getting issues.
  ###
  $scope.$on 'ticketLoaded', () ->
    getIssues()


  ###
   on account changed, start getting issues.
  ###
  $scope.$on 'accountChanged', () ->
    getIssues()

