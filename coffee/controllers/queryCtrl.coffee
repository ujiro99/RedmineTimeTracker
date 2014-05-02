timeTracker.controller 'QueryCtrl', ($scope, Account, Project, Message, State, Resource, Analytics, QueryEditState) ->

  $scope.accounts = []
  $scope.searchField = text: ''
  $scope.selectable = []
  $scope.selected = []
  $scope.state = State
  $scope.queries = [[]]
  $scope.tooltipPlace = 'top'
  $scope.itemsPerPage = 25
  $scope.totalItems = 0


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts = accounts
    $scope.selectable = Project.getSelectable()
    $scope.editState = new QueryEditState($scope)


  ###
   remove project
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    # remove selectable project on url
    newPrjs = (p for p, i in $scope.selectable when p.url isnt url)
    $scope.selectable.clear()
    for p in newPrjs then $scope.selectable.push p
    if $scope.selected[0]?.url is url
      $scope.selected[0] = $scope.selectable[0]


  ###
   on change selected url, start loading.
  ###
  $scope.$watch 'selected[0].url', () ->
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   on change selectable project, update selected.
  ###
  $scope.$watch 'selectable', () ->
    if $scope.selectable.length is 0
      $scope.selected.clear()
      return
    isSelectable = $scope.selectable.some (ele) -> ele.equals($scope.selected[0])
    if not isSelectable
      $scope.selected[0] = $scope.selectable[0]
  , true


  ###
   Start Initialize.
  ###
  init()
