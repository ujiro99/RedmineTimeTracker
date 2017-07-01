timeTracker.factory("DataAdapter", (Analytics, EventDispatcher, Const, Option, Log) ->


  ###*
   Data model of all data in account.
   @class DataModel
  ###
  class DataModel

    ###*
     @constructor
    ###
    constructor: () ->

      ###*
      # @property account
      # @type {AccountModel}
      ###
      @account = {}

      ###*
      # @property projects
      # @type {ProjectModel[]}
      ###
      @projects = []

      ###*
      # @property tickets
      # @type {TicketModel[]}
      ###
      @tickets = []

      ###*
      # @property Activities
      # @type {ActivityModel[]}
      ###
      @activities = []

      ###*
      # @property Queries
      # @type {QueryModel[]}
      ###
      @queries = []

      ###*
      # @property Statuses
      # @type {StatusModel[]}
      ###
      @statuses = []


  ###*
   Class representing the search word entered.
   @class SearchKeyword
  ###
  class SearchKeyword

    constructor: (@data) ->

    ###*
     Selected TaskModel or inputted search word.
     @type {TaskModel|String}
    ###
    _task: null
    @property 'task',
      get: -> return @_task
      set: (val) ->
        @_task = val
        if val is null or !!val.id # not String
          @data.selectedTask = val

    ###*
     Selected Activity Model or inputted search word.
     @type {ActivityModel|String}
    ###
    _activity: null
    @property 'activity',
      get: -> return @_activity
      set: (val) ->
        @_activity = val
        if val is null or !!val.id
          @data.selectedActivity = val

  ###*
   Adapter class for GUI and data models.
   @class DataAdapter
  ###
  class DataAdapter extends EventDispatcher

    # event
    ACCOUNT_ADDED:            "account_added"
    ACCOUNT_UPDATED:          "account_updated"
    ACCOUNT_REMOVED:          "account_removed"
    PROJECTS_CHANGED:         "projects_changed"
    TICKETS_CHANGED:          "tickets_changed"
    SELECTED_ACCOUNT_CHANGED: "selected_account_changed"
    SELECTED_PROJECT_CHANGED: "selected_project_changed"
    SELECTED_PROJECT_UPDATED: "selected_project_updated"
    SELECTED_TASK_CHANGED:    "selected_task_changed"
    SELECTED_QUERY_CHANGED:   "selected_query_changed"

    ###*
    # constructor
    # @constructor
    ###
    constructor: () ->
      super()
      @searchKeyword = new SearchKeyword(@)
      @_bindDataModelGetter()
      Option.onChanged "isProjectStarEnable", () =>
        @_updateStarredProjects()

    ###*
    # All data. Object key is Url of account.
    # @type {Object<string, DataModel>}
    ###
    _data: {}

    ###
    # filtered data.
    # @type {AccountModel[]}
    ###
    _filteredData: []
    @property 'accounts',
      get: -> @_filteredData

    ###*
    # selectable task
    # @type {TaskModel[]}
    ###
    _tasks: []
    @property 'tasks',
      get: -> @_tasks

    ###*
    # selectable ticket
    # @type {TicketModel[]}
    ###
    _tickets: []
    @property 'tickets',
      get: -> @_tickets

    ###*
    # selectable activites
    # @type {ActivityModel[]}
    ###
    _activities: []
    @property 'activities',
      get: -> @_activities

    ###*
    # selectable Queries
    # @type {QueryModel[]}
    ###
    _queries: []
    @property 'queries',
      get: -> @_queries
      set: (n) ->
        # filter the project-specific query
        n = n.exclude (q) => q and q.project_id and q.project_id isnt @selectedProject.id
        n = n.sortBy("id")
        @_queries.set n
        @selectedQuery = n[0]

    # selected account.
    _selectedAccount: null
    @property 'selectedAccount',
      get: -> @_selectedAccount
      set: (n) ->
        return if @_selectedAccount is n
        @_selectedAccount = n
        @_activities.set @_data[n.url].activities
        @fireEvent(@SELECTED_ACCOUNT_CHANGED, @, n)
        Log.debug("selectedAccount set: " + n.url)

    # selected project.
    _selectedProject: null
    @property 'selectedProject',
      get: -> @_selectedProject
      set: (n) ->
        return if not n? or @_selectedProject is n
        @_selectedProject and @_selectedProject.removeEventListener(n.UPDATED, @_notifyProjectUpdated)
        @_selectedProject = n
        @_selectedProject.addEventListener(n.UPDATED, @_notifyProjectUpdated)
        @selectedAccount  = @_data[n.url].account
        @queries          = @_data[n.url].queries
        @_sortTasks(@_tasks)
        @fireEvent(@SELECTED_PROJECT_CHANGED, @, n)
        Log.debug("selectedProject set: " + n.text)

    # project updated event.
    _notifyProjectUpdated: () =>
      @fireEvent(@SELECTED_PROJECT_UPDATED, @)

    # selected ticket.
    _selectedTask: null
    @property 'selectedTask',
      get: -> @_selectedTask
      set: (n) ->
        return if @_selectedTask is n or (n and not n.text)
        @_selectedTask = n
        @searchKeyword._task = n
        @_activities.set @_data[n.url].activities if n and @_data[n.url]
        @selectedActivity = @_activities[0]
        @fireEvent(@SELECTED_TASK_CHANGED, @, n)
        Log.debug("selectedTask set: " + n?.text)
        Log.debug("selectedActivity set: " + @_selectedActivity?.name)

    # selected activity.
    _selectedActivity: null
    @property 'selectedActivity',
      get: -> @_selectedActivity
      set: (n) ->
        @_selectedActivity = n
        @searchKeyword._activity = n

    # selected query.
    _selectedQuery: null
    @property 'selectedQuery',
      get: -> @_selectedQuery
      set: (n) ->
        return if @_selectedQuery is n
        @_selectedQuery = n
        @fireEvent(@SELECTED_QUERY_CHANGED, @, n)

    # query string for projects
    _projectQuery: ""
    @property 'projectQuery',
      get: () -> return @_projectQuery
      set: (query) ->
        Log.time('projectQuery\t')
        @_projectQuery = query
        @updateProjects()
        Log.timeEnd('projectQuery\t')

    ###*
    # check account is exists.
    # @param {AccountModel} account
    ###
    isAccountExists: (account) ->
      if not account? then return false
      return !!@_data[account.url] and !!@_data[account.url].account

    ###*
    # add accounts
    # @param {AccountModel[]} accounts - array of AccountModel.
    ###
    addAccounts: (accounts) ->
      Log.debug("addAccounts() start")
      if not accounts? then return
      accounts = [accounts] if not Array.isArray(accounts)
      if accounts.isEmpty() or not accounts[0].isValid() then return
      for a in accounts
        @_data[a.url] = new DataModel()
        @_data[a.url].account = a
      if not @selectedAccount? then @selectedAccount = accounts[0]
      @_filteredData.add(accounts)
      @fireEvent(@ACCOUNT_ADDED, @, accounts)
      Log.debug("addAccounts() finish")

    ###*
    # update accounts
    # @param {AccountModel[]} accounts - array of AccountModel.
    ###
    updateAccounts: (accounts) ->
      Log.debug("updateAccounts() start")
      if not accounts? then return
      accounts = [accounts] if not Array.isArray(accounts)
      if not accounts[0].isValid() then return
      for a in accounts
        @_data[a.url]?.account.update(a)
      @_updateStarredProjects()
      @fireEvent(@ACCOUNT_UPDATED, @, accounts)
      Log.debug("updateAccounts() finish")

    ###*
    # remove accounts
    # @param {AccountModel[]} accounts - array of AccountModel.
    ###
    removeAccounts: (accounts) ->
      Log.debug("removeAccounts() start")
      if not accounts? then return
      accounts = [accounts] if not Array.isArray(accounts)
      for a in accounts
        delete @_data[a.url]
        @_filteredData.remove((n) -> return n.url is a.url)
        @tasks.remove((n) -> return n.url is a.url)
        @_updateStarredProjects()
        if @selectedProject and @selectedProject.url is a.url
          account = @_filteredData.find (n) -> n.projects.length > 0
          @selectedProject = account.projects[0] if account
        if @selectedTask and @selectedTask.url is a.url
          @selectedTask = @tasks[0]
      @fireEvent(@ACCOUNT_REMOVED, @, accounts)
      Log.debug("removeAccounts() finish")

    ###*
    # add project to account.
    # if project is already loaded, overwrites by new project.
    # @param {ProjectModel[]} projects - array of ProjectModel.
    ###
    addProjects: (projects) ->
      Log.debug("addProjects() start")
      if not projects? or projects.length is 0 then return
      @removeProjects(projects, false)
      firstAdded = null
      projects.map (p) =>
        if not @_data[p.url] then return
        @_data[p.url].projects.add(p)
        firstAdded or firstAdded = p
      for url, dataModel of @_data
        dataModel.account.projectsCount = dataModel.projects.length
      if not @selectedProject then @selectedProject = firstAdded
      @_addProjectsToTasks()
      if not @selectedTask then @selectedTask = @_tasks[0]
      @updateProjects()
      @fireEvent(@PROJECTS_CHANGED, @, projects)
      Log.debug("addProjects() finish")

    ###*
    # remove project from account.
    # @param {ProjectModel[]} projects - array of ProjectModel
    # @param {Bool} eventEnable - is event enable
    ###
    removeProjects: (projects, eventEnable) ->
      Log.debug("removeProjects() start")
      if not projects? or projects.length is 0 then return
      for p in projects when @_data[p.url] and @_data[p.url].projects
        @_data[p.url].projects.remove((n) -> n.equals(p))
        @tasks.remove((n) -> n.equals(p))
        if @selectedTask?.equals(p) then @selectedTask = null
      eventEnable and @updateProjects()
      eventEnable and @fireEvent(@PROJECTS_CHANGED, @, projects)
      Log.debug("removeProjects() finish")

    ###*
    # filter project which has opened tickets.
    ###
    updateProjects: () ->
      Log.debug("updateProjects() start")
      @_filterProjectsByQuery()
      @_filterProjectsByIssueCount()
      @_updateStarredProjects()
      Log.debug("updateProjects() finish")

    ###*
     toggle ticket's show/hide status.
     @param {TicketModel[]} tickets - array of TicketModel
    ###
    toggleIsTicketShow: (tickets) ->
      Log.debug("toggleIsTicketShow() start")
      Log.time('toggleIsTicketShow\t')

      # toggle tickets.
      tickets = [tickets] if not Array.isArray(tickets)
      @_tickets.set @_tickets.xor(tickets)
      @_addProjectsToTasks()

      # update selectedTask.
      if not @selectedTask or not @_tasks.some((n) => n.equals(@selectedTask))
        @selectedTask = @_tasks[0]

      @fireEvent(@TICKETS_CHANGED, @)
      Log.timeEnd('toggleIsTicketShow\t')
      Log.debug("toggleIsTicketShow() finish")


    ###*
    # clear all tickets.
    ###
    clearTicket: () ->
      Log.debug("clearTicket() start")
      for url, data of @_data then data.tickets = []
      @_tasks.set []
      @_tickets.set []
      @selectedTask = null
      @fireEvent(@TICKETS_CHANGED, @)
      Log.debug("clearTicket() finish")

    ###*
     @typedef {Object} Activity
     @prop {number} id - id of this activity.
     @prop {string } name - name of this activity
    ###

    ###*
    # set activities.
    # @param {String} url - url of redmine server.
    # @param {Activity[]} activities - Array of activity to be set.
    ###
    setActivities: (url, activities) ->
      if not url? or not activities? then return
      @_data[url].activities = activities
      if @selectedTask and @selectedTask.url is url
        @_activities.set activities
        @selectedActivity = activities[0]
      Log.debug("setActivities: #{url}")

    ###*
     @typedef {Object} Query
     @prop {number} id - id of this query.
     @prop {string } name - name of this query
    ###

    ###*
    # set queries.
    # @param {String} url - url of redmine server.
    # @param {Query[]} queries  - Array of query to be set.
    ###
    setQueries: (url, queries) ->
      if not url? or not queries? then return
      @_data[url].queries = queries
      if @selectedProject and @selectedProject.url is url
        @queries = queries
      Log.debug("setQueries: #{url}")

    ###*
     @typedef {Object} Status
     @prop {number} id - id of this status.
     @prop {string } name - name of this status
    ###

    ###*
     Set Statuses.
     @param {string} url - url of redmine server.
     @param {Status[]} statuses - array of Status to be set.
    ###
    setStatuses: (url, statuses) ->
      if not url? or not statuses? then return
      @_data[url].statuses = statuses
      Log.debug("setStatuses: #{url}")


    ###*
     Add projects to @tasks if tickets exists.
    ###
    _addProjectsToTasks: () ->
      projects = @tickets.map((n) -> {url: n.url, id: n.project.id}).unique()
      projectModels = projects.map((p) => @_data[p.url]?.projects?.find(p)).compact()
      @_tasks.set @tickets.concat(projectModels)
      @_sortTasks(@_tasks)


    ###*
     sort tasks.
     order: selected -> url -> project -> type -> ticket
     @param {TaskModel[]} tasks - task array to be sorted.
    ###
    _sortTasks: (tasks) ->
      tasks.sort (a, b) =>
        if @selectedProject
          isAselected = a.url is @selectedProject.url and a.projectId is @selectedProject.id
          isBselected = b.url is @selectedProject.url and b.projectId is @selectedProject.id
          if isAselected and not isBselected then return -1
          if isBselected and not isAselected then return  1
        if a.url > b.url then return  1
        if a.url < b.url then return -1
        if a.projectId > b.projectId then return  1
        if a.projectId < b.projectId then return -1
        if a.type > b.type then return -1
        if a.type < b.type then return  1
        if a.id > b.id then return  1
        if a.id < b.id then return -1
        return 0
      # tickets.map (t) ->
      #   Log.debug "sort:\t id:#{t.id}\tprj:#{t.project.name}"

    ###*
    # filter projects by projectQuery.
    ###
    _filterProjectsByQuery: () ->
      @_filteredData = []
      if not @projectQuery? or @projectQuery.isBlank()
        for url, dataModel of @_data
          @_filteredData.push dataModel.account
          dataModel.account.projects of dataModel.account.projects = []
          dataModel.account.projects.set(dataModel.projects)
      else
        substrRegexs = @projectQuery.split(' ').map (q) -> new RegExp(util.escapeRegExp(q), 'i')
        for url, dataModel of @_data
          filtered = dataModel.projects.filter (n) ->
            text = n.id + " " + n.text
            return substrRegexs.every (r) -> r.test(text)
          if filtered.length > 0
            @_filteredData.push dataModel.account
            dataModel.account.projects = filtered

    ###*
    # filter project which has opened tickets.
    ###
    _filterProjectsByIssueCount: () ->
      return if not Option.getOptions().hideNonTicketProject
      for a in @_filteredData
        continue if not a.projects
        a.projects.set(a.projects.filter (p) -> p.ticketCount > 0)
      if not @selectedProject or not @selectedProject.ticketCount or @selectedProject.ticketCount is 0
        for a in @_filteredData when a.projects and a.projects.length > 0
          @selectedProject = a.projects[0]
          break

    ###*
    # filter and add starred projects.
    ###
    _updateStarredProjects: () =>
      @_filteredData.remove((n) -> n.url is Const.STARRED)
      if not Option.getOptions().isProjectStarEnable then return

      # find
      starred = []
      @_filteredData.map((a) ->
        if not a.projects then return
        starred.add(a.projects.filter((n) -> n.show is Const.SHOW.SHOW)))
      if starred.length is 0 then return

      # update
      starredAccount = { name: Const.STARRED, url: Const.STARRED ,projects: starred }
      @_filteredData.add(starredAccount, 0)

    ###*
    # bind getter for DataModel's properties.
    ###
    _bindDataModelGetter: () =>
      bind = (p) ->
        methodName = "get" + p.camelize()
        DataAdapter.prototype[methodName] = (url) ->
          if url
            if not @_data[url] then return []
            res = @_data[url][p]
            if Object.isArray(res)
              return [].concat(res) # return copy
            else
              return res
          else
            concated = []
            for url, dataModel of @_data
              concated = concated.concat(dataModel[p])
            return concated
      for prop, value of new DataModel then bind(prop)

  return new DataAdapter

)
