@timeTracker = angular.module('timeTracker', ['ngResource'])
timeTracker.factory("accountService", () ->

  ACCOUNTS = "ACCOUNTS"
  HOST     = "HOST"
  API_KEY  = "API_KEY"
  USER_ID  = "USER_ID"
  NULLFUNC = () ->

  return {

    getAccounts: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.get ACCOUNTS, (item) ->
        if chrome.runtime.lastError? or not item[ACCOUNTS]?
          callback null
        else
          callback item[ACCOUNTS]


    addAccount: (account, callback) ->
      if not account? then return
      callback = callback or NULLFUNC
      @getAccounts (accounts) ->
        accounts = accounts or []
        newArry = []
        for a in accounts when a.host isnt account.host
          newArry.push a
        accounts = newArry
        accounts.push account
        chrome.storage.sync.set ACCOUNTS: accounts, () ->
          if chrome.runtime.lastError?
            callback false
          else
            callback true


    clearAccount: (callback) ->
      callback = callback or NULLFUNC
      chrome.storage.sync.clear () ->
        if chrome.runtime.lastError?
          callback false
        else
          callback true
  }
)


timeTracker.factory("$message", ['$rootScope', ($rootScope) ->

  MESSAGE_DURATION = 2000

  return {
    toast: (msg, duration) ->
      duration = duration or MESSAGE_DURATION
      $rootScope.message = msg
      if not $rootScope.$$phase then $rootScope.$apply()
      setTimeout ->
        $rootScope.message = ""
        if not $rootScope.$$phase then $rootScope.$apply()
      , duration
  }
])

timeTracker.controller('MainCtrl', ['$rootScope', '$scope', ($rootScope, $scope) ->
  $rootScope.message = ""
  $scope.tickets = {}
])

timeTracker.controller('TimerCtrl', ['$scope', '$http', 'accountService', '$message', ($scope, $http, accountService, $message) ->

  ASSIGNED_ISSUES = "/issues.json?status_id=open&assigned_to_id="
  CONTENT_TYPE = "application/json"
  # ONE_MINUTE = 1000 * 60
  ONE_MINUTE = 1000 * 5
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
    accountService.getAccounts (accounts) ->
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
        $message.toast """start #{start.getHours()}:#{start.getMinutes()} end #{end.getHours()}:#{end.getMinutes()}: #{hours}"""
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


timeTracker.controller('IssueCtrl', ['$scope', '$http', '$resource', 'accountService', "$message", ($scope, $http, $resource, accountService, $message ) ->

  resource = {"resource": "issues.json"}
  CONTENT_TYPE = "application/json"
  AJAX_TIME_OUT = 30 * 1000
  $scope.accounts = []
  $scope.projects = []


  init = () ->
    accountService.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      $scope.accounts = accounts
      config =
        method: "GET"
        url: accounts[0].host + "/projects.json"
        headers:
          "X-Redmine-API-Key": accounts[0].apiKey
          "Content-Type": CONTENT_TYPE
        timeout: AJAX_TIME_OUT
      $http(config)
        .success(loadProjectSuccess)
        .error(loadProjectError)


  loadProjectSuccess = (msg) ->
    if msg.projects?
      msg.projects = for prj in msg.projects
        prj.account = $scope.accounts[0]
        prj
      $scope.projects = msg.projects
      $scope.selectedProject = msg.projects[0]
    else
      loadProjectError msg


  loadProjectError = (msg) ->
    $message.toast "Load Project Failed."


  $scope.onClickIssueAdd = ->
    Issue = $resource $scope.selectedProject.account.host + "/:resource"
    , resource
    , get:
        method: "GET"
        headers:
          "X-Redmine-API-Key": $scope.selectedProject.account.apiKey
          "Content-Type": CONTENT_TYPE
    res = Issue.get "project_id": $scope.selectedProject.id, () ->
      $message.toast res.issues[0].subject


  ###
   Initialize
  ###
  init()

])
