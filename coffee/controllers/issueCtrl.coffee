timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.accounts = []
  $scope.queries  = []
  $scope.issues   = []

  # selected
  $scope.selectedProject = {}
  $scope.selectedQuery   = {}

  # typeahead data
  $scope.queryData   = null

  $scope.searchField = text: ''
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0
  $scope.state = State

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0

  # http request canceled.
  STATUS_CANCEL = 0

  # don't use query
  QUERY_ALL_ID = 'All'


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts.set(accounts)
      $scope.selectedAccount = $scope.accounts[0]
      $scope.editState = new IssueEditState($scope)
      initializeSearchform()


  ###
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher($scope.queries, 'name')


  ###
   on change selected Project, load issues and queries.
  ###
  $scope.$watch 'selectedProject', (newVal) ->
    if not newVal
      $scope.queries.clear()
      return

    # load issues
    loadIssuesFirstPage()

    account = $scope.selectedAccount
    if account and account.url
      params =
        page: 1
        limit: 50
      Redmine.get(account).loadQueries(params)
        .success(_updateQuery)
        .error(_errorLoadQuery)


  ###
   update query by redmine's data.
  ###
  _updateQuery = (data) =>
    return if not $scope.selectedProject
    return if $scope.selectedProject.url isnt data.url
    newQueries = []
    newQueries.push {id: QUERY_ALL_ID, name: 'All'}
    for query in data.queries
      # filter the project-specific query
      if query.project_id
        if query.project_id is $scope.selectedProject.id
          newQueries.push query
      else
        newQueries.push query
    $scope.queries.set(newQueries)


  ###
   show error messaga.
  ###
  _errorLoadQuery = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadQueryFail")


  ###
   on change selected Query, set query to project, and udpate issues.
  ###
  $scope.$watch 'selectedQuery.id', (newVal) ->
    if not $scope.selectedProject then return
    if not $scope.selectedQuery then return

    targetId  = $scope.selectedProject.id
    targetUrl = $scope.selectedProject.url
    queryId = $scope.selectedQuery.id
    if queryId is QUERY_ALL_ID then queryId = undefined
    $scope.selectedProject.queryId = queryId
    Project.setParam(targetUrl, targetId, { 'queryId': queryId })
    loadIssuesFirstPage()


  # load issues on P.1
  loadIssuesFirstPage = () ->
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   Start Initialize.
  ###
  init()
