timeTracker.factory "Redmine", ($http, $q, Base64, Ticket, Project, Analytics, Log, State, Const) ->

  _redmines = {}

  ###*
   Service for communicate with Redmine.
   @class Redmine
  ###
  class Redmine

    @CONTENT_TYPE: "application/json"
    @AJAX_TIME_OUT: 30 * 1000
    @LIMIT_MAX: 100

    ###*
     @constructor
    ###
    constructor: (@auth, @$http, @$q, @Ticket, @Project, @Base64, @Analytics, @Log, @State, @Const) ->
      @url = auth.url

    _timeEntryData:
      "time_entry":
        "issue_id": 0
        "hours": 0
        "activity_id": 8
        "comments": ""

    getIssuesCanceler: null


    ###*
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


    ###*
     bind log.
    ###
    _bindDefer: (success, error, mothodName) ->
      deferred = @$q.defer()
      onSuccess = (args...) =>
        args[0].account = @auth
        deferred.resolve(args...)
        success?(args...)

      onError = (args...) =>
        @Log.warn(mothodName + " failed:\taccount: " + @auth.name + "\tstatus: " + args[1])
        if not args[0] or args[0].isBlank?()
          args[0] = { error: true }
        args[0] = Object.merge(args[0], {account: @auth, status: args[1]})
        deferred.reject(args...)
        error?(args...)

      return success: onSuccess, error: onError, promise: deferred.promise


    ###*
     set basic configs for $http.
    ###
    _setBasicConfig: (config, auth) ->
      config.headers = "Content-Type": Redmine.CONTENT_TYPE
      config.timeout = config.timeout or Redmine.AJAX_TIME_OUT
      if auth.apiKey? and auth.apiKey.length > 0
        @$http.defaults.headers.common["X-Redmine-API-Key"] = auth.apiKey
      else
        delete @$http.defaults.headers.common["X-Redmine-API-Key"]
        @$http.defaults.headers.common['Authorization'] = 'Basic ' + @Base64.encode(auth.id + ':' + auth.pass)
      return config


    ###*
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
      @State.isLoadingIssue = true
      @$http(config)
        .success((data, status, headers, config) =>
          data.params = params
          data.url    = @auth.url
          data.issues = data.issues or []
          data.issues = for issue in data.issues
            issue.text    = issue.subject
            issue.show    = @Const.SHOW.DEFAULT
            issue.url     = @auth.url
            issue.total   = issue.spent_hours or 0
            @Ticket.create(issue)
          deferred.resolve(data)
          success?(data))
        .error((args...) =>
          deferred.reject(args...)
          error?(args...))
        .finally(() =>
          return if @getIssuesCanceler isnt deferred
          @State.isLoadingIssue = false)
      return deferred


    ###*
     load issues.
    ###
    getIssues: (params, success, error) ->
      if @getIssuesCanceler
        @getIssuesCanceler.resolve()
        @getIssuesCanceler = null
      o = @_bindDefer(success, error, "getIssues")
      @getIssuesCanceler = @_getIssues(params, o.success, o.error)
      @getIssuesCanceler.promise


    ###*
     load issues pararell.
    ###
    getIssuesPararell: (params, success, error) ->
      o = @_bindDefer(success, error, "getIssuesPararell")
      @_getIssues(params, o.success, o.error).promise


    ###*
     load issues from `start` to `end`.
    ###
    getIssuesRange: (params, start, end, success, error) ->
      params = params or {}
      params.limit = Redmine.LIMIT_MAX
      pages = Math.ceil((end - start) / Redmine.LIMIT_MAX)
      promises = [1..pages].map (n) =>
        params = Object.clone(params)
        params.offset = start + (n - 1) * Redmine.LIMIT_MAX
        if params.offset + Redmine.LIMIT_MAX > end
          params.limit = end - params.offset
        @_getIssues(params).promise

      r = @_bindDefer(success, error, "getIssuesRange")
      @$q.all(promises)
        .then((dataAry) ->
          data = dataAry.reduce((a, b) -> a.issues.add(b.issues);a)
          r.success(data)
        , (data) -> r.error(data))
        .finally(() => @State.isLoadingIssue = false)

      return r.promise


    ###*
     Load tickets associated to user ID.
    ###
    getIssuesOnUser: (success, error) ->
      params =
        assigned_to_id: @auth.userId
      o = @_bindDefer(success, error, "getIssuesOnUser")
      @_getIssues(params, o.success, o.error).promise


    ###*
     get any ticket using id.
    ###
    getIssuesById: (issueId, success, error) ->
      config =
        method: "GET"
        url: @auth.url + "/issues/#{issueId}.json"
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success((data, status, headers, config) =>
          @Log.debug("getIssuesById: success")
          @Log.debug data
          if data?.issue?
            data.issue.text  = data.issue.subject
            data.issue.total = data.issue.spent_hours or 0
            data.issue.show  = @Const.SHOW.DEFAULT
            data.issue.url   = @auth.url
            data.issue       = @Ticket.create(data.issue)
          success?(data.issue, status, headers, config))
        .error((data, status, headers, config) =>
          @Log.debug("getIssuesById: error on #{issueId}")
          @Log.debug data
          issue = @Ticket.create(url: @auth.url, id:  issueId)
          if status isnt @Const.NOT_FOUND or status isnt @Const.UNAUTHORIZED
            @Analytics.sendException("Error: getIssuesById")
          error?(issue, status))


    ###*
     submit time entry to redmine server.
    ###
    submitTime: (config, success, error) ->
      success = success or @Const.NULLFUNC
      error = error or @Const.NULLFUNC
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
        .success((args...) =>
          @Log.info("Time Entry Posted.\t account:#{@auth.name}\tid:#{@_timeEntryData.time_entry.issue_id}\thours:#{@_timeEntryData.time_entry.hours}")
          @Analytics.sendEvent 'timeEntry', 'post', 'success', 1
          success(args...))
        .error((args...) =>
          @Log.info("Time Entry Post Failed.\t account:#{@auth.name}\tid:#{@_timeEntryData.time_entry.issue_id}\thours:#{@_timeEntryData.time_entry.hours}")
          @Log.debug args
          @Analytics.sendEvent 'timeEntry', 'post', 'failed', 1
          @Analytics.sendException("Error: submitTime\tstatus: " + args[1])
          error(args...))


    ###*
     Load time entry. uses promise.
    ###
    loadTimeEntries: (params) ->
      r = @_bindDefer(null, null, "loadTimeEntries")
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
          r.success(args[0]))
        .error(r.error)
      return r.promise


    ###*
     Load projects on url
    ###
    loadProjects: (params) =>
      @Log.debug "loadProjects start"
      r = @_bindDefer(null, null, "loadProjects")

      params = params or {}
      params.limit = params.limit or Redmine.LIMIT_MAX
      config =
        method: "GET"
        url: @auth.url + "/projects.json"
        params: params
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success((data, status, headers, config) =>
          if data?.projects?
            data.projects = for prj in data.projects
              newPrj =
                url: @auth.url,
                id: prj.id,
                text: prj.name,
                show: @Const.SHOW.DEFAULT
              @Project.create(newPrj)
            @Log.groupCollapsed "redmine.loadProjects()"
            @Log.table data.projects
            @Log.groupEnd "redmine.loadProjects()"
          r.success(data, status))
        .error(r.error)

      return r.promise


    ###*
     load projects from `start` to `end`.
    ###
    loadProjectsRange: (params, start, end) =>
      params = params or {}
      end = end or Redmine.LIMIT_MAX
      params.limit = Redmine.LIMIT_MAX
      pages = Math.ceil((end - start) / Redmine.LIMIT_MAX)
      promises = [1..pages].map (n) =>
        params = Object.clone(params)
        params.offset = start + (n - 1) * Redmine.LIMIT_MAX
        if params.offset + Redmine.LIMIT_MAX > end
          params.limit = end - params.offset
        return @loadProjects(params)

      @$q.all(promises)
        .then((d) ->
          return d.reduce((a, b) -> a.projects.add(b.projects); a)
        , (d) -> return d)


    ###*
     load projects using id.
    ###
    loadProjectById: (id) ->
      @Log.debug "loadProjectById start"
      r = @_bindDefer(null, null, "loadProjectById")
      config =
        method: "GET"
        url: @auth.url + "/projects/#{id}.json"
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success((data, status, headers, config) =>
          if data?.project?
            newPrj =
              url:  @auth.url,
              id:   data.project.id,
              text: data.project.name,
              show: @Const.SHOW.DEFAULT
            data.project = @Project.create(newPrj)
            @Log.groupCollapsed "redmine.loadProjectById()"
            @Log.table data.project
            @Log.groupEnd "redmine.loadProjectById()"
          r.success(data, status))
        .error((data, status, headers, config) =>
          data = targetId: id if data.isBlank()
          r.error(data, status))
      return r.promise


    ###*
     Load user on url associated to auth.
    ###
    _getUser: (success, error) ->
      error = error or @Const.NULLFUNC
      config =
        method: "GET"
        url: @auth.url + "/users/current.json?include=memberships"
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success((data, status, headers, config) =>
          if not data.user or not data.user.id
            error(data, status, headers, config)
            return
          @auth.userId = data.user.id
          success(data, status, headers, config))
        .error(error)


    ###*
     find user recursive.
    ###
    _findUser: (success, error, args...) ->
      @auth.url = @auth.url.substring(0, @auth.url.lastIndexOf('/'))
      if not @auth.url.match(/^https?:\/\/.+/)
        error(args...)
        return
      @_getUser(success, (msg...) => @_findUser(success, error, msg...))


    ###*
     find user from url.
    ###
    findUser: (success, error) ->
      @auth.url = @auth.url + '/'
      if not @auth.url.isUrl()
        error(null, @Const.URL_FORMAT_ERROR)
        return
      @_findUser((data) =>
          data.account = @auth
          success(data)
        , error or @Const.NULLFUNC)


    ###*
     Load time entry activities.
    ###
    loadActivities: (success, error) ->
      r = @_bindDefer(success, error, "loadActivities")
      config =
        method: "GET"
        url: @auth.url + "/enumerations/time_entry_activities.json"
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success(r.success)
        .error(r.error)
      return r.promise


    ###*
     Load queries. uses promise.
    ###
    loadQueries: (params) ->
      r = @_bindDefer(null, null, "loadQueries")
      params = params or {}
      params.limit = params.limit or Redmine.LIMIT_MAX
      config =
        method: "GET"
        url: @auth.url + "/queries.json"
        params: params
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success(r.success)
        .error(r.error)
      return r.promise

    ###*
     load status. uses promise.
    ###
    loadStatuses: () ->
      r = @_bindDefer(null, null, "loadStatuses")
      config =
        method: "GET"
        url: @auth.url + "/issue_statuses.json"
      config = @_setBasicConfig config, @auth
      @$http(config)
        .success(r.success)
        .error(r.error)
      return r.promise


  return {

    ###*
     Get redmine instance.
     @method get
     @param {Object} auth - Authentication information for Redmine.
     @param {String} auth.url - Redmine server's url.
     @param {String} auth.id - ID for redmine account.
     @param {String} auth.pass - Password for redmine account.
     @param {String} auth.apiKey - API Key for redmine account (optional).
     @param {Number} auth.userId - account UserID.
    ###
    get: (auth) ->
      if not _redmines[auth.url]
        _redmines[auth.url] = new Redmine(auth, $http, $q, Ticket, Project, Base64, Analytics, Log, State, Const)
      return _redmines[auth.url]

    ###*
     remove redmine instance.
    ###
    remove: (auth) ->
      if _redmines[auth.url]?
        delete _redmines[auth.url]

  }
