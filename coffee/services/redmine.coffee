timeTracker.factory "Redmine", ($http, $rootScope, $q, Base64, Ticket, Project, Analytics, Log) ->

  _redmines = {}

  return {

    ###*
     get redmine instance.
     @method get
     @param auth {Object} Authentication infomation for Redmine.
     @param auth.url {String} Redmine server's url.
     @param auth.id {String} ID for redmine account.
     @param auth.pass {String} Password for redmine account.
     @param auth.apiKey {String} API Key for redmine account (optional).
     @param auth.userId {Number} account UserID.
    ###
    get: (auth) ->
      if not _redmines[auth.url]
        _redmines[auth.url] = new Redmine(auth, $http, $q, $rootScope, Ticket, Project, Base64, Analytics, Log)
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
  @UNAUTHORIZED = 401
  @CONTENT_TYPE: "application/json"
  @AJAX_TIME_OUT: 30 * 1000
  @LIMIT_MAX: 100
  @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }
  @NULLFUNC: () ->

  constructor: (@auth, @$http, @$q, @observer, @Ticket, @Project, @Base64, @Analytics, @Log) ->
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

  @extends: (p) ->
    p.success = (fn) -> p.then(fn); return p
    p.error = (fn) -> p.then(null, fn); return p
    return p


  ###
   bind log.
  ###
  _bindDefer: (success, error, mothodName) ->
    deferred = @$q.defer()
    onSuccess = (args...) =>
      @Analytics.sendEvent 'internal', mothodName, 'total_count', args[0].total_count
      deferred.resolve(args...)
      success?(args...)

    onError = (args...) =>
      @Analytics.sendException("Error: " + mothodName)
      deferred.reject(args...)
      error?(args...)

    return success: onSuccess, error: onError, promise: deferred.promise


  ###
   set basic configs for $http.
  ###
  _setBasicConfig: (config, auth) ->
    config.headers = "Content-Type": Redmine.CONTENT_TYPE
    config.timeout = config.timeout or Redmine.AJAX_TIME_OUT
    if auth.apiKey? and auth.apiKey.length > 0
      config.headers["X-Redmine-API-Key"] = auth.apiKey
    else
      @$http.defaults.headers.common['Authorization'] = 'Basic ' + @Base64.encode(auth.id + ':' + auth.pass)
    return config


  ###
   load issues.
  ###
  _getIssues: (params, success, error) ->
    params.limit = params.limit or Redmine.LIMIT_MAX
    deferred = @$q.defer()
    config =
      method: "GET"
      url: @auth.url + "/issues.json"
      params: params
      timeout: deferred.promise
    config = @_setBasicConfig config, @auth
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
        deferred.resolve(data)
        success?(data))
      .error((args...) =>
        deferred.reject(args...)
        error?(args...))
    return deferred


  ###
   load issues.
  ###
  getIssues: (success, error, params) ->
    o = @_bindDefer(success, error, "getIssues")
    @_getIssues(params, o.success, o.error).promise


  ###
   load All issues.
  ###
  getIssuesRange: (params, start, end, success, error) ->
    params = params or {}
    params.limit = Redmine.LIMIT_MAX
    pages = Math.ceil((end - start) / Redmine.LIMIT_MAX)
    promises = [1..pages].map (n) =>
      params = Object.clone(params)
      params.offset = start + (n - 1) * Redmine.LIMIT_MAX
      if params.offset + Redmine.LIMIT_MAX > end
        params.limit = end - params.offset + 1
      @_getIssues(params).promise

    r = @_bindDefer(success, error, "getIssuesRange")
    @$q.all(promises).then(
      (dataAry) ->
        data = dataAry.reduce((a, b) -> a.issues.add(b.issues);a)
        r.success(data)
    , (data) -> r.error(data))

    return r.promise


  ###
   Load tickets associated to user ID.
  ###
  getIssuesOnUser: (success, error) ->
    params =
      assigned_to_id: @auth.userId
    o = @_bindDefer(success, error, "getIssuesOnUser")
    @_getIssues(params, o.success, o.error).promise


  ###
   Load tickets on project.
  ###
  getIssuesOnProject: (projectId, params, success, error) ->
    params.project_id = projectId
    if @getIssuesCanceler
      @getIssuesCanceler.resolve()
      @getIssuesCanceler = null
    o = @_bindDefer(success, error, "getIssuesOnUser")
    @getIssuesCanceler = @_getIssues(params, o.success, o.error)
    @getIssuesCanceler.promise


  ###
   get any ticket using id.
  ###
  getIssuesById: (issueId, success, error) ->
    config =
      method: "GET"
      url: @auth.url + "/issues/#{issueId}.json"
    config = @_setBasicConfig config, @auth
    @$http(config)
      .success((data, status, headers, config) =>
        if data?.issue?
          data.issue.show = Redmine.SHOW.DEFAULT
          data.issue.url = @auth.url
        success?(data.issue, status, headers, config))
      .error((data, status, headers, config) =>
        if status is Redmine.NOT_FOUND or status is Redmine.UNAUTHORIZED
          data = issue:
            url: @auth.url
            id:  issueId
        else
          @Log.debug data
          @Analytics.sendException("Error: getIssuesById")
        error(data.issue, status))


  ###
   submit time entry to redmine server.
  ###
  submitTime: (config, success, error) ->
    success = success or Redmine.NULLFUNC
    error = error or Redmine.NULLFUNC
    @_timeEntryData.time_entry.issue_id    = config.issueId
    @_timeEntryData.time_entry.hours       = config.hours
    @_timeEntryData.time_entry.comments    = config.comment
    @_timeEntryData.time_entry.activity_id = config.activityId
    config =
      method: "POST"
      url: @auth.url + "/issues/#{@_timeEntryData.time_entry.issue_id}/time_entries.json"
      data: Redmine.JSONtoXML @_timeEntryData
    config = @_setBasicConfig config, @auth
    config.headers = "Content-Type": "application/xml"
    @$http(config)
      .success((data) =>
        @Analytics.sendEvent 'internal', 'submitTime', 'success', @_timeEntryData.time_entry.hours
        success(data))
      .error((data) =>
        @Log.debug data
        @Analytics.sendException("Error: submitTime")
        error(data))


  ###
   laod time entry. uses promise.
  ###
  loadTimeEntries: (params) ->
    deferred = @$q.defer()

    params = params or {}
    params.limit = params.limit or Redmine.LIMIT_MAX
    config =
      method: "GET"
      url: @auth.url + "/time_entries.json"
      params: params
    config = @_setBasicConfig config, @auth
    @$http(config)
      .success((args...) =>
        args[0].url = @auth.url
        deferred.resolve(args[0]))
      .error((args...) -> deferred.reject(args[0]))

    return Redmine.extends(deferred.promise)



  ###
   Load projects on url
  ###
  loadProjects: (params) =>
    @Log.debug "loadProjects start"
    deferred = @$q.defer()

    params = params or {}
    params.limit = params.limit or Redmine.LIMIT_MAX
    config =
      method: "GET"
      url: @auth.url + "/projects.json"
      params: params
    config = @_setBasicConfig config, @auth
    @$http(config)
      .success( (data, status, headers, config) =>
        data.url = @auth.url
        if data?.projects?
          data.projects = for prj in data.projects
            newPrj =
              url: @auth.url,
              id: prj.id,
              text: prj.name,
              show: Redmine.SHOW.DEFAULT
            @Project.new(newPrj)
          @Log.groupCollapsed "redmine.loadProjects()"
          @Log.table data.projects
          @Log.groupEnd "redmine.loadProjects()"
        deferred.resolve(data, status))
      .error((args...) -> deferred.reject(args[0], args[1]))

    return deferred.promise


  ###
   Load user on url associated to auth.
  ###
  _getUser: (success, error) ->
    error = error or Redmine.NULLFUNC
    config =
      method: "GET"
      url: @auth.url + "/users/current.json?include=memberships"
    config = @_setBasicConfig config, @auth
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
  loadActivities: (success, error) ->
    config =
      method: "GET"
      url: @auth.url + "/enumerations/time_entry_activities.json"
    config = @_setBasicConfig config, @auth
    @$http(config)
      .success( (data, status, headers, config) =>
        data.url = @auth.url
        success?(data, status, headers, config))
      .error(error or Redmine.NULLFUNC)


  ###
   laod queries. uses promise.
  ###
  loadQueries: (params) ->
    deferred = @$q.defer()

    params = params or {}
    params.limit = params.limit or Redmine.LIMIT_MAX
    config =
      method: "GET"
      url: @auth.url + "/queries.json"
      params: params
    config = @_setBasicConfig config, @auth
    @$http(config)
      .success((args...) =>
        args[0].url = @auth.url
        deferred.resolve(args[0]))
      .error((args...) -> deferred.reject(args[0]))

    return Redmine.extends(deferred.promise)
