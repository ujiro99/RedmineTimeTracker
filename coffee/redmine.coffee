timeTracker.factory("$redmine", ['$http', ($http) ->

  CONTENT_TYPE = "application/json"
  AJAX_TIME_OUT = 30 * 1000
  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }
  NULLFUNC = () ->

  timeEntryData =
    "time_entry":
      "issue_id": 0
      "hours": 0
      "activity_id": 8
      "comments": ""


  issues = {}
  projects = {}
  user = {}


  return (url, apiKey, userId) ->

    issues:

      ###
       load issues following selected project
      ###
      get: (success, error, params) ->
        config =
          method: "GET"
          url: url + "/issues.json"
          headers:
            "X-Redmine-API-Key": apiKey
            "Content-Type": CONTENT_TYPE
          params: params
          timeout: AJAX_TIME_OUT
        $http(config)
          .success( (data, status, headers, config) ->
            if data?.issues?
              data.issues = for issue in data.issues
                issue.show = SHOW.DEFAULT
                issue.url = url
                issue
            success?(data, status, headers, config))
          .error(error or NULLFUNC)


      ###
       Load tickets associated to user ID.
      ###
      getOnUser: (success, error) ->
        params =
          assigned_to_id: userId
        @get(success, error, params)


      ###
       Load tickets on project.
      ###
      getOnProject: (projectId, success, error) ->
        params =
          project_id: projectId
        @get(success, error, params)


      ###
       submit time entry to redmine server.
      ###
      submitTime: (comment, hours, success, error) ->
        timeEntryData.time_entry.issue_id = userId
        timeEntryData.time_entry.hours = hours
        timeEntryData.time_entry.comments = comment
        config =
          method: "POST"
          url: url + "/issues/#{timeEntryData.time_entry.issue_id}/time_entries.json"
          headers:
            "X-Redmine-API-Key": apiKey
            "Content-Type": CONTENT_TYPE
          data: JSON.stringify(timeEntryData)
          timeout: AJAX_TIME_OUT
        $http(config)
          .success(success or NULLFUNC)
          .error(error or NULLFUNC)


    projects:

      ###
       Load projects on url
      ###
      get: (success, error) ->
        config =
          method: "GET"
          url: url + "/projects.json"
          headers:
            "X-Redmine-API-Key": apiKey
            "Content-Type": CONTENT_TYPE
          timeout: AJAX_TIME_OUT
        $http(config)
          .success( (data, status, headers, config) ->
            if data?.projects?
              data.projects = for prj in data.projects
                prj.text = prj.name
                prj
            success?(data, status, headers, config))
          .error(error or NULLFUNC)


    user:

      ###
       Load user on url associated to apiKey
      ###
      get: (success, error) ->
        config =
          method: "GET"
          url: url + "/users/current.json?include=memberships"
          headers:
            "X-Redmine-API-Key": apiKey
          timeout: AJAX_TIME_OUT
        $http(config)
          .success(success or NULLFUNC)
          .error(error or NULLFUNC)

])

