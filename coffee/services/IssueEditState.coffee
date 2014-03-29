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
      if not @$scope.selectedProject[0]?
        @$scope.issues.clear()
        return
      account = (a for a in @$scope.accounts when @$scope.selectedProject[0].url is a.url)[0]
      projectId = @$scope.selectedProject[0].id
      params =
        page: page
        limit: @$scope.itemsPerPage
      Redmine.get(account).getIssuesOnProject(projectId, params, @loadSuccess, @loadError)


    loadSuccess: (data) =>
      return if not @$scope.selectedProject[0]
      return if @$scope.selectedProject[0].url isnt data.url
      return if State.currentPage - 1 isnt data.offset / data.limit
      @$scope.totalItems = data.total_count
      for issue in data.issues
        for t in Ticket.get() when issue.equals t
          issue.show = t.show
      @$scope.issues = data.issues


    loadError: (data, status) ->
      if status is STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
