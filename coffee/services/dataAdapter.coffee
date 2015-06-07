timeTracker.factory("DataAdapter", (Analytics, EventDispatcher, Log) ->


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


  class DataAdapter extends EventDispatcher

    ## instance variables

    # event
    ACCOUNT_ADDED:            "account_added"
    ACCOUNT_REMOVED:          "account_removed"
    SELECTED_ACCOUNT_CHANGED: "selected_account_changed"
    SELECTED_PROJECT_CHANGED: "selected_project_changed"
    SELECTED_TICKET_CHANGED:  "selected_ticket_changed"
    SELECTED_QUERY_CHANGED:   "selected_query_changed"

    ###*
    # all data.
    # @param {DataModel}  data's url
    ###
    _data: {}

    # filtered data.
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
      set: (n) ->
        @_tickets.set n
        @selectedTicket = n[0]

    ###*
    # selectable activites
    # @type Array of ActivityModel
    ###
    _activities: []
    @property 'activities',
      get: -> @_activities
      set: (n) ->
        @_activities.set n
        @selectedActivity = n[0]

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
        @_queries.set n
        @selectedQuery = n[0]

    # selected account.
    _selectedAccount: null
    @property 'selectedAccount',
      get: -> @_selectedAccount
      set: (n) ->
        return if @_selectedAccount is n
        @_selectedAccount = n
        @activities       = @_data[n.url].activities
        @fireEvent(@SELECTED_ACCOUNT_CHANGED, @, n)
        Log.debug("selectedAccount set: " + n.url)

    # selected project.
    _selectedProject: null
    @property 'selectedProject',
      get: -> @_selectedProject
      set: (n) ->
        return if @_selectedProject is n
        @_selectedProject = n
        @queries          = @_data[n.url].queries
        @selectedAccount  = @_data[n.url].account
        @fireEvent(@SELECTED_PROJECT_CHANGED, @, n)
        Log.debug("selectedProject set: " + n.text)

    # selected ticket.
    _selectedTicket: null
    @property 'selectedTicket',
      get: -> @_selectedTicket
      set: (n) ->
        return if @_selectedTicket is n or n is ""
        @_selectedTicket = n
        @activities = @_data[n.url].activities if n and @_data[n.url]
        @fireEvent(@SELECTED_TICKET_CHANGED, @, n)
        Log.debug("selectedTicket set: " + n)

    # selected activity.
    _selectedActivity: null
    @property 'selectedActivity',
      get: -> @_selectedActivity
      set: (n) -> n is "" or @_selectedActivity = n

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
        @_filteredData = []
        if not query? or query.isBlank()
          for url, dataModel of @_data
            @_filteredData.push dataModel.account
            dataModel.account.projects.set(dataModel.projects)
        else
          substrRegexs = query.split(' ').map (q) -> new RegExp(q, 'i')
          for url, dataModel of @_data
            filtered = dataModel.projects.filter (n) ->
              text = n.id + " " + n.text
              return substrRegexs.every (r) -> r.test(text)
            if filtered.length > 0
              @_filteredData.push dataModel.account
              dataModel.account.projects = filtered
        Log.timeEnd('projectQuery\t')

    ###*
    # add accounts
    # @param {Array} accounts - array of AccountModel.
    ###
    addAccounts: (accounts) ->
      if not accounts? or accounts.length is 0 then return
      Log.debug("addAccounts")
      for a in accounts
        @_data[a.url] = new DataModel()
        @_data[a.url].account = a
      if not @selectedAccount? then @selectedAccount = accounts[0]
      @_filteredData.add(accounts)
      @fireEvent(@ACCOUNT_ADDED, @, accounts)

    ###*
    # remove accounts
    # @param {Array} accounts - array of AccountModel.
    ###
    removeAccounts: (accounts) ->
      if not accounts? or accounts.length is 0 then return
      for a in accounts
        delete @_data[a.url]
        @_filteredData.remove((n) -> return n.url is a.url)
        if @selectedProject.url is a.url
          @selectedProject = @_filteredData[0].projects[0]
      @fireEvent(@ACCOUNT_REMOVED, @, accounts)

    ###*
    # add project to account.
    # if project is already loaded, overwrites by new project.
    # @param {Array} projects - array of ProjectModel.
    ###
    addProjects: (projects) ->
      if not projects? or projects.length is 0 then return
      for p in projects
        @_data[projects[0].url].projects.remove((n) -> return n.equals(p))
      @_data[projects[0].url].projects.add(projects)
      if not @selectedProject then @selectedProject = projects[0]
      for a in @_filteredData when a.url is projects[0].url
        a.projects = a.projects or []
        a.projects.add(projects)

    ###*
    # remove project from account.
    # @param {Array} projects - array of ProjectModel
    ###
    removeProjects: (projects) ->
      if not projects? or projects.length is 0 then return
      for p in projects
        @_data[projects[0].url].projects.remove((n) -> return n.equals(p))
      for a in @_filteredData when a.url is projects[0].url
        a.projects.remove((n) -> return n.equals(p))

    ###*
    # set activities.
    # @param {String} url        - url of redmine server.
    # @param {Array}  activities - array of activiy. activiy: { id: Number, name: String }.
    ###
    setActivities: (url, activities) ->
      if not url? or not activities? then return
      @_data[url].activities = activities
      Log.debug("setActivities: #{url}")

    ###*
    # set queries.
    # @param {String} url      - url of redmine server.
    # @param {Array}  queries  - array of query. query: { id: Number, name: String }.
    ###
    setQueries: (url, queries) ->
      if not url? or not queries? then return
      @_data[url].queries = queries
      Log.debug("setQueries: #{url}")

  return new DataAdapter

)
