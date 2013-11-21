timeTracker.factory("$redmine", ['$http', 'Base64', ($http, Base64) ->

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


  ###
   set basic configs for $http.
  ###
  _setBasicConfig = (config, auth) ->
    config.headers = "Content-Type": CONTENT_TYPE
    config.timeout = AJAX_TIME_OUT
    auth.decrypt?()
    if auth.apiKey? and auth.apiKey.length > 0
      config.headers["X-Redmine-API-Key"] = auth.apiKey
    else
      $http.defaults.headers.common['Authorization'] = 'Basic ' + Base64.encode(auth.id + ':' + auth.pass)
    return config


  ###
   convert json to xml.
  ###
  _JSONtoXML = (obj, depth) ->
    result = ""
    indent = ""
    depth = depth || 0

    i = depth
    while --i > 0 then indent += "  "
    for key, val of obj
      name = key
      if key.match(/^\d+$/) then name = "item"
      if typeof(val) is "object"
        result += indent + "<" + name + ">\n"
        depth++
        result += _JSONtoXML(val, depth)
        depth--
        result += indent + "</" + name + ">\n"
      else
        val = '' + val
        val = val.replace(/&amp;/g, "&").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
        result += indent + "<" + name + ">" + val + "</" + name + ">\n"

    return result


  equals = (y) ->
    return @url is y.url and @id is y.id


  return (auth) ->

    issues:

      ###
       load issues following selected project
      ###
      get: (success, error, params) ->
        params.limit = 100
        config =
          method: "GET"
          url: auth.url + "/issues.json"
          params: params
        config = _setBasicConfig config, auth
        $http(config)
          .success( (data, status, headers, config) ->
            if data?.issues?
              data.issues = for issue in data.issues
                issue.show = SHOW.DEFAULT
                issue.url = auth.url
                issue.equals = equals
                issue
            success?(data, status, headers, config))
          .error(error or NULLFUNC)


      ###
       Load tickets associated to user ID.
      ###
      getOnUser: (success, error) ->
        params =
          assigned_to_id: auth.userId
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
      submitTime: (issueId, comment, hours, success, error) ->
        timeEntryData.time_entry.issue_id = issueId
        timeEntryData.time_entry.hours = hours
        timeEntryData.time_entry.comments = comment
        config =
          method: "POST"
          url: auth.url + "/issues/#{timeEntryData.time_entry.issue_id}/time_entries.json"
          data: _JSONtoXML timeEntryData
        config = _setBasicConfig config, auth
        config.headers = "Content-Type": "application/xml"
        $http(config)
          .success(success or NULLFUNC)
          .error(error or NULLFUNC)


      ###
       get any ticket using id.
      ###
      getById: (issueId, success, error) ->
        config =
          method: "GET"
          url: auth.url + "/issues/#{issueId}.json"
        config = _setBasicConfig config, auth
        $http(config)
          .success( (data, status, headers, config) ->
            if data?.issue?
              data.issue.show = SHOW.DEFAULT
              data.issue.url = auth.url
            success?(data, status, headers, config))
          .error(error or NULLFUNC)


    projects:

      ###
       Load projects on url
      ###
      get: (success, error) ->
        config =
          method: "GET"
          url: auth.url + "/projects.json"
        config = _setBasicConfig config, auth
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
          url: auth.url + "/users/current.json?include=memberships"
        config = _setBasicConfig config, auth
        $http(config)
          .success(success or NULLFUNC)
          .error(error or NULLFUNC)

])

