timeTracker.factory("Project", ($q, EventDispatcher, Analytics, Platform, Const, Log) ->

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
     @param urlIndex {Number} project id's index on Platform.storage.
     @param id {Number} project id.
     @param text {String} project's name.
     @param show {Number} can this project show? (DEFAULT: 0, NOT: 1, SHOW: 2)
     @param queryId {Number} Used query ID
     @param tickets {Array} Array of TicketModel.
    ###
    constructor: (@url, urlIndex, id, @text, show, queryId, tickets) ->
      @id = id - 0
      isNaN(urlIndex) or @urlIndex = urlIndex - 0
      isNaN(show) or @show = show - 0
      isNaN(queryId) or @queryId = queryId - 0
      Const.ISSUE_PROPS.map (p) => @[p] = []
      @_tickets = []
      @tickets = new Proxy(@_tickets, @updateProperties(@))

    ###
     update property related to project.
     @param projectModel {ProjectModel} target project.
    ###
    updateProperties: (projectModel) ->

      # Initialize property map.
      tmp = {}
      Const.ISSUE_PROPS.map (prop) -> tmp[prop] = {}

      return {

        ###*
         Properties map on this project.
         @type {Object}
        ###
        _props: tmp

        ###*
         Called on ticket changes.
         @param tickets {Array} Target object.
         @param index {String} Property name.
         @param ticket {TicketModel} New ticket.
        ###
        set: (tickets, index, ticket) ->
          Log.time("updateProperties #{projectModel.text}\t")
          if tickets.isEmpty()
            for prop, val of @_props
              for p, v of val then delete val[p]
          # create each property's id/name object. Id must be unique.
          Const.ISSUE_PROPS.map (prop) =>
            ticket[prop] and @_props[prop][ticket[prop].id] = ticket[prop].name
          Const.ISSUE_PROPS.map (prop) =>
            # create id/name pair array.
            tmpArray = Object.toKeyValuePair(@_props[prop], {key: "id", value: "name"})
            tmpArray.add({id: "", name: "All"}, 0)
            tmpArray.map (t) -> t.checked = true
            # restore old checked status
            projectModel[prop].map (oldOption) ->
              newOption = tmpArray.find (n) -> n.id is oldOption.id
              newOption.checked = oldOption.checked if newOption
            projectModel[prop].set(tmpArray)
          # set changed ticket
          tickets[index] = ticket
          Log.timeEnd("updateProperties #{projectModel.text}\t")
          # Log.info(projectModel)
          projectModel.fireEvent(projectModel.UPDATED, projectModel)
          return true
      }

    ###
     compare project.
     true: same / false: different
    ###
    equals: (y) ->
      return false if not y?
      return @url is y.url and @id is y.id


  class Project

    # class variables
    @PROJECT = "PROJECT"

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

    ###
     convert projects to format of chrome. all projects are unique.
     @param {Array} projects - array of ProjectModel
     @return {Object} project object on chrome format.
    ###
    _toChromeObjects: (projects) ->
      return {} if not projects
      result = {}
      projects.map (prj) ->
        # initialize if not exists
        result[prj.url] = result[prj.url] or {}
        target = result[prj.url][prj.id] = result[prj.url][prj.id] or {}
        # set params
        if result[prj.url].index >= 0
          prj.urlIndex = result[prj.url].index
        else
          prj.urlIndex = Object.keys(result).length - 1
        result[prj.url].index = prj.urlIndex
        target.show    = if prj.show? then prj.show else target.show
        target.queryId = if prj.queryId? then prj.queryId else target.queryId
      return result


    ###
     convert projects to ProjectModel.
     @param  {Object} project object on chrome format.
     @return {Array}  projects - array of ProjectModel
    ###
    _toProjectModels: (projects) ->
      result = []
      for url, obj of projects
        for k, v of obj
          continue if k is "index"
          result.push new ProjectModel(url,
                                       obj.index - 0,
                                       k - 0,
                                       v.text,
                                       v.show - 0,
                                       v.queryId - 0)
      return result


    ###*
     load all projects from chrome sync.
    ###
    load: () =>
      Log.debug "Project.load() start"
      return Platform.load(Project.PROJECT)
        .then((projects) =>
          if not projects
            Log.info 'Project does not exists, initialized.'
            projects = {}
          Analytics.sendEvent 'project', 'count', 'onLoad', projects.length
          Log.debug "Project.load() loaded"
          return @_toProjectModels(projects)
        , () ->
          Analytics.sendEvent 'project', 'count', 'onLoad', 0
          Log.debug "Project.load() failed"
          return $q.reject(null))


    ###
     sync all projects to chrome sync.
    ###
    sync: (projects) ->
      data = @_toChromeObjects(projects)
      Platform.save(Project.PROJECT, data)
        .then((res) ->
          Log.info 'project synced.'
          Analytics.sendEvent 'project', 'sync', 'success', 1
          return res
        , (res) ->
          Log.info 'project sync failed.'
          Analytics.sendEvent 'project', 'sync', 'failed', 1
          return res)


    ###
     save all project to local.
    ###
    syncLocal: (projects) ->
      data = @_toChromeObjects(projects)
      Platform.saveLocal(Project.PROJECT, data)
      .then((res) ->
        Log.info 'project synced.'
        Analytics.sendEvent 'project', 'sync', 'success', 1
        return res
      , (res) ->
        Log.info 'project sync failed.'
        Analytics.sendEvent 'project', 'sync', 'failed', 1
        return res)


    ###
     create new Model instance.
    ###
    create: (params) ->
      new ProjectModel(params.url,
                       params.urlIndex,
                       params.id,
                       params.text,
                       params.show,
                       params.queryId)


  return new Project()

)
