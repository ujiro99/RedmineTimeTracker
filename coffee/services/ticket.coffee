timeTracker.factory("Ticket", (Project, Analytics, Chrome) ->

  TICKET = "TICKET"

  TICKET_ID        = 0
  TICKET_TEXT      = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

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
  #     ticket = { id, text, project_url_index, project_id, show }
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
   ticket that user selected
  ###
  selectedTickets = []


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
   get tickets from local storage.
  ###
  _getLocal = (callback) ->
    _get(Chrome.storage.local, callback)


  ###
   get tickets from sync storage.
  ###
  _getSync = (callback) ->
    _get(Chrome.storage.sync, callback)


  ###
   get tickets from any area.
  ###
  _get = (storage, callback) ->
    if not storage? then callback? null; return

    storage.get TICKET, (tickets) ->
      if Chrome.runtime.lastError?
        console.debug 'runtime error'
        callback? null; return

      Project.load (projects) ->
        if Chrome.runtime.lastError?
          console.debug 'runtime error'
          callback? null; return

        if not tickets[TICKET]?
          console.debug 'project or ticket does not exists'
          callback? null; return

        tmp = []
        for t in tickets[TICKET]
          # search url
          for url, obj of projects when obj.index is t[TICKET_URL_INDEX]
            break
          tmp.push new TicketModel(
            t[TICKET_ID],
            t[TICKET_TEXT],
            url,
            {
              id: t[TICKET_PRJ_ID]
            },
            t[TICKET_SHOW])

        callback? tmp


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
    if not storage? then callback? null; return
    ticketArray = []
    projects = Project.get()
    for t in tickets
      urlIndex = projects[t.url].index
      ticketArray.push [t.id, t.text, urlIndex, t.project.id, t.show]
    storage.set TICKET: ticketArray, () ->
      if Chrome.runtime.lastError?
        callback? false
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
     get selected tickets.
    ###
    getSelected: () ->
      return selectedTickets


    ###
     set tickets.
    ###
    set: (ticketslist) ->
      console.log 'tikcet set'
      if not ticketslist? then return

      tickets.clear()

      for t in ticketslist
        tickets.push t
        if t.show is SHOW.NOT then continue
        selectableTickets.push t

      selectableTickets.sortById()
      if selectableTickets.length isnt 0
        selectedTickets[0] = selectableTickets[0]

      _setLocal(callback)


    ###
     add ticket.
     if ticket can be shown, it's added to selectable.
     if ticket can be shown and there is no selected ticket, it be selected.
    ###
    add: (ticket) ->
      _add(ticket)
      if ticket.show isnt SHOW.NOT
        if selectedTickets.length is 0
          selectedTickets.push ticket
        if not selectedTickets[0]?
          selectedTickets[0] = ticket
      _setLocal()


    ###
     add ticket array.
    ###
    addArray: (arr) ->
      console.log 'tikcet addArray'
      if not arr? then return
      for t in arr then _add t
      if selectedTickets.length is 0
        selectedTickets.push selectableTickets[0]
      if not selectedTickets[0]?
        selectedTickets[0] = selectableTickets[0]
      _setLocal()


    ###
     remove ticket when exists.
    ###
    remove: (ticket) ->
      if not ticket? then return
      for t, i in tickets when _equals(t, ticket)
        tickets.splice(i, 1)
        break
      for t, i in selectableTickets when _equals(t, ticket)
        selectableTickets.splice(i, 1)
        break
      selectedTickets[0] = selectableTickets[0]
      _setLocal()


    ###
     remove ticket associated to url.
    ###
    removeUrl: (url) ->
      if not url? then return
      newTickets = (t for t in tickets when t.url isnt url)
      tickets.clear()
      selectableTickets.clear()
      @addArray newTickets
      selectedTickets[0] = selectableTickets[0]
      _setLocal()


    ###
     set any parameter to ticket.
     if ticket can be shown, it be added to selectable.
     if ticket cannot be shown, it be deleted from selectable.
    ###
    setParam: (url, id, param) ->
      if not url? or not id? or not param? then return
      # update parameter
      target = tickets.find (t) -> _equals(t, {url: url, id: id})
      for k, v of param then target[k] = v
      if target.show is SHOW.NOT
        # delete from selectable
        for t, i in selectableTickets when _equals(t, {url: url, id: id})
          selectableTickets.splice(i, 1)
          break
        isSelected = selectedTickets.some (ele) -> _equals target, ele
        if isSelected
          selectedTickets[0] = selectableTickets[0]
      else
        # add selectable
        found = selectableTickets.some (ele) -> _equals target, ele
        if not found
          selectableTickets.push target
          selectableTickets.sortById()
        # show in selection
        if selectedTickets.isEmpty()
          selectedTickets[0] = selectableTickets[0]
      _setLocal()


    ###
     load all tickets from chrome sync.
    ###
    load: (callback) ->
      _getLocal (localTickets) ->
        if localTickets?
          console.log 'tikcet loaded from local'
          callback localTickets
        else
          _getSync (syncTickets) ->
            console.log 'tikcet loaded from sync'
            callback syncTickets


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
      tickets.clear()
      selectableTickets.clear()
      selectedTickets.clear()
      Chrome.storage.local.set TICKET: []
      Chrome.storage.sync.set TICKET: [], () ->
      if Chrome.runtime.lastError?
        callback? false
      else
        callback? true
  }
)
