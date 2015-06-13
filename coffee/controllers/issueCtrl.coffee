timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, DataAdapter, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.issues   = []

  # data
  $scope.data = DataAdapter

  # typeahead data
  $scope.queryData = null

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
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, () ->
      loadIssuesFirstPage()

   # on change selected Query, set query to project, and load issues.
    DataAdapter.addEventListener DataAdapter.SELECTED_QUERY_CHANGED, () ->
      setQueryAndloadIssues()


  ###
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher(DataAdapter.queries, ['name', 'id'])
      templates:
        suggestion: (n) -> "<div><span class='select-activity__name'>#{n.name}</span><span class='select-activity__id'>#{n.id}</span></div>"


  ###
   on change selected Query, set query to project, and udpate issues.
  ###
  setQueryAndloadIssues = () ->
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
