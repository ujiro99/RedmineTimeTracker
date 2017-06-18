timeTracker.controller 'IssueCtrl', ($scope, $window, Project, DataAdapter, Option, Analytics, RedmineLoader, Const, State, Message, Resource) ->

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
  # typeahead data.
  $scope.queryData = null
  # typeahead options
  $scope.typeaheadOptions = { highlight: true, minLength: 0 }
  # property filter's tab state.
  $scope.tabState = {}
  # provide functions for issue loading.
  $scope.loader = RedmineLoader
  # global state.
  $scope.state = State


  ###*
   Initialize.
  ###
  init = () ->
    initializeSearchform()
    # on change selected Project, load issues and queries.
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, () ->
      $scope.loader.fetchIssues()
    # on change selected Query, set query to project, and load issues.
    DataAdapter.addEventListener DataAdapter.SELECTED_QUERY_CHANGED, () ->
      $scope.loader.setQueryAndFetchIssues()


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
    State.isLoadingVisible = false
    $scope.loader.fetchAllTicketOnProject()


  ###
   check item was contained in selectable Tasks.
  ###
  $scope.isContained = (item) ->
    return DataAdapter.tasks.some (e) -> item.equals e


  ###
   on user selected item.
  ###
  $scope.onClickItem = (item) ->
    if not $scope.isContained(item)
      Message.toast Resource.string("msgAdded", item.text)
    else
      Message.toast Resource.string("msgRemoved", item.text)
    DataAdapter.toggleIsTicketShow item


  ###
   calculate tooltip position.
  ###
  $scope.onMouseMove = (e) ->
    if e.clientY > $window.innerHeight / 2
      $scope.tooltipPlace = 'top'
    else
      $scope.tooltipPlace = 'bottom'


  ###*
   Filter issues by searchParam.text and properties.
   @param {TicketModel} item - Issue to be judged.
   @return {bool} true: show, false: hide
  ###
  $scope.listFilter = (item) ->

    if $scope.searchParam.onlyContained
      return if not $scope.isContained(item)

    match = Const.ISSUE_PROPS.all (p) ->
      DataAdapter.selectedProject[p].some (n) ->
        return true if n.name is "All" and n.checked
        return false if not n.checked
        return item[p].id is (n.id|0)
    return false if not match

    if $scope.searchParam.text.isBlank() then return true
    return (item.id + "").contains($scope.searchParam.text) or
           item.text.toLowerCase().contains($scope.searchParam.text.toLowerCase())


  ###
   Start Initialize.
  ###
  init()
