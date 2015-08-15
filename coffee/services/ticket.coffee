timeTracker.factory("Ticket", (Project, Analytics, Chrome, Log) ->

  TICKET = "TICKET"

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

  PROJECT_NOT_FOUND = -1
  PROJECT_NOT_FOUND_NAME = "not found"

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

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
   ticket that user can select
  ###
  selectableTickets = []


  ###
   compare ticket.
   true: same / false: defferent
  ###
  _equals = (x, y) ->
    return x.url is y.url and x.id is y.id


  ###
   sort ticket by id
  ###
  selectableTickets.sortById = () ->
    this.sort (x, y) ->
      return x.id - y.id


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

      projects = Project.get()
      if Chrome.runtime.lastError?
        Log.error 'runtime error'
        callback? null; return

      if not tickets[TICKET]?
        Log.info 'project or ticket does not exists'
        callback? null; return

      synced = _syncWithProject tickets[TICKET], projects
      callback? synced.tickets, synced.missing


  ###
   syncronize tickets and projects.
   chrome format.
  ###
  _syncWithProject = (tickets, projects) ->
    tmp = []
    missing = []

    for t in tickets
      # search url
      url = PROJECT_NOT_FOUND
      for key, obj of projects when obj.index is t[TICKET_URL_INDEX]
        url = key
        break
      # url not found ...
      if url is PROJECT_NOT_FOUND
        missing.push t[TICKET_URL_INDEX]
        projectName = PROJECT_NOT_FOUND_NAME
        Log.error("ticket can not sync with project.")
        Log.error(t)
      else
        projectName = obj[t[TICKET_PRJ_ID]].text
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
    projects = Project.get()
    for t in tickets
      project = projects[t.url]
      if project?
        urlIndex = projects[t.url].index
        ticketArray.push [t.id, t.text, urlIndex, t.project.id, t.show]
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
    if not found
      tickets.push ticket
      if ticket.show is SHOW.NOT then return
      selectableTickets.push ticket
      selectableTickets.sortById()


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
                  @assigned_to,
                  @total) ->

    ###
     compare ticket.
     true: same / false: defferent
    ###
    equals: (y) ->
      return @url is y.url and @id is y.id


  return {

    ###
     get all tickets.
    ###
    get: () ->
      return tickets


    ###
     get selectable tickets.
    ###
    getSelectable: () ->
      return selectableTickets


    ###
     set tickets.
    ###
    set: (ticketslist, callback) ->
      Log.debug 'Ticket.set()'
      if not ticketslist? then return

      tickets.clear()

      for t in ticketslist
        tickets.push t
        if t.show is SHOW.NOT then continue
        selectableTickets.push t

      selectableTickets.sortById()

      _setLocal(callback)


    ###
     add ticket.
     if ticket can be shown, it's added to selectable.
     if ticket can be shown and there is no selected ticket, it be selected.
    ###
    add: (ticket) ->
      Log.debug 'Tikcet.add()'
      _add(ticket)
      _setLocal()


    ###
     add ticket array.
    ###
    addArray: (arr) ->
      Log.debug 'Tikcet.addArray()'
      if not arr? then return
      for t in arr then _add t
      _setLocal()


    ###
     remove ticket when exists.
    ###
    remove: (ticket) ->
      Log.debug 'Tikcet.remove()'
      if not ticket? then return
      for t, i in tickets when _equals(t, ticket)
        tickets.splice(i, 1)
        break
      for t, i in selectableTickets when _equals(t, ticket)
        selectableTickets.splice(i, 1)
        break
      _setLocal()


    ###
     remove ticket associated to url.
    ###
    removeUrl: (url) ->
      Log.debug 'Tikcet.removeUrl()'
      if not url? then return
      newTickets = (t for t in tickets when t.url isnt url)
      tickets.clear()
      selectableTickets.clear()
      @addArray newTickets
      _setLocal()


    ###
     set any parameter to ticket.
     if ticket can be shown, it be added to selectable.
     if ticket cannot be shown, it be deleted from selectable.
    ###
    setParam: (url, id, param) ->
      Log.debug 'Tikcet.setParam()'
      if not url? or not id? or not param? then return
      # update parameter
      target = tickets.find (t) -> _equals(t, {url: url, id: id})
      for k, v of param then target[k] = v
      if target.show is SHOW.NOT
        # delete from selectable
        for t, i in selectableTickets when _equals(t, {url: url, id: id})
          selectableTickets.splice(i, 1)
          break
      else
        # add selectable
        found = selectableTickets.some (ele) -> _equals target, ele
        if not found
          selectableTickets.push target
          selectableTickets.sortById()
      _setLocal()


    ###
     load all tickets from chrome sync.
    ###
    load: (callback) ->
      _loadLocal (localTickets, missingUrlIndex) =>
        if localTickets?
          Log.info 'tikcet loaded from local'
          Log.groupCollapsed 'tikcet loaded'
          Log.table localTickets
          Log.groupEnd 'tikcet loaded'
          @set localTickets, (res, msg) ->
            if not missingUrlIndex.isEmpty()
              msg = msg or {}
              msg = Object.merge(msg, {missing: missingUrlIndex})
            callback localTickets, msg
        else
          _loadSync (syncTickets, missingUrlIndex) =>
            Log.info 'tikcet loaded from sync'
            Log.groupCollapsed 'tikcet loaded'
            Log.table localTickets
            Log.groupEnd 'tikcet loaded'
            @set syncTickets, (res, msg) ->
              if not missingUrlIndex.isEmpty()
                msg = msg or {}
                msg = Object.merge(msg, {missing: missingUrlIndex})
              callback syncTickets, msg


    ###
     sync all tickets to chrome sync.
    ###
    sync: (callback) ->
      _setSync callback


    ###
     create new TicketModel instance.
    ###
    new: (params) ->
      return new TicketModel(params.id,
                             params.text,
                             params.url,
                             params.project,
                             params.show,
                             params.priority,
                             params.assigned_to
                             params.total)


    ###
     clear ticket data on storage and local.
    ###
    clear: (callback) ->
      Log.debug 'Tikcet.clear()'
      tickets.clear()
      selectableTickets.clear()
      Chrome.storage.local.set TICKET: []
      Chrome.storage.sync.set TICKET: [], () ->
      if Chrome.runtime.lastError?
        callback? false
      else
        callback? true
  }
)
