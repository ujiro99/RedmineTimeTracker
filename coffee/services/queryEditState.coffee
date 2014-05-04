timeTracker.factory "QueryEditState", ($window, Project, Redmine, Message, Resource) ->

  ###
   controller for issue edit mode.
  ###
  class QueryEditState

    constructor: (@$scope) ->

    ###
     on user selected item.
    ###
    onClickItem: (item) ->
      if @$scope.selected[0].queryId is item.id
        queryId = undefined
      else
        queryId = item.id
      Project.setParam @$scope.selected[0].url, @$scope.selected[0].id, { queryId: queryId }


    ###
     filter issues by searchField.text and item.project_id.
    ###
    listFilter: (item) =>
      if @$scope.searchField.text.isBlank()
        matchText = true
      else
        matchText = (item.id + "").contains(@$scope.searchField.text) or
          item.name.toLowerCase().contains(@$scope.searchField.text.toLowerCase())
      if item.project_id?
        matchProject = item.project_id is @$scope.selected[0].id
      else
        matchProject = true
      return matchText and matchProject


    ###
     calculate tooltip position.
    ###
    onMouseMove: (e) =>
      if e.clientY > $window.innerHeight / 2
        @$scope.tooltipPlace = 'top'
      else
        @$scope.tooltipPlace = 'bottom'


    ###
     load queries.
    ###
    load: (page) ->
      page = @currentPage if not page?
      if not @$scope.selected[0]?
        @$scope.queries.clear()
        return
      account = (a for a in @$scope.accounts when @$scope.selected[0].url is a.url)[0]
      params =
        page: page
        limit: @$scope.itemsPerPage
      Redmine.get(account).loadQueries(params)
        .success(@loadSuccess)
        .error(@loadError)


    loadSuccess: (data) =>
      return if not @$scope.selected[0]
      return if @$scope.selected[0].url isnt data.url
      return if @currentPage - 1 isnt data.offset / data.limit
      @$scope.totalItems = data.total_count
      @$scope.queries = data.queries


    loadError: (data, status) =>
      if status is 0 then return
      Message.toast Resource.string("msgLoadIssueFail")


  return QueryEditState
