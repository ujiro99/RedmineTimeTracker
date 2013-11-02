timeTracker.factory("$ticket", () ->

  TICKET = "TICKET"
  PROJECT = "PROJECT"
  INDEX = "INDEX"

  TICKET_ID        = 0
  TICKET_SUBJECT   = 1
  TICKET_URL_INDEX = 2
  TICKET_PRJ_ID    = 3
  TICKET_SHOW      = 4

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  #
  # - in this app,
  #
  #     ticket = {
  #       id: ,
  #       subject: ,
  #       url: ,
  #       project: ,
  #         id: ,
  #         name: ,
  #       show:
  #     }
  #
  # - in chrome sync,
  #
  #     ticket = [ id, subject, project_url_index, project_id, show ]
  #
  #     project = {
  #       url:
  #         id: name
  #     }
  #
  #     index = [ project_url ]
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
  equals = (x, y) ->
    return x.url is y.url and x.id is y.id


  ###
   sort ticket by id
  ###
  selectableTickets.sortById = () ->
    this.sort (x, y) ->
      return x.id - y.id


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
      if not ticketslist? then return

      tickets.clear()

      for t in ticketslist
        tickets.push t
        if t.show is SHOW.NOT then return
        selectableTickets.push t

      selectableTickets.sortById()
      if selectableTickets.length isnt 0
        selectedTickets[0] = selectableTickets[0]


    ###
     add ticket.
     if ticket can be shown, it's added to selectable.
    ###
    add: (ticket) ->
      if not ticket? then return
      found = tickets.some (ele) -> equals ele, ticket
      if not found
        tickets.push ticket
        if ticket.show is SHOW.NOT then return
        selectableTickets.push ticket
        selectableTickets.sortById()
        if selectedTickets.length is 0
          selectedTickets.push ticket


    ###
     add ticket array.
    ###
    addArray: (arr) ->
      if not arr? then return
      for t in arr then @add t


    ###
     remove ticket when exists.
    ###
    remove: (ticket) ->
      if not ticket? then return
      for t, i in tickets when equals(t, ticket)
        tickets.splice(i, 1)
        break
      for t, i in selectableTickets when equals(t, ticket)
        selectableTickets.splice(i, 1)
        selectedTickets[0] = selectableTickets[0]
        break


    ###
     set any parameter to ticket.
     if ticket can be shown, it be added to selectable.
     if ticket cannot be shown, it be deleted from selectable.
    ###
    setParam: (url, id, param) ->
      if not url? or not url? or not id? then return
      for t in tickets when equals(t, {url: url, id: id})
        for k, v of param then t[k] = v
        if t.show isnt SHOW.NOT
          selectableTickets.push t
          selectableTickets.sortById()
        break
      for t, i in selectableTickets when equals(t, {url: url, id: id})
        for k, v of param then t[k] = v
        if t.show is SHOW.NOT
          selectableTickets.splice(i, 1)
          selectedTickets[0] = selectableTickets[0]
        break


    ###
     load all tickets from chrome sync
    ###
    load: (callback) ->

      chrome.storage.sync.get TICKET, (tickets) ->
        if chrome.runtime.lastError? then callback? null; return

        chrome.storage.sync.get PROJECT, (projects) ->
          if chrome.runtime.lastError? then callback? null; return

          chrome.storage.sync.get INDEX, (index) ->
            if chrome.runtime.lastError? then callback? null; return
            if not (tickets[TICKET]? and index[INDEX]? and projects[PROJECT]?)
              callback? null
              return

            tmp = []
            for t in tickets[TICKET] when t?
              url = index[INDEX][t[TICKET_URL_INDEX]]
              tmp.push {
                id:      t[TICKET_ID]
                subject: t[TICKET_SUBJECT]
                url:     url
                project:
                  id:    t[TICKET_PRJ_ID]
                  name:  projects[PROJECT][url][t[TICKET_PRJ_ID]]
                show:    t[TICKET_SHOW]
              }

            callback? tmp


    ###
     sync all tickets to chrome sync
    ###
    sync: (callback) ->

      urlIndex = []
      projectObj = {}
      for t in tickets
        projectObj[t.url] = projectObj[t.url] or {}
        projectObj[t.url][t.project.id] = t.project.name
      for url, v of projectObj
        urlIndex.push url
      ticketArray = []
      for t in tickets
        for url, i in urlIndex when url is t.url then index = i
        ticketArray.push [t.id, t.subject, index, t.project.id, t.show]

      chrome.storage.sync.set PROJECT: projectObj
      chrome.storage.sync.set INDEX: urlIndex
      chrome.storage.sync.set TICKET: ticketArray, () ->
        if chrome.runtime.lastError?
          callback? false
        else
          callback? true

  }
)
