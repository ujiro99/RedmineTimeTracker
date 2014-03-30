timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, BaseEditState, IssueEditState, ProjectEditState) ->

  STATUS_CANCEL = 0
  MODE = {ISSUE: "Issues", PROJECT: "Projects"}

  $scope.accounts = []
  $scope.issues = []
  $scope.itemsPerPage = 25
  $scope.mode = MODE.ISSUE
  $scope.projects = []
  $scope.projectsInList = []
  $scope.searchField = text: ''
  $scope.selected = []
  $scope.selectedAccount = []
  $scope.selectedProject = []
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0
  $scope.state = State


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts = accounts
      $scope.selectedAccount[0] = $scope.accounts[0]
    $scope.projects = Project.getSelectable()
    $scope.editState = new IssueEditState($scope)


  ###
   start getting issues.
  ###
  $scope.$on 'accountAdded', (e, account) ->
    Redmine.get(account).getIssuesOnUser(getIssuesSuccess)
    if not $scope.selectedAccount[0]
      $scope.selectedAccount[0] = $scope.accounts[0]


  ###
   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    # remove a account
    if $scope.selectedAccount[0]?.url is url
      $scope.selectedAccount[0] = $scope.accounts[0]
    # remove projects
    newPrjs = (p for p, i in $scope.projects when p.url isnt url)
    $scope.projects.clear()
    for p in newPrjs then $scope.projects.push p
    if $scope.selectedProject[0]?.url is url
      $scope.selectedProject[0] = $scope.projects[0]


  ###
   on change selected, start loading.
  ###
  $scope.$watch 'selected[0]', () ->
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   on change projects, update selected.
  ###
  $scope.$watch 'projects', () ->
    if $scope.projects.length is 0
      $scope.selectedProject.clear()
      return

    selected = $scope.selectedProject[0]
    if not selected?
      $scope.selectedProject[0] = $scope.projects[0]
      return

    found = $scope.projects.some (ele) -> ele.equals(selected)
    if not found
      $scope.selectedProject[0] = $scope.projects[0]
  , true


  ###
   add assigned issues and projects.
  ###
  getIssuesSuccess = (data) ->
    if not data? then return
    # show assigned project.
    activeProject = {}
    for i in data.issues
      activeProject[i.url] = activeProject[i.url] or {}
      activeProject[i.url][i.project.id] = true
    for url, ids of activeProject
      for id in Object.keys(ids)
        Project.setParam url, id - 0, {show: BaseEditState.SHOW.SHOW}
    # show assigned ticket.
    Ticket.addArray data.issues
    Ticket.sync()


  ###
   change edit mode.
  ###
  $scope.changeMode = () ->
    if $scope.mode is MODE.ISSUE
      $scope.mode = MODE.PROJECT
      $scope.editState = new ProjectEditState($scope)
    else
      $scope.mode = MODE.ISSUE
      $scope.editState = new IssueEditState($scope)


  ###
   Start Initialize.
  ###
  init()
