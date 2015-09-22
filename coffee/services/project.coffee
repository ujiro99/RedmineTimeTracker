timeTracker.factory("Project", ($q, Analytics, Chrome, Const, Log) ->

  ###
   Project data model.
  ###
  class ProjectModel extends EventDispatcher

    UPDATED: "updated"

    ###*
     constructor.
     @class ProjectModel
     @constructor
     @param url {String} Redmine server's url.
     @param urlIndex {Number} project id's index on Chrome.storage.
     @param id {Number} project id.
     @param text {String} project's name.
     @param show {Number} can this project show? (DEFAULT: 0, NOT: 1, SHOW: 2)
     @param queryId {Number} Used query ID
     @param tickets {Array} Array of TicketModel.
    ###
    constructor: (@url, @urlIndex, @id, @text, @show, @queryId, tickets) ->
      Const.ISSUE_PROPS.map (p) => @[p] = []
      @tickets  = tickets or []
      Array.observe(@tickets, @updateProperties)
      @updateProperties([{object: @tickets}]) if tickets and tickets.length > 0

    ###
     update property related to project.
     @param changes {Object} what was changed.
                             ex) [{type: 'splice', object: <arr>, index: 1, removed: ['B', 'c', 'd'], addedCount: 3}]
    ###
    updateProperties: (changes) =>
      Log.time("updateProperties #{@text}\t")
      tmp = {}
      # create each property's id/name object.
      Const.ISSUE_PROPS.map (p) => tmp[p] = {}
      changes.map (c) => c.object.map (t) => Const.ISSUE_PROPS.map (p) =>
        t[p] and tmp[p][t[p].id] = t[p].name
      Const.ISSUE_PROPS.map (p) =>
        # create id/name pair array.
        tmpArray = Object.toKeyValuePair(tmp[p], {key: "id", value: "name"})
        tmpArray.add({id: "", name: "All"}, 0)
        tmpArray.map (t) -> t.checked = true
        # restore old checked status
        @[p].map (oldOption) ->
          newOption = tmpArray.find (n) -> n.id is oldOption.id
          newOption.checked = oldOption.checked if newOption
        @[p].set(tmpArray)
      Log.timeEnd("updateProperties #{@text}\t")
      @fireEvent(@UPDATED, @)

    ###
     compare project.
     true: same / false: different
    ###
    equals: (y) ->
      return false if not y?
      return @url is y.url and @id is y.id


  class Project

    ## class variables
    @PROJECT = "PROJECT"
    @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }

    ## instance variables

    ###
     project object. same as on chrome object.
     - in chrome sync,
         project = {
           value of url:
             index: project_url_index
             value of project_id:
               text: project_name
               show: DEFAULT: 0, NOT: 1, SHOW: 2
         }
    ###
    _projects: {}


    ###
     load from any area.
    ###
    _load: (storage, callback) ->
      if not storage? then callback? null; return
      storage.get Project.PROJECT, (projects) ->
        if Chrome.runtime.lastError? then callback? null; return
        if not projects[Project.PROJECT]? then callback? null; return
        if Object.keys(projects[Project.PROJECT]).length is 0 then callback? null; return
        callback? projects[Project.PROJECT]


    ###
     save all project to any area.
    ###
    _set: (projects, storage, callback) ->
      storage.set PROJECT: projects, () ->
        if Chrome.runtime.lastError?
          callback? false
        else
          callback? true


    ###
     save all project to local.
    ###
    _setLocal: (callback) ->
      @_set @_projects, Chrome.storage.local, callback


    ###
     get projects project.
    ###
    get: () ->
      return @_projects


    ###
     set projects.
     @param newProjects {Object} HashMap of ProjectModel. Key is Account URL.
    ###
    set: (newProjects) ->
      if not newProjects? then return
      Log.groupCollapsed "Project.set()"
      Log.debug newProjects
      Log.groupEnd "Project.set()"

      # clear old data
      for url, params of @_projects then delete @_projects[url]

      # set new project
      for url, params of newProjects
        @_projects[url] = params
      @_setLocal()


    ###
     set parameter to project.
     doesnt't chagne references.
    ###
    setParam: (url, id, params) ->
      if not url? or not id? then return
      if not @_projects[url] or not @_projects[url][id] then return
      target = @_projects[url][id]
      for k, v of params then target[k] = v
      @_setLocal()


    ###
     add a project.
     - all projects are unique.
     - doesnt't chagne references.
    ###
    add: (prj) ->
      # initialize if not exists
      @_projects[prj.url] = @_projects[prj.url] or {}
      target = @_projects[prj.url][prj.id] = @_projects[prj.url][prj.id] or {}
      # set params
      if @_projects[prj.url].index >= 0
        prj.urlIndex = @_projects[prj.url].index
      else
        prj.urlIndex = Object.keys(@_projects).length - 1
      @_projects[prj.url].index = prj.urlIndex
      target.text    = prj.text or target.text
      target.show    = if prj.show? then prj.show else target.show
      target.queryId = if prj.queryId? then prj.queryId else target.queryId
      @_setLocal()


    ###
     remove a project, and update urlIndex.
    ###
    remove: (url, id) ->
      delete @_projects[url][id]
      if Object.keys(@_projects[url]).length is 1
        delete @_projects[url]
        # update urlIndex
        i = 0
        for redmineUrl, params of @_projects
          @_projects[redmineUrl].index = i++
      @_setLocal()


    ###
     remove projects on url, and update urlIndex.
    ###
    removeUrl: (url) ->
      for k, v of @_projects[url]
        continue if k is 'index'
        @remove url, k


    ###
     load all projects from chrome sync.
    ###
    load: () =>
      deferred = $q.defer()
      @_load Chrome.storage.local, (local) =>
        if local?
          Log.info 'project loaded from local'
          Log.groupCollapsed "Project.load()"
          Log.debug local
          Log.groupEnd "Project.load()"
          deferred.resolve(local)
        else
          @_load Chrome.storage.sync, (sync) =>
            Log.info 'project loaded from sync'
            deferred.resolve(sync)
      return deferred.promise


    ###
     sync all projects to chrome sync.
    ###
    sync: (callback) ->
      @_set @_projects, Chrome.storage.sync, callback
      count = 0
      for k, v of @_projects
        count += Object.keys(v).length - 1
      Analytics.sendEvent 'internal', 'project', 'set', count


    ###
     create new Model instance.
    ###
    new: (params) ->
      new ProjectModel(params.url,
                       params.urlIndex,
                       params.id,
                       params.text,
                       params.show,
                       params.queryId)


    ###
     clear project data on storage and local.
    ###
    clear: (callback) ->
      for url, params of @_projects then delete @_projects[url]
      Chrome.storage.local.set PROJECT: []
      Chrome.storage.sync.set PROJECT: [], () ->
      if Chrome.runtime.lastError?
        callback? false
      else
        callback? true


    ###
     sanitize format of prject data.
    ###
    sanitize: (prjObj) ->
      # fix url index
      urlIndex = 0
      for url, param of prjObj
        param.index = urlIndex++
      return prjObj


  return new Project()

)
