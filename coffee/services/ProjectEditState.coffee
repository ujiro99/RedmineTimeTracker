timeTracker.factory "ProjectEditState", (Project, Ticket, Redmine, State, Message, Resource, BaseEditState) ->

  ###
   controller for project edit mode.
  ###
  class ProjectEditState extends BaseEditState

    constructor: (@$scope) ->
      super()
      @listData = Project
      @$scope.selected = @$scope.selectedAccount


    removeItem: (item) ->
      selected = Ticket.getSelected()[0]
      if State.isTracking and item.url is selected.url
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    load: (page) ->
      page = @currentPage if not page?
      if not @$scope.selectedAccount[0]?
        @$scope.projectsInList.clear()
        return
      account = @$scope.selectedAccount[0]
      params =
        page: page
        limit: @$scope.itemsPerPage
      Redmine.get(account).loadProjects @loadSuccess, @loadError, params


    loadSuccess: (data) =>
      return if not @$scope.selectedAccount[0]
      return if @$scope.selectedAccount[0].url isnt data.url
      return if @currentPage - 1 isnt data.offset / data.limit
      @$scope.totalItems = data.total_count
      if data.projects?
        @$scope.projectsInList = data.projects
      else
        @loadError data


    loadError: (data, status) ->
      if status is STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadFail")


  return ProjectEditState
