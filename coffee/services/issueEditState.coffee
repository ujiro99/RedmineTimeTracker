timeTracker.factory "IssueEditState", ($window, Redmine, DataAdapter, State, Message, Resource, BaseEditState, Log) ->

  ###
   controller for issue edit mode.
  ###
  class IssueEditState extends BaseEditState

    constructor: (@$scope) ->
      super()


    ###
     on click remove button, remove issue from selectable list.
    ###
    removeItem: (item) ->
      if State.isTracking and item.equals DataAdapter.selectedTicket
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    ###
     load all issues from Redmine on selected Project.
    ###
    loadAllTicketOnProject: () ->
      return if not DataAdapter.selectedProject
      params =
        query_id: DataAdapter.selectedProject.queryId
        project_id: DataAdapter.selectedProject.id
      redmine = Redmine.get(DataAdapter.selectedAccount)
      redmine.getIssuesOnProject(params.project_id, params).then(
        (data) =>
          return if not data?
          return if DataAdapter.selectedProject.tickets.length is data.total_count
          if data.total_count <= data.issues.length
            @loadSuccess(data)
            return
          start = 0
          end = data.total_count - DataAdapter.selectedProject.tickets.length
          redmine.getIssuesRange(params, start, end, @loadSuccess, @loadError)
      , @loadError)


    ###
     update issues.
    ###
    loadSuccess: (data) =>
      return if not DataAdapter.selectedProject
      return if DataAdapter.selectedProject.url isnt data.url
      for issue in data.issues
        saved = DataAdapter.tickets.find (n) -> n.equals(issue)
        saved and issue.show = saved.show
      tickets = DataAdapter.selectedProject.tickets.union(data.issues)
      DataAdapter.selectedProject.tickets.set(tickets)


    ###
     show error message.
    ###
    loadError: (data, status) =>
      if status is BaseEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
