timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, DataAdapter, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.queries  = []
  $scope.issues   = []

  # data
  $scope.data = DataAdapter

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
    $scope.editState = new IssueEditState($scope)
    initializeSearchform()

    # on change selected Project, load issues and queries.
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, (project) ->
      if not project?
        $scope.queries.clear()
        return

      # load issues
      loadIssuesFirstPage()

      account = DataAdapter.selectedAccount
      if account and account.url
        params =
          page: 1
          limit: 50
        Redmine.get(account).loadQueries(params)
          .success(_updateQuery)
          .error(_errorLoadQuery)


  ###
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher($scope.queries, 'name')


  ###
   update query by redmine's data.
  ###
  _updateQuery = (data) =>
    return if not DataAdapter.selectedProject
    return if DataAdapter.selectedProject.url isnt data.url
    newQueries = []
    newQueries.push {id: QUERY_ALL_ID, name: 'All'}
    for query in data.queries
      # filter the project-specific query
      if query.project_id
        if query.project_id is DataAdapter.selectedProject.id
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
    if not DataAdapter.selectedProject then return
    if not DataAdapter.selectedQuery then return

    targetId  = DataAdapter.selectedProject.id
    targetUrl = DataAdapter.selectedProject.url
    queryId = DataAdapter.selectedQuery.id
    if queryId is QUERY_ALL_ID then queryId = undefined
    DataAdapter.selectedProject.queryId = queryId
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
