timeTracker.controller('IssueCtrl', ['$scope', '$http', '$resource', '$account', "$message", ($scope, $http, $resource, $account, $message ) ->

  resource = {"resource": "issues.json"}
  CONTENT_TYPE = "application/json"
  AJAX_TIME_OUT = 30 * 1000
  $scope.accounts = []
  $scope.projects = []


  ###
   load project
  ###
  init = () ->
    $account.getAccounts (accounts) ->
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


  ###
   show loaded project.
  ###
  loadProjectSuccess = (msg) ->
    if msg.projects?
      msg.projects = for prj in msg.projects
        prj.account = $scope.accounts[0]
        prj
      $scope.projects = msg.projects
      $scope.selectedProject = msg.projects[0]
    else
      loadProjectError msg


  ###
   show fail message.
  ###
  loadProjectError = (msg) ->
    $message.toast "Load Project Failed."


  ###
   add selected project
  ###
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
