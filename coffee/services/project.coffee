timeTracker.factory("Project", (Analytics) ->

  PROJECT = "PROJECT"

  # - in chrome sync,
  #
  #     project = {
  #       value of url:
  #         index: project_url_index
  #         value of project_id:
  #           name: project_name
  #           show: true/false
  #     }
  #


  ###
   project list.
  ###
  _projects = {}


  ###
   compare projects.
  ###
  _equals = (x, y) ->
    x.url is y.url and x.id is y.id


  ###
   get from any area.
  ###
  _get = (storage, callback) ->
    if not storage? then callback? null; return
    storage.get PROJECT, (projects) ->
      if chrome.runtime.lastError? then callback? null; return
      if not projects[PROJECT]? then callback? null; return
      _projects = projects[PROJECT]
      callback? projects[PROJECT]


  ###
   save all project to local.
  ###
  _setLocal = (callback) ->
    _set _projects, chrome.storage.local, callback


  ###
   save all project to any area.
  ###
  _set = (projects, storage, callback) ->
    storage.set PROJECT: projects, () ->
      if chrome.runtime.lastError?
        callback? false
      else
        callback? true


  return {


    ###
     get all tickets.
    ###
    get: () ->
      return _projects


    ###
     set tickets.
    ###
    set: (newProjects) ->
      if not newProjects? then return
      for k, v of _projects
        delete _projects[k]
      for k, v of newProjects
        _projects[k] = v
      _setLocal()


    ###
     load all tickets from chrome sync.
    ###
    load: (callback) ->
      _get chrome.storage.local, (local) ->
        if local?
          console.log 'project loaded from local'
          callback local
        else
          _get chrome.storage.sync, (sync) ->
            console.log 'project loaded from sync'
            callback sync


    ###
     sync all tickets to chrome sync.
    ###
    sync: (callback) ->
      _set _projects, chrome.storage.sync, callback
      count = 0
      for k, v of _projects
        count += Object.keys(v).length - 1
      Analytics.sendEvent 'internal', 'project', 'set', count

  }
)
