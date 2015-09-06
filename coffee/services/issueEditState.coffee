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
        query_id:   DataAdapter.selectedProject.queryId
        project_id: DataAdapter.selectedProject.id
      Redmine.get(DataAdapter.selectedAccount)
        .getIssues(params)
        .then(@loadRemain, @loadError)
        .then(@loadSuccess, @loadError)


    ###
     load remaining data.
    ###
    loadRemain: (data) =>
      return if not data

      storedCount = DataAdapter.selectedProject.tickets.length
      remainCount = data.total_count - storedCount

      # remaining tickets was already stored.
      return if remainCount is 0

      # remaining tickets was already loaded.
      @loadSuccess(data)
      return if remainCount <= data.issues.length

      # load remain.
      Redmine.get(DataAdapter.selectedAccount)
        .getIssuesRange(data.params, data.issues.length, remainCount)


    ###
     update issues.
    ###
    loadSuccess: (data) =>
      return if not data
      return if not DataAdapter.selectedProject
      return if DataAdapter.selectedProject.url isnt data.url

      # merge issues status.
      for issue in data.issues
        saved = DataAdapter.tickets.find (n) -> n.equals(issue)
        saved and issue.show = saved.show

      # merge arrays and set.
      tickets = DataAdapter.selectedProject.tickets.union(data.issues)
      DataAdapter.selectedProject.tickets.set(tickets)


    ###
     show error message.
    ###
    loadError: (data, status) =>
      if status is BaseEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueEditState
