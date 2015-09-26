timeTracker.factory "IssueEditState", ($window, Redmine, DataAdapter, State, Message, Resource, Const, Log) ->

  ###
   controller for issue edit mode.
  ###
  class IssueEditState

    constructor: (@$scope) ->

    @STATUS_CANCEL : 0
    @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }
    currentPage: 1

    ###
     check item was contained in selectableTickets.
    ###
    isContained: (item) ->
      return DataAdapter.tickets.some (e) -> item.equals e


    ###
     on user selected item.
    ###
    onClickItem: (item) ->
      if not @isContained(item)
        Message.toast Resource.string("msgAdded").format(item.text)
      else
        Message.toast Resource.string("msgRemoved").format(item.text)
      DataAdapter.toggleIsTicketShow item


    ###
     open link on other window.
    ###
    openLink: (url) ->
      a = document.createElement('a')
      a.href = url
      a.target='_blank'
      a.click()


    ###
     calculate tooltip position.
    ###
    onMouseMove: (e) =>
      if e.clientY > $window.innerHeight / 2
        @$scope.tooltipPlace = 'top'
      else
        @$scope.tooltipPlace = 'bottom'


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
      @$scope.isLoadingVisible = false


    ###
     show error message.
    ###
    loadError: (data, status) =>
      if status is IssueEditState.STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


    ###
     filter issues by searchField.text and properties.
    ###
    listFilter: (item) =>

      if @$scope.searchField.onlyContained
        return if not @isContained(item)

      match = Const.ISSUE_PROPS.all (p) ->
        DataAdapter.selectedProject[p].some (n) ->
          return true if n.name is "All" and n.checked
          return false if not n.checked
          return item[p].id is (n.id|0)
      return false if not match

      if @$scope.searchField.text.isBlank() then return true
      return (item.id + "").contains(@$scope.searchField.text) or
             item.text.toLowerCase().contains(@$scope.searchField.text.toLowerCase())


  return IssueEditState
