timeTracker.factory "IssueLoader", ($window, Redmine, DataAdapter, Message, Resource, Const, State) ->

  ###*
   Service for loading issues from redmine.
   @class IssueLoader
  ###
  class IssueLoader

    # http request canceled.
    @STATUS_CANCEL : 0
    # don't use query
    @QUERY_ALL_ID = 0


    ###*
     Constructor
     @constructor
    ###
    constructor: () ->


    ###*
     Clear and load issues
    ###
    loadIssues: () ->
      State.isLoadingVisible = true
      DataAdapter.selectedProject.tickets.clear()
      @loadAllTicketOnProject()


    ###*
     On change selected Query, set query to project, and udpate issues.
    ###
    setQueryAndloadIssues: () ->
      if not DataAdapter.selectedProject then return
      if not DataAdapter.selectedQuery then return
      targetId  = DataAdapter.selectedProject.id
      targetUrl = DataAdapter.selectedProject.url
      queryId   = DataAdapter.selectedQuery.id
      if queryId is IssueLoader.QUERY_ALL_ID then queryId = undefined
      DataAdapter.selectedProject.queryId = queryId
      @loadIssues()


    ###*
     Load all issues from Redmine on selected Project.
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


    ###*
     load remaining data.
    ###
    loadRemain: (data) =>
      return if not data

      storedCount = DataAdapter.selectedProject.tickets.length
      remainCount = data.total_count - storedCount
      DataAdapter.selectedProject.ticketCount = data.total_count

      # remaining tickets was already stored.
      return if remainCount is 0

      # remaining tickets was already loaded.
      @loadSuccess(data)
      return if remainCount <= data.issues.length

      # load remain.
      Redmine.get(DataAdapter.selectedAccount)
        .getIssuesRange(data.params, data.issues.length, remainCount)


    ###*
     Update issues.
    ###
    loadSuccess: (data) =>
      return if not data
      return if not DataAdapter.selectedProject
      return if DataAdapter.selectedProject.url isnt data.url

      # merge issues status.
      for issue in data.issues
        saved = DataAdapter.tasks.find (n) -> n.equals(issue)
        saved and issue.show = saved.show

      # merge arrays and set.
      tickets = DataAdapter.selectedProject.tickets.union(data.issues)
      DataAdapter.selectedProject.tickets.set(tickets)
      State.isLoadingVisible = false


    ###*
     Show error message.
    ###
    loadError: (data, status) =>
      if status is IssueLoader.STATUS_CANCEL then return
      State.isLoadingVisible = false
      Message.toast Resource.string("msgLoadIssueFail")


  return IssueLoader
