timeTracker.factory("DataAdapter", (Analytics) ->


  class DataModel

    constructor: () ->
      @account = {}
      @projects = []


  class DataAdapter

    ## class variables
    # events
    @CHANGE: "change"
    @CHANGE_SELECTED: "change_selected"

    ## instance variables

    ###*
    # all data.
    # @param {Object} data
    # @param {Object.AccountModel} account
    # @param {Object.ProjectModel[]} projects
    ###
    _data: {}
    # filtered data.
    _filteredData: []
    # query string for projects
    _projectQuery: ""
    # selected project.
    selectedProject: null
    # selected ticket.
    selectedTicket: null

    # accounts accessor.
    @property 'accounts',
      get: -> @_filteredData

    # projectQuery accessor.
    @property 'projectQuery',
      get: () -> return @_projectQuery
      set: (query) ->
        # console.time('projectQuery\t')
        @_projectQuery = query
        @_filteredData = []
        if not query? or query.isBlank()
          for url, dataModel of @_data
            @_filteredData.push dataModel.account
            dataModel.account.projects = dataModel.projects
        else
          query = query.toLowerCase()
          for url, dataModel of @_data
            filtered = []
            for n in dataModel.projects
              filtered.push n if (n.id + " " + n.text).toLowerCase().contains(query)
            if filtered.length > 0
              @_filteredData.push dataModel.account
              dataModel.account.projects = filtered
        # console.timeEnd('projectQuery\t')

    ###*
    # add accounts
    # @param {Array} accounts - array of AccountModel.
    ###
    addAccounts: (accounts) ->
      if not accounts? or accounts.length is 0 then return
      for a in accounts
        @_data[a.url] = new DataModel()
        @_data[a.url].account = a
      @_filteredData.add(accounts)

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
          @selectedProject = _filteredData[0].projects[0]

    ###*
    # add project to account.
    # if project is already loaded, overwrites by new project.
    # @param {Array} projects - array of ProjectModel.
    ###
    addProjects: (projects) ->
      if not projects? or projects.length is 0 then return
      if not @selectedProject then @selectedProject = projects[0]
      for p in projects
        @_data[projects[0].url].projects.remove((n) -> return n.equals(p))
      @_data[projects[0].url].projects.add(projects)
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

  return new DataAdapter

)
