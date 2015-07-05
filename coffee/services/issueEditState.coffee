timeTracker.factory "IssueEditState", ($window, Redmine, DataAdapter, State, Message, Resource, BaseEditState) ->

  ###
   controller for issue edit mode.
  ###
  class IssueEditState extends BaseEditState

    constructor: (@$scope) ->
      super()

    removeItem: (item) ->
      if State.isTracking and item.equals DataAdapter.selectedTicket
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    load: (page) ->
      page = @currentPage if not page?
      if not DataAdapter.selectedProject?
        @$scope.issues.clear()
        return
      projectId = DataAdapter.selectedProject.id
      params =
        page: page
        limit: @$scope.options.itemsPerPage
        query_id: DataAdapter.selectedProject.queryId
      Redmine.get(DataAdapter.selectedAccount).getIssuesOnProject(projectId, params, @loadSuccess, @loadError)


    loadSuccess: (data) =>
      return if not DataAdapter.selectedProject
      return if DataAdapter.selectedProject.url isnt data.url
      return if @currentPage - 1 isnt data.offset / data.limit
      @$scope.totalItems = data.total_count
      console.log "ticket total count: " + @$scope.totalItems
      for issue in data.issues
        saved = DataAdapter.tickets.find (n) -> n.equals(issue)
        saved and issue.show = saved.show
      @$scope.issues.set(data.issues)


    loadError: (data, status) =>
      if status is BaseEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
