timeTracker.factory "Redmine", ($http, $rootScope, $q, Base64, Ticket, Project, Analytics) ->


  _redmines = {}

  return {

    ###
     get redmine instance.
    ###
    get: (auth) ->
      if not _redmines[auth.url]
        _redmines[auth.url] = new Redmine(auth, $http, $q, $rootScope, Ticket, Project, Base64)
      return _redmines[auth.url]


    ###
     remove redmine instance.
    ###
    remove: (auth) ->
      if _redmines[auth.url]?
        delete _redmines[auth.url]

  }

class Redmine

  @NOT_FOUND = 404
  @CONTENT_TYPE: "application/json"
  @AJAX_TIME_OUT: 30 * 1000
  @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }
  @NULLFUNC: () ->

  constructor: (@auth, @$http, @$q, @observer, @Ticket, @Project, @Base64) ->
    @url = auth.url

  _timeEntryData:
    "time_entry":
      "issue_id": 0
      "hours": 0
      "activity_id": 8
      "comments": ""

  getIssuesCanceler: null


  ###
   convert json to xml.
  ###
  @JSONtoXML: (obj, depth) ->
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
        result += @JSONtoXML(val, depth)
        depth--
        result += indent + "</" + name + ">\n"
      else
        val = '' + val
        val = val.replace(/&amp;/g, "&").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
        result += indent + "<" + name + ">" + val + "</" + name + ">\n"

    return result


  ###
   set basic configs for $http.
  ###
  setBasicConfig: (config, auth) ->
    config.headers = "Content-Type": Redmine.CONTENT_TYPE
    config.timeout = config.timeout or Redmine.AJAX_TIME_OUT
    if auth.apiKey? and auth.apiKey.length > 0
      config.headers["X-Redmine-API-Key"] = auth.apiKey
    else
      @$http.defaults.headers.common['Authorization'] = 'Basic ' + @Base64.encode(auth.id + ':' + auth.pass)
    return config


  ###
   load issues following selected project
  ###
  getIssues: (success, error, params) ->
    params.limit = params.limit or 100
    cancelDefer = @$q.defer()
    config =
      method: "GET"
      url: @auth.url + "/issues.json"
      params: params
      timeout: cancelDefer.promise
    config = @setBasicConfig config, @auth
    @$http(config)
      .success((data, status, headers, config) =>
        data.url = @auth.url
        if data?.issues?
          data.issues = for issue in data.issues
            issue.text    = issue.subject
            issue.show    = Redmine.SHOW.DEFAULT
            issue.url     = @auth.url
            issue.total   = issue.spent_hours or 0
            issue.project = issue.project
            new @Ticket.new(issue)
        success?(data))
      .error(error or Redmine.NULLFUNC)
    return cancelDefer


  ###
   Load tickets associated to user ID.
  ###
  getIssuesOnUser: (success, error) ->
    params =
      assigned_to_id: @auth.userId
    @getIssues(success, error, params)


  ###
   Load tickets on project.
  ###
  getIssuesOnProject: (projectId, params, success, error) ->
    params.project_id = projectId
    @getIssuesCanceler.resolve() if @getIssuesCanceler
    @getIssuesCanceler = @getIssues(success, error, params)


  ###
   get any ticket using id.
  ###
  getIssuesById: (issueId, success, error) ->
    config =
      method: "GET"
      url: @auth.url + "/issues/#{issueId}.json"
    config = @setBasicConfig config, @auth
    @$http(config)
      .success((data, status, headers, config) =>
        if data?.issue?
          data.issue.show = Redmine.SHOW.DEFAULT
          data.issue.url = @auth.url
        success?(data, status, headers, config))
      .error((data, status, headers, config) =>
        if status is Redmine.NOT_FOUND
          data = issue:
            url: @auth.url
            id:  issueId
        else
          console.debug data
          Analytics.sendException("Error: getIssuesById")
        error(data, status))


  ###
   submit time entry to redmine server.
  ###
  submitTime: (config, success, error) ->
    @_timeEntryData.time_entry.issue_id    = config.issueId
    @_timeEntryData.time_entry.hours       = config.hours
    @_timeEntryData.time_entry.comments    = config.comment
    @_timeEntryData.time_entry.activity_id = config.activityId
    config =
      method: "POST"
      url: @auth.url + "/issues/#{@_timeEntryData.time_entry.issue_id}/time_entries.json"
      data: Redmine.JSONtoXML @_timeEntryData
    config = @setBasicConfig config, @auth
    config.headers = "Content-Type": "application/xml"
    @$http(config)
      .success(success or Redmine.NULLFUNC)
      .error((data, status, headers, config) ->
        console.debug data
        Analytics.sendException("Error: submitTime")
        error(data, status))


  ###
   Load projects on url
  ###
  loadProjects: (success, error, params) ->
    params = params or {}
    params.limit = params.limit or 50
    config =
      method: "GET"
      url: @auth.url + "/projects.json"
      params: params
    config = @setBasicConfig config, @auth
    @$http(config)
      .success( (data, status, headers, config) =>
        data.url = @auth.url
        if data?.projects?
          data.projects = for prj in data.projects
            newPrj =
              url: @auth.url,
              urlIndex: prj.urlIndex,  # undefined
              id: prj.id,
              text: prj.name,
              show: Redmine.SHOW.NOT
            @Project.add(newPrj)
            @Project.new(newPrj)
        success?(data, status, headers, config))
      .error(error or Redmine.NULLFUNC)


  ###
   Load user on url associated to auth.
  ###
  _getUser: (success, error) ->
    error = error or Redmine.NULLFUNC
    config =
      method: "GET"
      url: @auth.url + "/users/current.json?include=memberships"
    config = @setBasicConfig config, @auth
    @$http(config)
      .success( (data, status, headers, config) =>
        if not data.user or not data.user.id
          error(data, status, headers, config)
          return
        @auth.userId = data.user.id
        success(data, status, headers, config))
      .error(error)


  ###
   find user recursive.
  ###
  _findUser: (success, error) ->
    @auth.url = @auth.url.substring(0, @auth.url.lastIndexOf('/'))
    if not @auth.url.match(/^https?:\/\/.+/) then error(); return
    @_getUser(success, () => @_findUser(success, error))


  ###
   find user from url.
  ###
  findUser: (success, error) ->
    @auth.url = @auth.url + '/'
    @_findUser((data) =>
        data.account = @auth
        success(data)
      , error or Redmine.NULLFUNC)


  ###
   Load time entry activities.
  ###
  getActivities: (success, error) ->
    config =
      method: "GET"
      url: @auth.url + "/enumerations/time_entry_activities.json"
    config = @setBasicConfig config, @auth
    @$http(config)
      .success( (data, status, headers, config) =>
        data.url = @auth.url
        success?(data, status, headers, config))
      .error(error or Redmine.NULLFUNC)

