$ ->

  API_KEY = "ApiKey"
  HOST = "Host"
  USER_ID = "userId"
  ASSIGNED_ISSUES = "/issues.json?status_id=open&assigned_to_id="
  CONTENT_TYPE = "application/json"
  ONE_MINUTE = 1000 * 60
  CHARACTERS_MAX = 255
  MESSAGE_DURATION = 2000
  AJAX_TIME_OUT = 30 * 1000

  postData =
    "time_entry":
      "issue_id": 0
      "hours": 0
      "activity_id": 8
      "comments": ""
  hours = 0
  isTracking = false
  start = null
  $buttonTimer = $('#buttonTimer')
  $issueSelect = $('#issueSelect')
  $issueLoading = $('#issueLoading')


  ###
   On ready document, init.
  ###
  $(document).ready ->
    init()


  ###
   get data from localStorage, then init.
  ###
  init = ->
    host   = localStorage[HOST]
    apiKey = localStorage[API_KEY]
    userId = localStorage[USER_ID]

    if not apiKey? or not host? or not userId? then return

    loadOpenAssignedIssues(host, apiKey, userId)
    $("#submitButton").click -> onClickSubmit(host, apiKey, userId)
    $("#comment textarea").keyup onKeyDownComment
    $("#issueSearchButton").click -> onClickIssueSearch(host, apiKey)
    $("#issueAddButton").click onClickIssueAdd


  ###
   Load tickets associated to user ID.
  ###
  loadOpenAssignedIssues = (host, apiKey, userId) ->
    console.log "load open assigned issues for " + userId
    $.ajax
      type: "GET"
      url: host + ASSIGNED_ISSUES + userId
      contentType: CONTENT_TYPE
      headers:
        "X-Redmine-API-Key": apiKey
      success: setSelectOption


  ###
   Set options to the issue select form.
  ###
  setSelectOption = (res) ->
    arr = $.map res.issues, (issue) ->
      """<option value="#{issue.id}">##{issue.id} #{issue.subject}</option>"""
    $("#issueSelect").html(arr.join(""))


  ###
   Start or End Time tracking
  ###
  onClickSubmit = (host, apiKey, userId) ->
    if isTracking
      isTracking = false
      end = new Date()
      millisec = end.getTime() - start.getTime()
      if millisec > ONE_MINUTE
        hours = millisec / 1000 / 60 / 60
        submitTimeEntry(host, apiKey, userId, hours)
        $('#Log').append("""<p>start #{start.getHours()}:#{start.getMinutes()} end #{end.getHours()}:#{end.getMinutes()}: #{hours}</p>""")
      else
        console.log 'Too short time entry.'
      $buttonTimer.addClass('icon-play-sign')
      $buttonTimer.removeClass('icon-stop')
      $issueSelect.show()
      $issueLoading.hide()
    else
      isTracking = true
      start = new Date()
      $buttonTimer.removeClass('icon-play-sign')
      $buttonTimer.addClass('icon-stop')
      $issueSelect.hide()
      $issueLoading.show()


  ###
   submit to redmine server.
  ###
  submitTimeEntry = (host, apiKey, userId, hours) ->
    issueId = $('#issueSelect').val()
    comments = $('#comment').val()
    if comments.length > CHARACTERS_MAX
      comments = comments.substring(0, CHARACTERS_MAX - 1)
    postData.time_entry.issue_id = issueId
    postData.time_entry.hours = hours
    postData.time_entry.comments = comments

    $.ajax
      type: "POST"
      url: host + "/issues/#{issueId}/time_entries.json"
      contentType: CONTENT_TYPE
      headers:
        "X-Redmine-API-Key": apiKey
      data: JSON.stringify(postData)
      dataType: "json"
      timeout: AJAX_TIME_OUT
      success: (msg) ->
        userMessage = ""
        if msg?.time_entry?.id?
          userMessage = "Time Entry Saved."
        else
          userMessage = "Save Failed."
        $('#message').html(userMessage)
        setTimeout ->
          $('#message').html("")
        , MESSAGE_DURATION
      error: (msg) ->
        userMessage = "Save Failed."
        $('#message').html(userMessage)
        setTimeout ->
          return $('#message').html("")
        , MESSAGE_DURATION

  ###
   check comment length
  ###
  onKeyDownComment = ->
    thisValueLength = $(this).val().length
    $('#commentCount').html(thisValueLength)
    if thisValueLength > CHARACTERS_MAX
      $('#commentCount').addClass "label-danger"
      $('#commentCount').removeClass "label-info"
    else
      $('#commentCount').addClass "label-info"
      $('#commentCount').removeClass "label-danger"


  onClickIssueSearch = (host, apiKey) ->
    number = $("#inputIssueNumber").val()
    $("#issueSearchButton").button('loading')
    $.ajax
      type: "GET"
      url: host + "/issues/#{number}.json"
      contentType: CONTENT_TYPE
      headers:
        "X-Redmine-API-Key": apiKey
      success: issueSearchSuccess
      error: issueSearchError

  issueSearchSuccess = (res) ->
    $("#issueSearchButton").button('reset')
    $("#issueList").append("""<label><input type="checkbox" value="#{res.issue.id}"/>##{res.issue.id} #{res.issue.subject}</label>""")

  issueSearchError = (msg) ->
    $("#issueSearchButton").button('reset')

  onClickIssueAdd = ->
    arr = $.map $('#issueList input:checked'), (issue) ->
      issue = $(issue)
      """<option value="#{issue.val()}">#{issue.parent().get(0).innerText}</option>"""
    if arr?.length > 0
      $("#issueSelect").append(arr.join(""))


TimerCtrl = ($scope) ->
  $scope.tickets = [
    { id: 0, name: "test", project: "plugin" }
    { id: 1, name: "dev", project: "plugin" }
    { id: 2, name: "design", project: "web" }
  ]

