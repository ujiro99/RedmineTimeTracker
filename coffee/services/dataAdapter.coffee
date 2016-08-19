timeTracker.factory("DataAdapter", (Analytics, EventDispatcher, Const, Option, Log) ->


  ###*
  ###
  class DataModel

    constructor: () ->

      ###*
      # @property account
      # @type AccountModel
      ###
      @account = {}

      ###*
      # @property projects
      # @type Array of ProjectModel
      ###
      @projects = []

      ###*
      # @property tickets
      # @type Array of TicketModel
      ###
      @tickets = []

      ###*
      # @property Activities
      # @type Array of ActivityModel
      ###
      @activities = []

      ###*
      # @property Queries
      # @type Array of QueryModel
      ###
      @queries = []

      ###*
      # @property Statuses
      # @type Array of StatusModel
      ###
      @statuses = []


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
    SELECTED_TICKET_CHANGED:  "selected_ticket_changed"
    SELECTED_QUERY_CHANGED:   "selected_query_changed"

    ###*
    # constructor
    ###
    constructor: () ->
      @_bindDataModelGetter()
      Option.onChanged "isProjectStarEnable", () =>
        @_updateStarredProjects()

    ###*
    # all data.
    # @type {object}
    # @prop {DataModel} url of server - DataModel
    ###
    _data: {}

    ###
    # filtered data.
    # @type Array of AccountModel
    ###
    _filteredData: []
    @property 'accounts',
      get: -> @_filteredData

    ###*
    # selectable tickets
    # @type Array of TicketModel
    ###
    _tickets: []
    @property 'tickets',
      get: -> @_tickets

    ###*
    # selectable activites
    # @type Array of ActivityModel
    ###
    _activities: []
    @property 'activities',
      get: -> @_activities

    ###*
    # selectable Queries
    # @type Array of QueryModel
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
        @_sortTickets(@_tickets)
        @fireEvent(@SELECTED_PROJECT_CHANGED, @, n)
        Log.debug("selectedProject set: " + n.text)

    # project updated event.
    _notifyProjectUpdated: () =>
      @fireEvent(@SELECTED_PROJECT_UPDATED, @)

    # selected ticket.
    _selectedTicket: null
    @property 'selectedTicket',
      get: -> @_selectedTicket
      set: (n) ->
        return if @_selectedTicket is n
        @_selectedTicket = n
        @_activities.set @_data[n.url].activities if n and @_data[n.url]
        @_selectedActivity = @_activities[0]
        @fireEvent(@SELECTED_TICKET_CHANGED, @, n)
        Log.debug("selectedTicket set: " + n?.text)
        Log.debug("selectedActivity set: " + @_selectedActivity?.name)

    # selected activity.
    _selectedActivity: null
    @property 'selectedActivity',
      get: -> @_selectedActivity
      set: (n) -> @_selectedActivity = n

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
    # @param {Array} accounts - array of AccountModel.
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
    # @param {Array} accounts - array of AccountModel.
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
    # @param {Array} accounts - array of AccountModel.
    ###
    removeAccounts: (accounts) ->
      Log.debug("removeAccounts() start")
      if not accounts? then return
      accounts = [accounts] if not Array.isArray(accounts)
      for a in accounts
        delete @_data[a.url]
        @_filteredData.remove((n) -> return n.url is a.url)
        @tickets.remove((n) -> return n.url is a.url)
        @_updateStarredProjects()
        if @selectedProject and @selectedProject.url is a.url
          account = @_filteredData.find (n) -> n.projects.length > 0
          @selectedProject = account.projects[0] if account
        if @selectedTicket and @selectedTicket.url is a.url
          @selectedTicket = @tickets[0]
      @fireEvent(@ACCOUNT_REMOVED, @, accounts)
      Log.debug("removeAccounts() finish")

    ###*
    # add project to account.
    # if project is already loaded, overwrites by new project.
    # @param {Array} projects - array of ProjectModel.
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
      @updateProjects()
      @fireEvent(@PROJECTS_CHANGED, @, projects)
      Log.debug("addProjects() finish")

    ###*
    # remove project from account.
    # @param {Array} projects - array of ProjectModel
    # @param {Bool} eventEnable - is event enable
    ###
    removeProjects: (projects, eventEnable) ->
      Log.debug("removeProjects() start")
      if not projects? or projects.length is 0 then return
      for p in projects when @_data[p.url] and @_data[p.url].projects
        @_data[p.url].projects.remove((n) -> n.equals(p))
      @updateProjects()
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
    # toggle ticket's show/hide status.
    # @param {Array} tickets - array of TicketModel
    ###
    toggleIsTicketShow: (tickets) ->
      Log.debug("toggleIsTicketShow() start")
      tickets = [tickets] if not Array.isArray(tickets)
      @_tickets.set @_tickets.xor(tickets)
      @_sortTickets(@_tickets)
      if not @selectedTicket or not @_tickets.some((n) => n.equals(@selectedTicket))
        @selectedTicket = @_tickets[0]
      @fireEvent(@TICKETS_CHANGED, @)
      Log.debug("toggleIsTicketShow() finish")

    ###*
    # add tickets to _data.
    # @param {Array} tickets - array of TicketModel
    ###
    addTickets: (tickets) ->
      Log.debug("addTickets() start")
      tickets = [tickets] if not Array.isArray(tickets)
      tickets.map (n) -> @_data[n.url].tickets.add n
      Log.debug("addTickets() finish")

    ###*
    # clear all tickets.
    ###
    clearTicket: () ->
      Log.debug("clearTicket() start")
      for url, data of @_data then data.tickets = []
      @_tickets.set []
      @selectedTicket = null
      @fireEvent(@TICKETS_CHANGED, @)
      Log.debug("clearTicket() finish")

    ###*
    # set activities.
    # @param {String} url        - url of redmine server.
    # @param {Array}  activities - array of activity. activity: { id: Number, name: String }.
    ###
    setActivities: (url, activities) ->
      if not url? or not activities? then return
      @_data[url].activities = activities
      if @selectedTicket and @selectedTicket.url is url
        @_activities.set activities
        @_selectedActivity = activities[0]
      Log.debug("setActivities: #{url}")

    ###*
    # set queries.
    # @param {String} url      - url of redmine server.
    # @param {Array}  queries  - array of query. query: { id: Number, name: String }.
    ###
    setQueries: (url, queries) ->
      if not url? or not queries? then return
      @_data[url].queries = queries
      if @selectedProject and @selectedProject.url is url
        @queries = queries
      Log.debug("setQueries: #{url}")

    ###*
    # set Statuses.
    # @param {Array} status - array of StatusModel
    ###
    setStatuses: (url, statuses) ->
      if not url? or not statuses? then return
      @_data[url].statuses = statuses
      Log.debug("setStatuses: #{url}")

    ###*
    # sort tickets.
    #  order: account -> project -> ticket
    ###
    _sortTickets: (tickets) ->
      tickets.sort (a, b) =>
        if @selectedProject
          isAselected = a.url is @selectedProject.url and a.project.id is @selectedProject.id
          isBselected = b.url is @selectedProject.url and b.project.id is @selectedProject.id
          if isAselected then return -1
          if isBselected then return  1
        if a.url > b.url then return  1
        if a.url < b.url then return -1
        if a.project.id > b.project.id then return  1
        if a.project.id < b.project.id then return -1
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
