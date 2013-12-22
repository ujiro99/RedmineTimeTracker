timeTracker.controller 'IssueCtrl', ($scope, $window, Redmine, Ticket, Message, State) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  $scope.issues = []
  $scope.projects = []
  $scope.selectedProject = []
  $scope.searchText = ''
  $scope.tooltipPlace = 'top'


  ###
   on project added, show project.
  ###
  $scope.$on 'projectsAdded', (e, projects) ->
    for prj in projects
      addProject prj


  ###
   start getting issues.
  ###
  $scope.$on 'accountAdded', (e, account) ->
    Redmine.get(account).getIssuesOnUser(getIssuesSuccess)


  ###
   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    removeProject url


  ###
   add project.
   if project already exists, it will be overwritten.
  ###
  addProject = (project) ->
    for prj, i in $scope.projects
      if prj.account.url is project.account.url and prj.id is project.id
        $scope.projects.splice i, 1
        break
    $scope.projects.push project
    if not $scope.selectedProject[0]
      $scope.selectedProject[0] = $scope.projects[0]


  ###
   add assigned issues.
  ###
  getIssuesSuccess = (data) ->
    if not data? then return
    Ticket.addArray data.issues
    Ticket.sync()


  ###
   on loading success, update issue list
  ###
  loadIssuesSuccess = (data) ->
    for issue in data.issues
      for t in Ticket.get() when issue.equals t
        issue.show = t.show
    $scope.issues = data.issues


  ###
   show fail message.
  ###
  loadIssuesError = () ->
    Message.toast 'Failed to load issues'


  ###
   remve project and tikcets.
  ###
  removeProject = (url) ->
    $scope.projects = (prj for prj in $scope.projects when prj.account.url isnt url)
    $scope.selectedProject[0] = $scope.projects[0]
    Ticket.removeUrl url
    Message.toast(url + ' removed.')


  ###
   on project selection change, load issue on the project.
  ###
  $scope.$watch 'selectedProject[0]', ->
    loadIssues()


  ###
   load issues according selected project.
  ###
  loadIssues = ->
    if $scope.selectedProject.length is 0 then return
    if not $scope.selectedProject[0]?
      $scope.issues.clear()
      return
    account = $scope.selectedProject[0].account
    projectId = $scope.selectedProject[0].id
    Redmine.get(account).getIssuesOnProject(projectId, loadIssuesSuccess, loadIssuesError)


  ###
   on user selected issue.
   if ticket is being tracked, it will not be removed.
  ###
  $scope.onClickIssue = (issue) ->
    if $scope.isContained(issue)
      selected = Ticket.getSelected()[0]
      if State.isTracking and issue.equals selected
        Message.toast issue.subject + ' is being tracked now.'
        return
      removeIssue(issue)
    else
      addIssue(issue)


  ###
   open issue page on redmien.
  ###
  $scope.openIssue = (issue) ->
    openLink issue.url + '/issues/' + issue.id


  ###
   open link on other window.
  ###
  openLink = (url) ->
    a = document.createElement('a')
    a.href = url
    a.target='_blank'
    a.click()


  ###
   add selected issue.
  ###
  addIssue = (issue) ->
    issue.show = SHOW.SHOW
    Ticket.add issue
    Ticket.setParam issue.url, issue.id, {show: SHOW.SHOW}
    Message.toast "#{issue.subject} added"


  ###
   remove selected issue.
  ###
  removeIssue = (issue) ->
    issue.show = SHOW.NOT
    Ticket.setParam issue.url, issue.id, {show: SHOW.NOT}
    Message.toast "#{issue.subject} removed"


  ###
   check issue was contained in selectableTickets.
  ###
  $scope.isContained = (issue) ->
    selectable = Ticket.getSelectable()
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


