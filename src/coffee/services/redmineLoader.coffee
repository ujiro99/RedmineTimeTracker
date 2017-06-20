timeTracker.factory "RedmineLoader", ($window, $q, Redmine, DataAdapter, Message, Resource, Const, State, Option, Log) ->

  ###*
   Service for loading issues from redmine.
   @class RedmineLoader
  ###
  class RedmineLoader

    # http request canceled.
    @STATUS_CANCEL: 0
    # don't use query
    @QUERY_ALL_ID: 0
    # http status.
    @NOT_FOUND: 404
    # http status.
    @UNAUTHORIZED: 401


    ###*
     Constructor
     @constructor
    ###
    constructor: () ->


    ###*
     Fetch all data from redmine.
     @param {AccountModel[]} accounts - Account to be fetched data.
     @return {Promise[]<undefined>} To be resolved when all fetching finished.
    ###
    fetchAllData: (accounts) =>
      Log.debug("fetchAllData() start")
      State.isLoadingAllData = true
      for a in accounts
        @_fetchActivities(a)
        @_fetchQueries(a)
        $q.all([@_fetchProjects(a), @_fetchStatuses(a)])
          .then(@_fetchSavedIssues(a))
          .then(@fetchTicketsCount(a))
          .then(()->
            State.isLoadingAllData = false
            Log.debug("fetchAllData() finish"))


    ###*
     Clear and fetch issues
     @return {Promise<undefined>} To be resolved when tickets fetched.
    ###
    fetchIssues: () ->
      State.isLoadingVisible = true
      DataAdapter.selectedProject.tickets.clear()
      @fetchAllTicketOnProject()


    ###*
     On change selected Query, set query to project, and udpate issues.
     @return {Promise<undefined>} To be resolved when tickets fetched.
    ###
    setQueryAndFetchIssues: () ->
      if not DataAdapter.selectedProject then return
      if not DataAdapter.selectedQuery then return
      targetId  = DataAdapter.selectedProject.id
      targetUrl = DataAdapter.selectedProject.url
      queryId   = DataAdapter.selectedQuery.id
      if queryId is RedmineLoader.QUERY_ALL_ID then queryId = undefined
      DataAdapter.selectedProject.queryId = queryId
      @fetchIssues()


    ###*
     Fetch all issues from Redmine on selected Project.
     @return {Promise<undefined>} To be resolved when tickets fetched.
    ###
    fetchAllTicketOnProject: () ->
      return if not DataAdapter.selectedProject
      params =
        query_id:   DataAdapter.selectedProject.queryId
        project_id: DataAdapter.selectedProject.id
      Redmine.get(DataAdapter.selectedAccount)
        .getIssues(params)
        .then(@_fetchRemainingTickets, @_errorFetchTickets)
        .then(@_successFetchTickets, @_errorFetchTickets)


    ###
     Update project's issues count.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>} To be resolved when all count fetched.
    ###
    fetchTicketsCount: (account) -> () ->
      Log.debug("fetchTicketsCount() start:\t#{account.name}")
      return if not Option.getOptions().hideNonTicketProject
      projects = DataAdapter.getProjects(account.url)
      promises = projects.map (p) ->
        params = limit: 1, project_id: p.id, status_id: "open"
        Redmine.get(account).getIssuesPararell(params)
          .then((d) -> p.ticketCount = d.total_count)
      $q.all(promises)
        .then(() -> DataAdapter.updateProjects())
        .then(() ->
           projects = DataAdapter.getProjects(account.url)
           Log.groupCollapsed "fetchTicketsCount() #{account.url}"
           for p in projects
             Log.debug("  project: " + p.text + "\tticketCount: " + p.ticketCount)
           Log.groupEnd "fetchTicketsCount() #{account.url}" )


    ###*
     Fetch remaining tickets.
     @param {Object} data - Fetched data using Redmine.getIssues().
     @return {Promise<Object>} Fetched remaining data.
    ###
    _fetchRemainingTickets: (data) =>
      return if not data

      storedCount = DataAdapter.selectedProject.tickets.length
      remainCount = data.total_count - storedCount
      DataAdapter.selectedProject.ticketCount = data.total_count

      # remaining tickets was already stored.
      return if remainCount is 0

      # remaining tickets was already fetched.
      @_successFetchTickets(data)
      return if remainCount <= data.issues.length

      # fetch remaining tickets.
      Redmine.get(DataAdapter.selectedAccount)
        .getIssuesRange(data.params, data.issues.length, remainCount)


    ###*
     Update tickets.
     @param {Object} data - Fetched data using Redmine.getIssues().
    ###
    _successFetchTickets: (data) =>
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
     @param {Object} data - Error object.
     @param {Number} status - Error code.
    ###
    _errorFetchTickets: (data, status) =>
      if status is RedmineLoader.STATUS_CANCEL then return
      State.isLoadingVisible = false
      Message.toast Resource.string("msgLoadIssueFail")


    ###*
     Fetch issues for account.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>[]}
    ###
    _fetchSavedIssues: (account) => () =>
      Log.debug("_fetchSavedIssues:() start:\t#{account.name}")
      for t in DataAdapter.tickets when account.url is t.url
        Redmine.get(account).getIssuesById t.id, @_updateIssue(t), @_issueNotFound(t)


    ###*
     Update issue according to fetched data.
     @param {TicketModel} target - Issue to be updated.
     @param {TicketModel} issue - Issue to be used for update.
    ###
    _updateIssue: (target) -> (issue) ->
      for k, v of issue then target[k] = v
      return if not Option.getOptions().removeClosedTicket
      # remove closed issues.
      statuses = DataAdapter.getStatuses(target.url)
      status = statuses.find (n) -> n.id is target.status.id
      if status?.is_closed
        DataAdapter.toggleIsTicketShow(target)
        Message.toast(Resource.string("msgIssueClosed", target.text), 3000)


    ###*
     When issue not found, remove issue.
     @param {TicketModel} target - Issue to be updated.
     @param {TicketModel} issue - Issue to be removed.
     @param {Number} status - result code.
    ###
    _issueNotFound: (target) -> (issue, status) ->
      if status is RedmineLoader.NOT_FOUND or status is RedmineLoader.UNAUTHORIZED
        DataAdapter.toggleIsTicketShow(issue)
        Message.toast(Resource.string("msgIssueMissing", [target.text, account.name]), 3000)


    ###*
     Fetch projects from redmine.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>} To be resolved when all projects fetched.
    ###
    _fetchProjects: (account) ->
      Log.debug("_fetchProjects() start:\t#{account.name}")
      redmine = Redmine.get(account)
      promises = []
      # fetch projects according to numProjects.
      if account.numProjects isnt 0
        promises.push(redmine.loadProjectsRange({}, 0, account.numProjects))
      # fetch projects according to projectList.
      if account.projectList
        promises.add account.projectList.map (id) -> redmine.loadProjectById(id)
      # if nothing to fetch...
      if promises.length is 0
        Message.toast Resource.string("msgCannotFetchProject", account.name), 5000
        Log.warn "loadProjects: account.numProjects: #{account.numProjects}\taccount.projectList: #{account.projectList}"
        return
      promises = promises.map (p) => p.then(@_successFetchProject, @_errorFetchProject)
      $q.all(promises).then(@_updateProjects)


    ###*
     Show success message.
     @param {Object} data - Fetched data using Redmine.loadProjectById().
     @return {ProjectModel[]} Fetched projects.
    ###
    _successFetchProject: (data) =>
      if not data.project and (not data.projects or data.projects.length is 0)
        _errorFetchProject data
        return null
      data.projects = data.projects or [data.project]
      Message.toast Resource.string("msgLoadProjectSuccess", [data.account.name, data.projects.length]), 3000
      return data.projects


    ###*
     Show error message.
     @param {Object} data - Fetched data using Redmine.loadProjectById().
    ###
    _errorFetchProject: (data) =>
      if data.status is RedmineLoader.STATUS_CANCEL then return
      if data.targetId
        message = Resource.string("msgLoadProjectFailId", [data.account.name, data.targetId]) + Resource.string("status", data.status)
      else
        message = Resource.string("msgLoadProjectFaild", [data.account.name, data.account.numProjects or '']) + Resource.string("status", data.status)
      Message.toast message, 5000
      return null


    ###*
     Update projects and remove projects which was not fetched.
     @param {ProjectModel[]} projectsList - array of fetched projects.
    ###
    _updateProjects: (projectsList) =>
      projects = projectsList.compact().flatten().unique("id")
      return if projects.length is 0

      # update settings specified by user, using saved data on chrome.
      saved = DataAdapter.getProjects(projects[0].url)
      projects.map (p) ->
        s = saved.find (n) -> n.equals p
        return if not s
        p.show = s.show
        p.queryId = s.queryId
        # On chrome, project doesn't have text. Update it here.
        if p.equals DataAdapter.selectedProject
          DataAdapter.selectedProject.text = p.text

      # update
      DataAdapter.removeProjects(saved, false)
      DataAdapter.addProjects(projects)


    ###*
     Fetch activities for account.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>} To be resolved when activities fetched.
    ###
    _fetchActivities: (account) ->
      Log.debug("_fetchActivities() start:\t#{account.name}")
      Redmine.get(account).loadActivities()
        .then((data) ->
          if not data?.time_entry_activities? then return
          Log.info "Redmine.loadActivities success"
          DataAdapter.setActivities(data.account.url, data.time_entry_activities))


    ###*
     Fetch queries for account.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>} To be resolved when queries fetched.
    ###
    _fetchQueries: (account) ->
      Log.debug("_fetchQueries() start:\t#{account.name}")
      params =
        page: 1
        limit: 50
      Redmine.get(account).loadQueries(params)
        .then((data) ->
          data.queries.add({id: RedmineLoader.QUERY_ALL_ID, name: 'All'}, 0)
          DataAdapter.setQueries(data.account.url, data.queries)
        , (data, status) =>
          if status is RedmineLoader.STATUS_CANCEL then return
          Message.toast Resource.string("msgLoadQueryFail", data.account.name), 3000)


    ###*
     Fetch statuses for account.
     @param {AccountModel} account - Account to be fetched.
     @return {Promise<undefined>} To be resolved when statuses fetched.
    ###
    _fetchStatuses: (account) =>
      Log.debug("_fetchStatuses() start:\t#{account.name}")
      Redmine.get(account).loadStatuses()
        .then((data) ->
          DataAdapter.setStatuses(data.account.url, data.issue_statuses)
        , (data, status) ->
          if status is RedmineLoader.STATUS_CANCEL then return
          Message.toast(Resource.string("msgLoadStatusesFail", data.account.name), 3000))


  return new RedmineLoader()

