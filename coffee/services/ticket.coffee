timeTracker.factory("Ticket", ($q, Project, Analytics, Chrome, Log) ->

  TICKET = "TICKET"

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

  PROJECT_NOT_FOUND = -1
  PROJECT_NOT_FOUND_NAME = "not found"

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  NOT_CONFIGED = { id: -1, name: "Not Assigned"}

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
   ticket using this app
  ###
  tickets = []


  ###
   compare ticket.
   true: same / false: defferent
  ###
  _equals = (x, y) ->
    return x.url is y.url and x.id is y.id


  ###
   load tickets from local storage.
  ###
  _loadLocal = (callback) ->
    _load(Chrome.storage.local, callback)


  ###
   load tickets from sync storage.
  ###
  _loadSync = (callback) ->
    _load(Chrome.storage.sync, callback)


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
   save all tickets to local.
  ###
  _setLocal = (callback) ->
    _set Chrome.storage.local, callback


  ###
   save all tickets to chrome sync.
  ###
  _setSync = (callback) ->
    _set Chrome.storage.sync, callback
    Analytics.sendEvent 'internal', 'ticket', 'set', tickets.length


  ###
   save all tickets to any area.
  ###
  _set = (storage, callback) ->
    Log.groupCollapsed "ticket.set: " + storage.QUOTA_BYTES
    Log.table tickets
    if not storage? then callback? null; return
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
          errorTickets.push id: t.id, url: t.url
      # save to strage
      Log.debug "to chrome"
      Log.table ticketArray
      Log.groupEnd "ticket.set: " + storage.QUOTA_BYTES
      storage.set TICKET: ticketArray, () ->
        if Chrome.runtime.lastError?
          callback? false, {message: "Chrome.runtime error."}
        else if not errorTickets.isEmpty()
          callback? false, {
            message: "Project not found."
            param: errorTickets
          }
          Analytics.sendException("Error: Project not found on ticket._set().")
        else
          callback? true


  ###
   add ticket to all and selectable.
  ###
  _add = (ticket) ->
    if not ticket? then return
    found = tickets.some (ele) -> _equals ele, ticket
    tickets.push ticket if not found


  ###
   fix parameter's status.
  ###
  _sanitize = (params) ->
    if not params.assigned_to then params.assigned_to = NOT_CONFIGED


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


  return {

    ###
     get all tickets.
    ###
    get: () ->
      return tickets


    ###
     set tickets.
    ###
    set: (ticketslist, callback) ->
      Log.debug 'Ticket.set()'
      if not ticketslist? then callback(); return

      tickets.clear()
      for t in ticketslist
        tickets.push t

      _setLocal(callback)


    ###
     add ticket.
     if ticket can be shown, it's added to selectable.
     if ticket can be shown and there is no selected ticket, it be selected.
    ###
    add: (ticket) ->
      Log.debug 'Ticket.add()'
      _add(ticket)
      _setLocal()


    ###
     add ticket array.
    ###
    addArray: (arr) ->
      Log.debug 'Ticket.addArray()'
      if not arr? then return
      for t in arr then _add t
      _setLocal()


    ###
     remove ticket when exists.
    ###
    remove: (ticket) ->
      Log.debug 'Ticket.remove()'
      if not ticket? then return
      for t, i in tickets when _equals(t, ticket)
        tickets.splice(i, 1)
        break
      _setLocal()


    ###
     remove ticket associated to url.
    ###
    removeUrl: (url) ->
      Log.debug 'Ticket.removeUrl()'
      if not url? then return
      newTickets = (t for t in tickets when t.url isnt url)
      tickets.clear()
      @addArray newTickets
      _setLocal()


    ###
     set any parameter to ticket.
     if ticket can be shown, it be added to selectable.
     if ticket cannot be shown, it be deleted from selectable.
    ###
    setParam: (url, id, param) ->
      Log.debug 'Ticket.setParam()'
      if not url? or not id? or not param? then return
      # update parameter
      target = tickets.find (t) -> _equals(t, {url: url, id: id})
      for k, v of param then target[k] = v
      _setLocal()


    ###
     load all tickets from chrome sync.
    ###
    load: (callback) ->
      Log.debug "Ticket.load() start"
      deferred = $q.defer()
      _loadLocal (localTickets, missingUrlIndex) =>
        if localTickets?
          Log.info 'ticket loaded from local'
          Log.groupCollapsed 'Ticket.load() loaded'
          Log.table localTickets
          Log.groupEnd 'Ticket.load() loaded'
          @set localTickets, (res, msg) ->
            if not missingUrlIndex?.isEmpty()
              msg = msg or {}
              msg = Object.merge(msg, {missing: missingUrlIndex})
            deferred.resolve(localTickets, msg)
            callback(localTickets, msg)
        else
          _loadSync (syncTickets, missingUrlIndex) =>
            Log.info 'ticket loaded from sync'
            Log.groupCollapsed 'Ticket.load() loaded'
            Log.table localTickets
            Log.groupEnd 'Ticket.load() loaded'
            @set syncTickets, (res, msg) ->
              if not missingUrlIndex?.isEmpty()
                msg = msg or {}
                msg = Object.merge(msg, {missing: missingUrlIndex})
              deferred.resolve(syncTickets, msg)
              callback(syncTickets, msg)
      return deferred.promise


    ###
     sync all tickets to chrome sync.
    ###
    sync: (callback) ->
      _setSync callback


    ###
     create new TicketModel instance.
    ###
    new: (params) ->
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
      tickets.clear()
      Chrome.storage.local.set TICKET: []
      Chrome.storage.sync.set TICKET: [], () ->
        if Chrome.runtime.lastError?
          callback? false
        else
          callback? true
  }
)
