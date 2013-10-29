timeTracker.factory("$ticket", () ->

  TICKET = "TICKET"
  PROJECT = "PROJECT"

  TICKET_ID      = 0
  TICKET_SUBJECT = 1
  TICKET_PRJ_URL = 2
  TICKET_PRJ_ID  = 3
  TICKET_SHOW    = 4

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


  return {

    ###
     ticket using this app
    ###
    tickets: []


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
      for t in @tickets
        ticketArray.push [t.id, t.subject, t.url, t.project.id, t.show]
      chrome.storage.sync.set TICKET: ticketArray, () ->
        if chrome.runtime.lastError?
          callback? false
        else
          callback? true

      projectObj = {}
      for t in @tickets
        projectObj[t.url] = projectObj[t.url] or {}
        projectObj[t.url][t.project.id] = t.project.name
      chrome.storage.sync.set PROJECT: projectObj

  }
)
