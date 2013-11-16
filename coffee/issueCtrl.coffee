timeTracker.controller('IssueCtrl', ['$scope', '$redmine', '$account', '$ticket', "$message", ($scope, $redmine, $account, $ticket, $message ) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $scope.accounts = []
  $scope.projects = []
  $scope.selectedProject = []
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
      $scope.selectedProject[0] = msg.projects[0]
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
    if $scope.selectedProject.length is 0 then return
    url = $scope.selectedProject[0].account.url
    apiKey = $scope.selectedProject[0].account.apiKey
    projectId = $scope.selectedProject[0].id
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
  $scope.$watch 'selectedProject[0]', ->
    loadIssues()


  ###
   on user selected issue.
  ###
  $scope.onClickIssue = (issue) ->
    if $scope.isContained(issue)
      removeIssue(issue)
    else
      addIssue(issue)


  ###
   add selected issue.
  ###
  addIssue = (issue) ->
    issue.show = SHOW.SHOW
    $ticket.add issue
    $ticket.setParam issue.url, issue.id, {show: SHOW.SHOW}
    $message.toast "#{issue.subject} added"


  ###
   remove selected issue.
  ###
  removeIssue = (issue) ->
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
           item.subject.toLowerCase().contains($scope.searchText.toLowerCase())


  ###
   execute initialize.
  ###
  init()

])
