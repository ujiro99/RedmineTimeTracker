timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, IssueEditState) ->

  $scope.accounts = []
  $scope.issues = []
  $scope.itemsPerPage = 25
  $scope.projects = []
  $scope.searchField = text: ''
  $scope.selected = []
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
    $scope.projects = Project.getSelectable()
    $scope.editState = new IssueEditState($scope)


  ###
   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
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
   Start Initialize.
  ###
  init()
