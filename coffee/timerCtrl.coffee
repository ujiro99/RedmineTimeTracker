timeTracker.controller('TimerCtrl', ['$scope', '$http', '$account', '$message', ($scope, $http, $account, $message) ->

  ASSIGNED_ISSUES = "/issues.json?status_id=open&assigned_to_id="
  CONTENT_TYPE = "application/json"
  # ONE_MINUTE = 1000 * 60
  ONE_MINUTE = 1000 * 5 # for develop
  COMMENT_MAX = 255
  AJAX_TIME_OUT = 30 * 1000

  postData =
    "time_entry":
      "issue_id": 0
      "hours": 0
      "activity_id": 8
      "comments": ""

  hours = 0
  start = null

  $scope.isTracking = false
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX
  $scope.message = ""
  $scope.clickSubmitButton = ->


  ###
   get data from sync Storage, then init.
  ###
  init = ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      host   = accounts[0].host
      apiKey = accounts[0].apiKey
      userId = accounts[0].userId
      $scope.$apply ->
        loadOpenAssignedIssues(host, apiKey, userId)
        $scope.clickSubmitButton = -> onClickSubmit(host, apiKey, userId)


  ###
   Load tickets associated to user ID.
  ###
  loadOpenAssignedIssues = (host, apiKey, userId) ->
    console.log "load open assigned issues for " + userId
    config =
      method: "GET"
      url: host + ASSIGNED_ISSUES + userId
      headers:
        "X-Redmine-API-Key": apiKey
        "Content-Type": CONTENT_TYPE
      timeout: AJAX_TIME_OUT
    $http(config)
      .success(setSelectOptions)


  ###
   Set options to the issue select form.
  ###
  setSelectOptions = (res) ->
    if res?.issues?
      $scope.tickets = res.issues
      $scope.selectedTicket = res.issues[0]


  ###
   Start or End Time tracking
  ###
  onClickSubmit = (host, apiKey, userId) ->
    if $scope.isTracking
      $scope.isTracking = false
      end = new Date()
      millisec = end.getTime() - start.getTime()
      if millisec > ONE_MINUTE
        hours = millisec / 1000 / 60 / 60
        submitTimeEntry(host, apiKey, userId, hours)
        $message.toast "Submitting #{$scope.selectedTicket.subject} : #{hours} hr"
      else
        $message.toast 'Too short time entry.'
    else
      $scope.isTracking = true
      start = new Date()


  ###
   submit to redmine server.
  ###
  submitTimeEntry = (host, apiKey, userId, hours) ->
    postData.time_entry.issue_id = $scope.selectedTicket.id
    postData.time_entry.hours = hours
    postData.time_entry.comments = $scope.comment

    config =
      method: "POST"
      url: host + "/issues/#{postData.time_entry.issue_id}/time_entries.json"
      headers:
        "X-Redmine-API-Key": apiKey
        "Content-Type": CONTENT_TYPE
      data: JSON.stringify(postData)
      timeout: AJAX_TIME_OUT

    $http(config)
      .success(submitSuccess)
      .error(submitError)


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
