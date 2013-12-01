timeTracker.controller 'IssueCtrl', ($scope, $window, $redmine, $account, $ticket, $message, state) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $scope.projects = []
  $scope.selectedProject = []
  $scope.searchText = ''
  $scope.tooltipPlace = 'top'


  ###
   on account changed, start getting project and issues.
  ###
  $scope.$on 'accountChanged', () ->
    loadProject()


  $scope.$on 'accountRemoved', (e, url) ->
    removeProject url


  ###
   load project.
  ###
  loadProject = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      for account in accounts
        for project in $redmine(account).getProjects() or []
          found = $scope.projects.some (prj) ->
            prj.account.url is account.url and prj.id is project.id
          if not found
            $scope.projects.push project
      if not $scope.selectedProject[0]
        $scope.selectedProject[0] = $scope.projects[0]


  ###
   load issues according selected project.
  ###
  loadIssues = ->
    if $scope.selectedProject.length is 0 then return
    account = $scope.selectedProject[0].account
    projectId = $scope.selectedProject[0].id
    $redmine(account).getIssuesOnProject(projectId, loadIssuesSuccess, loadIssuesError)


  ###
   on loading success, update issue list
  ###
  loadIssuesSuccess = (data) ->
    for issue in data.issues
      for t in $ticket.get() when issue.equals t
        issue.show = t.show
    $scope.issues = data.issues


  removeProject = (url) ->
    $scope.projects = (prj for prj in $scope.projects when prj.account.url isnt url)
    $scope.selectedProject[0] = $scope.projects[0]


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


  ###
   calculate tooltip position.
  ###
  $scope.onMouseMove = (e) ->
    if e.clientY > $window.innerHeight / 2
      $scope.tooltipPlace = 'top'
    else
      $scope.tooltipPlace = 'bottom'
