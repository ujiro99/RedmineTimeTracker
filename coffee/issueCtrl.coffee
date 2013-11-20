timeTracker.controller('IssueCtrl', ['$scope', '$redmine', '$account', '$ticket', "$message", 'state', ($scope, $redmine, $account, $ticket, $message, state ) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $scope.accounts = []
  $scope.projects = []
  $scope.selectedProject = []
  $scope.searchText = ''


  ###
   on ticket loaded, start getting project and issues.
  ###
  $scope.$on 'ticketLoaded', () ->
    loadProject()


  ###
   on account changed, start getting project and issues.
  ###
  $scope.$on 'accountChanged', () ->
    loadProject()


  ###
   load project.
  ###
  loadProject = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      $scope.accounts = accounts
      $redmine(accounts[0]).projects.get(loadProjectSuccess, loadProjectError)


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
    account = $scope.selectedProject[0].account
    projectId = $scope.selectedProject[0].id
    $redmine(account).issues.getOnProject(projectId, loadIssuesSuccess, loadIssuesError)


  ###
   on loading success, update issue list
  ###
  loadIssuesSuccess = (data) ->
    for issue in data.issues
      for t in $ticket.get() when issue.equals t
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
   if ticket is being tracked, it will not be removed.
  ###
  $scope.onClickIssue = (issue) ->
    if $scope.isContained(issue)
      selected = $ticket.getSelected()[0]
      if state.isTracking and issue.equals selected
        $message.toast issue.subject + ' is being tracked now.'
        return
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
    found = selectable.some (t) -> issue.equals t
    return found


  ###
   filter issues by searchText.
  ###
  $scope.issueFilter = (item) ->
    if $scope.searchText.isBlank() then return true
    return (item.id + "").contains($scope.searchText) or
           item.subject.toLowerCase().contains($scope.searchText.toLowerCase())

])
