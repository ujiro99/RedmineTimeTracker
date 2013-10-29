timeTracker.factory("$ticket", () ->

  TICKET = "TICKET"
  PROJECT = "PROJECT"

  #
  # - in this app,
  #
  #     ticket = {
  #       id: ,
  #       subject: ,
  #       project: ,
  #         url: ,
  #         id: ,
  #         name:
  #     }
  #
  # - in chrome sync,
  #
  #     ticket = [ id, subject, project_url, project_id ]
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
              id:      t[0]
              subject: t[1]
              project:
                url:   t[2]
                id:    t[3]
                name:  projects[t[2]]?[t[3]]
            }

          @tickets = tmp
          callback? tickets


    ###
     set all tickets to chrome sync
    ###
    submit: (tickets, callback) ->
      if not tickets? then callback? false; return

      @tickets = tickets

      ticketArray = []
      for t in tickets
        ticketArray.push [t.id, t.subject, t.url, t.project.id]
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
