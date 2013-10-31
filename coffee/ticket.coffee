timeTracker.factory("$ticket", () ->

  TICKET = "TICKET"
  PROJECT = "PROJECT"

  TICKET_ID      = 0
  TICKET_SUBJECT = 1
  TICKET_PRJ_URL = 2
  TICKET_PRJ_ID  = 3
  TICKET_SHOW    = 4

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
  #     ticket = [ id, subject, project_url, project_id, show ]
  #


  ###
   ticket using this app
  ###
  tickets = []


  ###
   ticket that user can select
  ###
  selectableTickets = []


  equals = (x, y) ->
    return x.url is y.url and x.id is y.id


  return {


    get: () ->
      return tickets


    getSelectable: () ->
      return selectableTickets


    add: (ticket) ->
      if not ticket? then return
      found = tickets.some (ele) -> equals ele, ticket
      if not found then tickets.push ticket
      if ticket.show is SHOW.NOT then return
      found = selectableTickets.some (ele) -> equals ele, ticket
      if not found then selectableTickets.push ticket


    addArray: (arr) ->
      if not arr? then return
      for t in arr then @add t


    remove: (ticket) ->
      if not ticket? then return
      for t, i in tickets when equals(t, ticket)
        tickets.splice(i, 1)
        break
      for t, i in selectableTickets when equals(t, ticket)
        selectableTickets.splice(i, 1)
        break


    setParam: (url, id, param) ->
      if not url? or not url? or not id? then return
      for t in tickets when equals(t, {url: url, id: id})
        for k, v of param then t[k] = v
        break
      for t, i in selectableTickets when equals(t, {url: url, id: id})
        for k, v of param then t[k] = v
        if t.show is SHOW.NOT then selectableTickets.splice(i, 1)
        break


    ###
     load all tickets from chrome sync
    ###
    load: (callback) ->

      chrome.storage.sync.get TICKET, (tickets) ->
        if chrome.runtime.lastError? then callback? null; return

        chrome.storage.sync.get PROJECT, (projects) ->
          if chrome.runtime.lastError? then callback? null; return

          tmp = []
          for t in tickets[TICKET]
            tmp.push {
              id:      t[TICKET_ID]
              subject: t[TICKET_SUBJECT]
              url:   t[TICKET_PRJ_URL]
              project:
                id:    t[TICKET_PRJ_ID]
                name:  projects[PROJECT][t[TICKET_PRJ_URL]][t[TICKET_PRJ_ID]]
              show:    t[TICKET_SHOW]
            }

          callback? tmp


    ###
     sync all tickets to chrome sync
    ###
    sync: (callback) ->

      ticketArray = []
      for t in tickets
        ticketArray.push [t.id, t.subject, t.url, t.project.id, t.show]
      chrome.storage.sync.set TICKET: ticketArray, () ->
        if chrome.runtime.lastError?
          callback? false
        else
          callback? true

      projectObj = {}
      for t in tickets
        projectObj[t.url] = projectObj[t.url] or {}
        projectObj[t.url][t.project.id] = t.project.name
      chrome.storage.sync.set PROJECT: projectObj

  }
)
