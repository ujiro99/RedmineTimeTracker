timeTracker.controller('IssueCtrl', ['$scope', '$redmine', '$account', '$ticket', "$message", ($scope, $redmine, $account, $ticket, $message ) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $scope.accounts = []
  $scope.projects = []
  $scope.searchText = ''

  ###
   Initialize
  ###
  init = () ->
    loadProject()


  ###
   load project.
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
    for issue in data.issues
      for t in $ticket.get() when t.url is issue.url and t.id is issue.id
        issue.show = t.show
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
   add selected issue.
  ###
  $scope.onClickIssueAdd = (issue) ->
    issue.show = SHOW.SHOW
    $ticket.add issue
    $ticket.setParam issue.url, issue.id, {show: SHOW.SHOW}
    $message.toast "#{issue.subject} added"


  ###
   remove selected issue.
  ###
  $scope.onClickIssueRemove = (issue) ->
    issue.show = SHOW.NOT
    $ticket.setParam issue.url, issue.id, {show: SHOW.NOT}
    $message.toast "#{issue.subject} removed"


  ###
   check issue was contained in selectableTickets.
  ###
  $scope.isContained = (issue) ->
    selectable = $ticket.getSelectable()
    found = selectable.some (ele) ->
      return issue.id is ele.id and issue.url is ele.url
    return found


  ###
   filter issues by searchText.
  ###
  $scope.issueFilter = (item) ->
    if $scope.searchText.isBlank() then return true
    return (item.id + "").contains($scope.searchText) or
           item.subject.contains($scope.searchText)


  ###
   execute initialize.
  ###
  init()

])
