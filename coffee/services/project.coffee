timeTracker.factory("Project", (Analytics) ->

  PROJECT = "PROJECT"
  URL_INDEX_START = 1  # for avoid 0 == false
  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  # - in chrome sync,
  #
  #     project = {
  #       value of url:
  #         index: project_url_index
  #         value of project_id:
  #           text: project_name
  #           show: true/false
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
   compare projects.
  ###
  _equals = (x, y) ->
    x.url is y.url and x.id is y.id


  ###
   load from any area.
  ###
  _get = (storage, callback) ->
    if not storage? then callback? null; return
    storage.get PROJECT, (projects) ->
      if chrome.runtime.lastError? then callback? null; return
      if not projects[PROJECT]? then callback? null; return
      if Object.keys(projects[PROJECT]).length is 0 then callback? null; return
      callback? projects[PROJECT]


  ###
   save all project to any area.
  ###
  _set = (projects, storage, callback) ->
    storage.set PROJECT: projects, () ->
      if chrome.runtime.lastError?
        callback? false
      else
        callback? true


  ###
   save all project to local.
  ###
  _setLocal = (callback) ->
    _set _projects, chrome.storage.local, callback


  ###
   Project data model.
  ###
  class ProjectModel

    ###
     constructor.
    ###
    constructor: (@url, @urlIndex, @id, @text, @show) ->

    ###
     compare project.
     true: same / false: defferent
    ###
    equals: (y) ->
      return @url is y.url and @id is y.id


  return {


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
      tmp = {}
      _selectableProjects.clear()
      for url, params of newProjects then tmp[url] = params
      for url, params of _projects then delete _projects[url]
      for url, params of tmp
        _projects[url] = params
        urlIndex = params.index
        for k, v of params
          if k isnt 'index'
            id = k - 0
            text = v.text or v              # for compatibility
            show = v.show or SHOW.DEFAULT
            _projects[url][id] = {}         # for compatibility
            _projects[url][id].text = text  # for compatibility
            _projects[url][id].show = show  # for compatibility
            prj = new ProjectModel(url, urlIndex, id, text, show)
            if prj.show isnt SHOW.NOT
              _selectableProjects.push prj
      _setLocal()


    ###
     set parameter to project.
    ###
    setParam: (url, id, params) ->
      # set param
      if not url? or not url? or not id? then return
      for k, v of params
        _projects[url][id][k] = v
      # update selectable
      prj = new ProjectModel(url,
                             _projects[url].index,
                             id,
                             _projects[url][id].text,
                             _projects[url][id].show)
      for p, i in _selectableProjects when p.equals prj
        _selectableProjects.splice i, 1
        break
      if _projects[url][id].show isnt SHOW.NOT
        _selectableProjects.push prj
      _setLocal()


    ###
     add a project. all projects are unique.
    ###
    add: (project) ->
      prj = new ProjectModel(project.url,
                             project.urlIndex,
                             project.id,
                             project.text,
                             project.show)

      # initialize if not exists
      _projects[prj.url] = _projects[prj.url] or {}
      _projects[prj.url][prj.id] = _projects[prj.url][prj.id] or {}
      prj.urlIndex = _projects[prj.url].index or Object.keys(_projects).length + URL_INDEX_START
      _projects[prj.url]['index'] = prj.urlIndex
      _projects[prj.url][prj.id] =
        text: prj.text
        show: _projects[prj.url][prj.id].show or prj.show

      # update selectable
      for p, i in _selectableProjects when p.equals prj
        _selectableProjects.splice i, 1
        break
      if prj.show isnt SHOW.NOT
        _selectableProjects.push prj
      _setLocal()


    ###
     load all projects from chrome sync.
    ###
    load: (callback) ->
      _get chrome.storage.local, (local) =>
        if local?
          console.log 'project loaded from local'
          @set local
          callback local
        else
          _get chrome.storage.sync, (sync) =>
            console.log 'project loaded from sync'
            @set sync
            callback sync


    ###
     sync all projects to chrome sync.
    ###
    sync: (callback) ->
      _set _projects, chrome.storage.sync, callback
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
                       params.show)

  }
)
