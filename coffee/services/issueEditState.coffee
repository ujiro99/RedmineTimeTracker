timeTracker.factory "IssueEditState", ($window, Ticket, Redmine, DataAdapter, State, Message, Resource, BaseEditState) ->

  ###
   controller for issue edit mode.
  ###
  class IssueEditState extends BaseEditState

    constructor: (@$scope) ->
      super()
      @listData = Ticket

    removeItem: (item) ->
      selected = @listData.getSelected()[0]
      if State.isTracking and item.equals selected
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
      console.log "total count: " + @$scope.totalItems
      for issue in data.issues
        for t in Ticket.get() when issue.equals t
          issue.show = t.show
      @$scope.issues.set(data.issues)


    loadError: (data, status) =>
      if status is BaseEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
