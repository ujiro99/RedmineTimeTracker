timeTracker.controller 'IssueCtrl', ($scope, $window, Project, DataAdapter, Option, Analytics, IssueLoader, Const, State) ->

  # data
  $scope.data = DataAdapter
  # constant variables.
  $scope.Const = Const
  # options. using in pagination.
  $scope.options = Option.getOptions()
  # search parameters.
  $scope.searchParam = { text: '', onlyContained: false }
  # issue list's current page
  $scope.pageParam = { currentPage: 1 }
  # where does tooltip show.
  $scope.tooltipPlace = 'top'
  # is search field collapse.
  $scope.isCollapseParameters = true
  # flag for loading icon.
  $scope.isLoadingVisible = true
  # typeahead data.
  $scope.queryData = null
  # typeahead options
  $scope.typeaheadOptions = { highlight: true, minLength: 0 }
  # property filter's tab state.
  $scope.tabState = {}
  # provide functions for issue loading.
  $scope.loader = new IssueLoader($scope)
  # global state.
  $scope.state = State


  ###*
   Initialize.
  ###
  init = () ->
    initializeSearchform()
    # on change selected Project, load issues and queries.
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, () ->
      $scope.loader.loadIssues()
   # on change selected Query, set query to project, and load issues.
    DataAdapter.addEventListener DataAdapter.SELECTED_QUERY_CHANGED, () ->
      $scope.loader.setQueryAndloadIssues()
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_UPDATED, () ->
      $scope.$apply()


  ###*
   Initialize.
  ###
  initializeSearchform = () ->
    # query
    $scope.queryData =
      displayKey: 'name'
      source: util.substringMatcher(DataAdapter.queries, ['name', 'id'])
      templates:
        suggestion: (n) -> "<div class='list-item'><span class='list-item__name'>#{n.name}</span><span class='list-item__description list-item__id'>#{n.id}</span></div>"


  ###*
   Open or collapse search form. And initialize tab state.
  ###
  $scope.toggleSearchForm = () ->
    $scope.isCollapseParameters = !$scope.isCollapseParameters
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
   on change currentPage, start loading.
  ###
  $scope.$watch 'pageParam.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.isLoadingVisible = false
    $scope.loader.loadAllTicketOnProject()


  ###
   check item was contained in selectableTickets.
  ###
  $scope.isContained = (item) ->
    return DataAdapter.tickets.some (e) -> item.equals e


  ###
   on user selected item.
  ###
  $scope.onClickItem = (item) ->
    if not $scope.isContained(item)
      Message.toast Resource.string("msgAdded").format(item.text)
    else
      Message.toast Resource.string("msgRemoved").format(item.text)
    DataAdapter.toggleIsTicketShow item


  ###
   open link on other window.
  ###
  $scope.openLink = (url) ->
    a = document.createElement('a')
    a.href = url
    a.target='_blank'
    a.click()


  ###
   calculate tooltip position.
  ###
  $scope.onMouseMove = (e) ->
    if e.clientY > $window.innerHeight / 2
      $scope.tooltipPlace = 'top'
    else
      $scope.tooltipPlace = 'bottom'


  ###
   Start Initialize.
  ###
  init()
