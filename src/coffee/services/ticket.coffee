timeTracker.factory("Ticket", ($q, Project, Analytics, Platform, Log) ->

  TICKET = "TICKET"

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

  PROJECT_NOT_FOUND = -1
  PROJECT_NOT_FOUND_NAME = "not found"
  NOT_CONFIGED = { id: -1, name: "Not Assigned"}


  ###*
   Ticket data model.
   @class TicketModel
  ###
  class TicketModel

    ###*
     constructor.
     @constructor
    ###
    constructor: (@id,
                  @text,
                  @url,
                  @project,
                  @show,
                  @priority,
                  @assignedTo,
                  @status,
                  @tracker,
                  @total) ->

    ###*
     compare ticket.
     true: same / false: different
    ###
    equals: (y) ->
      return @url is y.url and @id is y.id

    hash: () -> return @url + @id


  #
  # - in this app,
  #
  #     ticket = {
  #       id: ,
  #       text: ,
  #       url: ,
  #       project: ,
  #         id: project_id
  #         text: ,
  #       show:
  #     }
  #
  # - in chrome sync,
  #
  #     ticket = [ id, text, project_url_index, project_id, show ]
  #


  ###*
   Synchronize tickets and projects using urlIndex.
   @param {Array} tickets - tickets of chrome format.
   @param {Array} projects - ProjectModel.
  ###
  _syncWithProject = (tickets, projects) ->
    tmp = []
    missing = []

    for t in tickets
      # search url
      url = PROJECT_NOT_FOUND
      for projectModel in projects when projectModel.urlIndex is t[TICKET_URL_INDEX]
        url = projectModel.url
        break
      if url isnt PROJECT_NOT_FOUND
        projectName = projectModel.text
      else
        missing.push t[TICKET_URL_INDEX]
        projectName = PROJECT_NOT_FOUND_NAME
        Log.error("This ticket cannot synced to project.")
        Log.error(t)
      tmp.push new TicketModel(
        t[TICKET_ID],
        t[TICKET_TEXT],
        url,
        { id: t[TICKET_PRJ_ID], name: projectName},
        t[TICKET_SHOW])

    return { tickets: tmp, missing: missing }


  ###*
   Save all tickets to any area.
   @param {Array} tickets - Array of TicketModel.
   @param {Bool}  isLocal - If true, save data to local storage area.
  ###
  _sync = (tickets, isLocal) ->

    ticketArray = []
    errorTickets = []

    deferred = $q.defer()
    promise = deferred.promise
      .then(Project.load)
      .then((projects) ->
        for t in tickets
          prj = projects.find (p) -> p.url is t.url
          if prj?
            ticketArray.push [t.id, t.text, prj.urlIndex, t.project.id, t.show]
          else
            ticketArray.push [t.id, t.text, PROJECT_NOT_FOUND, t.project.id, t.show]
            errorTickets.push id: t.id, text: t.text, url: t.url, projectId: t.project.id, show: t.show

        area = if isLocal then "local" else "sync"
        Log.groupCollapsed "Ticket.sync: " + area
        Log.table tickets
        Log.debug "to chrome"
        Log.table ticketArray
        Log.groupEnd "Ticket.sync: " + area

        # save to storage
        if isLocal
          return Platform.saveLocal(TICKET, ticketArray)
        else
          return Platform.save(TICKET, ticketArray)
      , () ->
        $q.reject({message: "Couldn't sync with project."}))
      .then(() ->
        if not errorTickets.isEmpty()
          Analytics.sendException("Error: Project not found on Ticket.sync().")
          return {
            message: "Some projects not found."
            missing: errorTickets
          }
      , (res) ->
        if not res
          $q.reject {message: "Couldn't save tickets."}
        else
          $q.reject res)
    deferred.resolve()
    return  promise


  ###*
   Fix parameter's status.
  ###
  _sanitize = (params) ->
    if not params.assigned_to then params.assigned_to = NOT_CONFIGED


  return {

    ###*
     load all tickets from chrome sync.
    ###
    load: () ->
      Log.debug "Ticket.load() start"
      return Platform.load(TICKET)
      .then((tickets) =>
        if not tickets
          Log.info 'Ticket does not exists, initialized.'
          tickets = []
        Project.load().then (projects) ->
          if not tickets or not projects
            Log.info 'Project does not exists.'
          synced = _syncWithProject tickets, projects
          Analytics.sendEvent 'ticket', 'count', 'onLoad', tickets.length
          Log.debug "Ticket.load() success"
          return synced
      , () ->
        Analytics.sendEvent 'ticket', 'count', 'onLoad', 0
        Log.debug "Ticket.load() failed"
        return $q.reject(null))


    ###*
     sync all tickets to chrome sync.
    ###
    sync: (tickets) ->
      _sync(tickets)
        .then((res) ->
          Log.info 'ticket synced.'
          Analytics.sendEvent 'ticket', 'sync', 'success', 1
          return res
        , (res) ->
          Log.info 'ticket sync failed.'
          Analytics.sendEvent 'ticket', 'sync', 'failed', 1
          $q.reject(res))


    ###*
     save all tickets to local.
    ###
    syncLocal: (tickets) ->
      _sync tickets, true


    ###*
     create new TicketModel instance.
    ###
    create: (params) ->
      _sanitize(params)
      return new TicketModel(params.id,
                             params.text,
                             params.url,
                             params.project,
                             params.show,
                             params.priority,
                             params.assigned_to
                             params.status
                             params.tracker
                             params.total)


    ###*
     clear ticket data on storage and local.
    ###
    clear: (callback) ->
      Log.debug 'Ticket.clear()'
      Platform.storage.local.set TICKET: []
      Platform.storage.sync.set TICKET: [], () ->
        if Platform.runtime.lastError?
          callback? false
        else
          callback? true
  }
)
