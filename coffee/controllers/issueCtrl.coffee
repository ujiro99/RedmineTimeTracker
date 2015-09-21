timeTracker.controller 'IssueCtrl', ($scope, $window, Project, DataAdapter, Option, Analytics, IssueEditState, Const) ->

  # http request canceled.
  STATUS_CANCEL = 0
  # don't use query
  QUERY_ALL_ID = 0

  # data
  $scope.data = DataAdapter
  # constant variables.
  $scope.Const = Const
  # options. using in pagination.
  $scope.options = Option.getOptions()
  # search parameters.
  $scope.searchField = text: '', onlyContained: false
  # where does tooltip show.
  $scope.tooltipPlace = 'top'
  # is search field open.
  $scope.isOpen = false
  # typeahead data.
  $scope.queryData = null
  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0
  # property filter's tab state.
  $scope.tabState = {}
  # controll functions for issue list.
  $scope.editState = new IssueEditState($scope)

  ###
   Initialize.
  ###
  init = () ->
    initializeSearchform()

    # on change selected Project, load issues and queries.
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, () ->
      loadIssues()

   # on change selected Query, set query to project, and load issues.
    DataAdapter.addEventListener DataAdapter.SELECTED_QUERY_CHANGED, () ->
      setQueryAndloadIssues()

    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_UPDATED, () ->
      $scope.$apply()


  ###
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher(DataAdapter.queries, ['name', 'id'])
      templates:
        suggestion: (n) -> "<div class='list-item'><span class='list-item__name'>#{n.name}</span><span class='list-item__description list-item__id'>#{n.id}</span></div>"


  ###
   on change selected Query, set query to project, and udpate issues.
  ###
  setQueryAndloadIssues = () ->
    if not DataAdapter.selectedProject then return
    if not DataAdapter.selectedQuery then return
    targetId  = DataAdapter.selectedProject.id
    targetUrl = DataAdapter.selectedProject.url
    queryId   = DataAdapter.selectedQuery.id
    if queryId is QUERY_ALL_ID then queryId = undefined
    DataAdapter.selectedProject.queryId = queryId
    DataAdapter.selectedProject.tickets.clear()
    Project.setParam(targetUrl, targetId, { 'queryId': queryId })
    loadIssues()


  # load issues on P.1
  loadIssues = () ->
    $scope.editState.loadAllTicketOnProject()


  ###*
   Open or collapse search form. And initialize tab state.
  ###
  $scope.toggleSearchForm = () ->
    $scope.isOpen = !$scope.isOpen
    for prop in Const.ISSUE_PROPS
      $scope.tabState[prop] = false

  ###*
   toggle tab's hover class.
  ###
  $scope.toggleTabClass = (prop) ->
    $('#id_' + prop).toggleClass('hover')
    return false

  ###*
   on checkBox == All is clicked, change all property state.
   on checkBox != All is clicked, change All's property state.
  ###
  $scope.clickCheckbox = (propertyName, option, $event) ->
    if option.name is "All"
      DataAdapter.selectedProject[propertyName].map((p) -> p.checked = option.checked)
    else if option.checked is false
      DataAdapter.selectedProject[propertyName][0].checked = false
    else if DataAdapter.selectedProject[propertyName].slice(1).all((p) -> p.checked)
      DataAdapter.selectedProject[propertyName][0].checked = true

    $event.stopPropagation()

  ###*
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.loadAllTicketOnProject()


  ###
   Start Initialize.
  ###
  init()
