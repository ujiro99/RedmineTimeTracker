timeTracker.controller 'ProjectCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, Resource, Analytics, ProjectEditState) ->

  $scope.accounts = []
  $scope.projects = []
  $scope.projectsInList = []
  $scope.searchField = text: ''
  $scope.selected = []
  $scope.selectedAccount = []
  $scope.totalItems = 0
  $scope.itemsPerPage = 25

  # controller for edit list
  $scope.editState = new ProjectEditState($scope)

  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts = accounts
      $scope.selectedAccount[0] = $scope.accounts[0]
    $scope.projects = Project.getSelectable()


  ###
   start getting issues.
  ###
  $scope.$on 'accountAdded', (e, account) ->
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


  ###
   on change selected, start loading.
  ###
  $scope.$watch 'selected[0]', () ->
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change editState.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', () ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   Start Initialize.
  ###
  init()
