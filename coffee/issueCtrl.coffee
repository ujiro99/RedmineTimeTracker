timeTracker.controller('IssueCtrl', ['$scope', '$redmine', '$account', '$ticket', "$message", ($scope, $redmine, $account, $ticket, $message ) ->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

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
    sameUrlTickets = (ticket for ticket in $ticket.tickets when ticket.url is url)
    for issue in data.issues
      for ticket in sameUrlTickets when issue.id is ticket.id
        issue.show = ticket.show isnt SHOW.NOT
        break
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
    found = $ticket.tickets.some (ticket) ->
      if issue.url is ticket.url and issue.id is ticket.id
        ticket.show = SHOW.SHOW
        issue.show = true
        return true
    if not found then $ticket.tickets.push issue
    $message.toast "#{issue.subject} added"


  ###
   remove selected issue.
  ###
  $scope.onClickIssueRemove = (issue) ->
    for ticket in $ticket.tickets
      if issue.url is ticket.url and issue.id is ticket.id
        ticket.show = SHOW.NOT
        issue.show = false
        break
    for ticket in $ticket.tickets when ticket.show is SHOW.SHOW
      $scope.selectedTicket = ticket
      break
    $message.toast "#{issue.subject} removed"


  ###
   execute initialize.
  ###
  init()

])
