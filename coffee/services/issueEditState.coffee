timeTracker.factory "IssueEditState", ($window, Ticket, Redmine, State, Message, Resource, BaseEditState) ->

  ###
   controller for issue edit mode.
  ###
  class IssueEditState extends BaseEditState

    constructor: (@$scope) ->
      super()
      @listData = Ticket
      @$scope.selected = @$scope.selectedProject


    removeItem: (item) ->
      selected = @listData.getSelected()[0]
      if State.isTracking and item.equals selected
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    load: (page) ->
      page = @currentPage if not page?
      if not @$scope.selectedProject?
        @$scope.issues.clear()
        return
      account = (a for a in @$scope.accounts when @$scope.selectedProject.url is a.url)[0]
      if not (account and account.url) then return
      projectId = @$scope.selectedProject.id
      params =
        page: page
        limit: @itemsPerPage
        query_id: @$scope.selectedProject.queryId
      Redmine.get(account).getIssuesOnProject(projectId, params, @loadSuccess, @loadError)


    loadSuccess: (data) =>
      return if not @$scope.selectedProject
      return if @$scope.selectedProject.url isnt data.url
      return if @currentPage - 1 isnt data.offset / data.limit
      @$scope.totalItems = data.total_count
      for issue in data.issues
        for t in Ticket.get() when issue.equals t
          issue.show = t.show
      @$scope.issues.set(data.issues)


    loadError: (data, status) =>
      if status is BaseEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
