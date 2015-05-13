timeTracker.factory("DataAdapter", (Analytics) ->

  class DataAdapter

    ## class variables
    # events
    @CHANGE: "change"
    @CHANGE_SELECTED: "change_selected"

    ## instance variables
    # all account.
    _accounts: []
    # selected account.
    accounts: []
    # selected project.
    selectedProject: {}
    # selected ticket.
    selectedTicket: {}

    ###
     filter project.
    ###
    projectFilter: (keyword) ->
      if keyword.isBlank()
        accounts.set _accounts
      else
        for a,i in _accounts
          filteredProjects = []
          for p in a.projects
            if (p.id + " " + p.text).toLowerCase().contains(keyword.toLowerCase())
              filteredProjects.push p
          accounts[i].projects.set filteredProjects
      # reg = new RegExp($scope.projectSearchText, 'i')
      # return reg.test(project.id + " " + project.text)

  return new DataAdapter

)
