timeTracker.factory("Ticket", ($q, Project, Analytics, Chrome, Log) ->

  TICKET = "TICKET"

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

  PROJECT_NOT_FOUND = -1
  PROJECT_NOT_FOUND_NAME = "not found"
  NOT_CONFIGED = { id: -1, name: "Not Assigned"}


  ###
   Ticket data model.
  ###
  class TicketModel

    ###
     constructor.
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

    ###
     compare ticket.
     true: same / false: defferent
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


  ###
   load tickets from any area.
  ###
  _load = (storage, callback) ->
    if not storage? then callback? null; return

    storage.get TICKET, (tickets) ->
      if Chrome.runtime.lastError?
        Log.error 'runtime error'
        callback? null; return

      Project.load().then (projects) ->
        if Chrome.runtime.lastError?
          Log.error 'runtime error'
          callback? null; return

        if not tickets[TICKET]?
          Log.info 'project or ticket does not exists'
          callback? null; return

        synced = _syncWithProject tickets[TICKET], projects
        callback? synced.tickets, synced.missing


  ###
   syncronize tickets and projects using urlIndex.
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


  ###
   save all tickets to any area.
  ###
  _sync = (tickets, storage) ->
    if not storage? then return

    deferred = $q.defer()
    ticketArray = []
    errorTickets = []

    # assign project data
    Project.load().then (projects) ->
      for t in tickets
        prj = projects.find (p) -> p.url is t.url
        if prj?
          ticketArray.push [t.id, t.text, prj.urlIndex, t.project.id, t.show]
        else
          ticketArray.push [t.id, t.text, PROJECT_NOT_FOUND, t.project.id, t.show]
          errorTickets.push id: t.id, text: t.text, url: t.url, projectId: t.project.id, show: t.show

      Log.groupCollapsed "Ticket.sync: " + storage.QUOTA_BYTES
      Log.table tickets
      Log.debug "to chrome"
      Log.table ticketArray
      Log.groupEnd "Ticket.sync: " + storage.QUOTA_BYTES

      # save to strage
      storage.set TICKET: ticketArray, () ->
        if Chrome.runtime.lastError?
          deferred.reject({message: "Chrome.runtime error."})
        else if not errorTickets.isEmpty()
          Analytics.sendException("Error: Project not found on Ticket.sync().")
          deferred.resolve({
            message: "Some projects not found."
            missing: errorTickets
          })
        else
          deferred.resolve()

    return deferred.promise


  ###
   fix parameter's status.
  ###
  _sanitize = (params) ->
    if not params.assigned_to then params.assigned_to = NOT_CONFIGED


  return {


    ###
     load all tickets from chrome sync.
    ###
    load: () ->
      Log.debug "Ticket.load() start"
      deferred = $q.defer()
      _load Chrome.storage.local, (localTickets, missingUrlIndex) =>
        if localTickets?
          Log.info 'ticket loaded from local'
          Log.groupCollapsed 'Ticket.load() loaded'
          Log.table localTickets
          Log.groupEnd 'Ticket.load() loaded'
          localTickets.missing = missingUrlIndex
          deferred.resolve(localTickets)
        else
          _load Chrome.storage.sync, (syncTickets, missingUrlIndex) =>
            syncTickets or syncTickets = []
            Log.info 'ticket loaded from sync'
            Log.groupCollapsed 'Ticket.load() loaded'
            Log.table localTickets
            Log.groupEnd 'Ticket.load() loaded'
            syncTickets.missing = missingUrlIndex
            deferred.resolve(syncTickets)
      return deferred.promise


    ###
     sync all tickets to chrome sync.
    ###
    sync: (tickets) ->
      _sync(tickets, Chrome.storage.sync)
        .then((res) ->
          Log.info 'ticket synced.'
          Analytics.sendEvent 'chrome', 'ticket', 'sync', tickets.length
          return res
        , (res) ->
          Log.info 'ticket sync failed.'
          Analytics.sendEvent 'chrome', 'ticket', 'syncFailed'
          $q.reject(res))


    ###
     save all tickets to local.
    ###
    syncLocal: (tickets) ->
      _sync tickets, Chrome.storage.local


    ###
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


    ###
     clear ticket data on storage and local.
    ###
    clear: (callback) ->
      Log.debug 'Ticket.clear()'
      Chrome.storage.local.set TICKET: []
      Chrome.storage.sync.set TICKET: [], () ->
        if Chrome.runtime.lastError?
          callback? false
        else
          callback? true
  }
)
