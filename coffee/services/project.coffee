timeTracker.factory("Project", (Analytics, Chrome) ->

  PROJECT = "PROJECT"
  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  # - in chrome sync,
  #
  #     project = {
  #       value of url:
  #         index: project_url_index
  #         value of project_id:
  #           text: project_name
  #           show: DEFAULT: 0, NOT: 1, SHOW: 2
  #     }
  #


  ###
   project object. same as on chrome object.
  ###
  _projects = {}


  ###
   selectable project list.
  ###
  _selectableProjects = []


  ###
   load from any area.
  ###
  _load = (storage, callback) ->
    if not storage? then callback? null; return
    storage.get PROJECT, (projects) ->
      if Chrome.runtime.lastError? then callback? null; return
      if not projects[PROJECT]? then callback? null; return
      if Object.keys(projects[PROJECT]).length is 0 then callback? null; return
      callback? projects[PROJECT]


  ###
   save all project to any area.
  ###
  _set = (projects, storage, callback) ->
    storage.set PROJECT: projects, () ->
      if Chrome.runtime.lastError?
        callback? false
      else
        callback? true


  ###
   save all project to local.
  ###
  _setLocal = (callback) ->
    _set _projects, Chrome.storage.local, callback


  ###
   Project data model.
  ###
  class ProjectModel

    ###
     constructor.
    ###
    constructor: (@url, @urlIndex, @id, @text, @show, @queryId) ->

    ###
     compare project.
     true: same / false: different
    ###
    equals: (y) ->
      return false if not y?
      return @url is y.url and @id is y.id


  return {

    SHOW: SHOW

    ###
     get projects project.
    ###
    get: () ->
      return _projects


    getSelectable: () ->
      return _selectableProjects


    ###
     set projects.
    ###
    set: (newProjects) ->
      if not newProjects? then return

      # clear old data
      _selectableProjects.clear()
      for url, params of _projects then delete _projects[url]

      # set new project
      for url, params of newProjects
        _projects[url] = params
        urlIndex = params.index
        for k, v of params
          if k isnt 'index'
            id = k - 0
            _projects[url][id] = {}
            _projects[url][id].text = v.text
            _projects[url][id].show = v.show
            _projects[url][id].queryId = v.queryId
            prj = new ProjectModel(url, urlIndex, id, v.text, v.show, v.queryId)
            if prj.show isnt SHOW.NOT
              _selectableProjects.push prj
      _setLocal()


    ###
     set parameter to project.
     doesnt't chagne references.
    ###
    setParam: (url, id, params) ->
      # set param
      if not url? or not url? or not id? then return
      for k, v of params
        _projects[url][id][k] = v
      # update selectable
      for p, i in _selectableProjects when p.equals {url: url, id: id}
        if _projects[url][id].show isnt SHOW.NOT
          for k, v of params then p[k] = v
        else
          _selectableProjects.splice(i, 1)
        break
      _setLocal()


    ###
     add a project. all projects are unique.
    ###
    add: (project) ->
      prj = new ProjectModel(project.url,
                             project.urlIndex,
                             project.id,
                             project.text,
                             project.show,
                             project.queryId)

      # initialize if not exists
      _projects[prj.url] = _projects[prj.url] or {}
      _projects[prj.url][prj.id] = _projects[prj.url][prj.id] or {}
      if _projects[prj.url].index >= 0
        prj.urlIndex = _projects[prj.url].index
      else
        prj.urlIndex = Object.keys(_projects).length - 1
      _projects[prj.url]['index'] = prj.urlIndex
      _projects[prj.url][prj.id] =
        text: prj.text
        show: _projects[prj.url][prj.id].show or prj.show
        queryId: prj.queryId

      # update selectable
      for p, i in _selectableProjects when p.equals prj
        _selectableProjects.splice i, 1
        break
      if _projects[prj.url][prj.id].show isnt SHOW.NOT
        _selectableProjects.push prj
      _setLocal()


    ###
     remove a project, and update urlIndex.
    ###
    remove: (url, id) ->
      delete _projects[url][id]
      if Object.keys(_projects[url]).length is 1
        delete _projects[url]
        # update urlIndex
        i = 0
        for redmineUrl, params of _projects
          _projects[redmineUrl].index = i++
      for p, i in _selectableProjects when p.equals {url: url, id: id}
        _selectableProjects.splice i, 1
        break
      _setLocal()


    ###
     remove projects on url, and update urlIndex.
    ###
    removeUrl: (url) ->
      for k, v of _projects[url]
        continue if k is 'index'
        @remove url, k


    ###
     load all projects from chrome sync.
    ###
    load: (callback) ->
      _load Chrome.storage.local, (local) =>
        if local?
          console.log 'project loaded from local'
          @set local
          callback local
        else
          _load Chrome.storage.sync, (sync) =>
            console.log 'project loaded from sync'
            @set sync
            callback sync


    ###
     sync all projects to chrome sync.
    ###
    sync: (callback) ->
      _set _projects, Chrome.storage.sync, callback
      count = 0
      for k, v of _projects
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
      for url, params of _projects then delete _projects[url]
      _selectableProjects.clear()
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

  }
)
