timeTracker.controller('IssueCtrl', ['$scope', '$redmine', '$account', "$message", ($scope, $redmine, $account, $message ) ->

  $scope.accounts = []
  $scope.projects = []


  ###
   Initialize
  ###
  init = () ->
    loadProject()


  ###
   load project
  ###
  loadProject = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      $scope.accounts = accounts
      url = accounts[0].url
      apiKey = accounts[0].apiKey
      $redmine(url, apiKey).projects.get(loadProjectSuccess, loadProjectError)


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
      loadIssues()
    else
      loadProjectError msg


  ###
   show fail message.
  ###
  loadProjectError = (msg) ->
    $message.toast "Load Project Failed."


  ###
   load issues according selected project.
  ###
  loadIssues = ->
    url = $scope.selectedProject.account.url
    apiKey = $scope.selectedProject.account.apiKey
    projectId = $scope.selectedProject.id
    $redmine(url, apiKey).issues.getOnProject(projectId, loadIssuesSuccess, loadIssuesError)


  ###
   on loading success, update issue list
  ###
  loadIssuesSuccess = (data) ->
    url = $scope.selectedProject.account.url
    sameUrlTickets = (ticket for ticket in $scope.tickets when ticket.url is url)
    for issue in data.issues
      for ticket in sameUrlTickets
        issue.added = issue.added or (issue.id is ticket.id)
    $scope.issues = data.issues


  ###
   show fail message.
  ###
  loadIssuesError = () ->
    $message.toast 'Failed to load issues'


  ###
   on project selection change, load issue on the project.
  ###
  $scope.onProjectChange = ->
    loadIssues()


  ###
   add selected issue
  ###
  $scope.onClickIssueAdd = (issue) ->
    $message.toast issue.subject


  ###
   remove selected issue
  ###
  $scope.onClickIssueRemove = (issue) ->
    $message.toast issue.subject


  ###
   execute initialize
  ###
  init()

])
