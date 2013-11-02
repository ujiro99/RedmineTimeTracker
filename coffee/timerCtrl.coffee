timeTracker.controller('TimerCtrl', ['$scope', '$account', '$redmine', '$ticket', '$message', ($scope, $account, $redmine, $ticket, $message) ->

  # ONE_MINUTE = 1000 * 60
  ONE_MINUTE = 1000 * 5 # for develop
  COMMENT_MAX = 255

  hours = 0
  start = null

  $scope.isTracking = false
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX
  $scope.clickSubmitButton = ->


  ###
   get data from sync Storage, then init.
  ###
  init = ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      url    = accounts[0].url
      apiKey = accounts[0].apiKey
      userId = accounts[0].userId
      $scope.clickSubmitButton = -> onClickSubmit(url, apiKey, userId)
      $redmine(url, apiKey).issues.getOnUser(userId, successGetIssues)


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
   Start or End Time tracking
  ###
  onClickSubmit = (url, apiKey, userId) ->
    if $scope.isTracking
      $scope.isTracking = false
      end = new Date()
      millisec = end.getTime() - start.getTime()
      if millisec > ONE_MINUTE
        hours = millisec / 1000 / 60 / 60
        $redmine(url, apiKey).issues.submitTime(userId, $scope.comment, hours, submitSuccess, submitError)
        $message.toast "Submitting #{$scope.selectedTicket[0].subject}: #{hours} hr"
      else
        $message.toast 'Too short time entry.'
    else
      $scope.isTracking = true
      start = new Date()


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
   Initialize
  ###
  init()

])
