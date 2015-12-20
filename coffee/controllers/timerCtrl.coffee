timeTracker.controller 'TimerCtrl', ($scope, $timeout, Redmine, Project, Ticket, DataAdapter, Message, State, Resource, Log) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255
  SWITCHING_TIME = 300

  CHECK =
    OK: 0
    CANCEL: 1
    NG: -1

  $scope.state = State
  $scope.data = DataAdapter
  $scope.comment =
    text: ""
    MaxLength: COMMENT_MAX
    remain: COMMENT_MAX
  $scope.mode = "auto"
  $scope.time = { min: 0 }

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0

  trackedTime = {}


  ###
   Initialize.
  ###
  init = () ->
    initializeSearchform()

  ###*
   @param matches {Array}  Array of issues which matched.
  ###
  groupByProject = (matches) ->
    obj = {}
    for m in matches
      if not obj[m.url] then obj[m.url] = {}
      m.groupTop = not obj[m.url][m.project.id]
      obj[m.url][m.project.id] = true

  ###
   Initialize search form.
  ###
  initializeSearchform = () ->
    $scope.ticketData =
      displayKey: 'text'
      source: util.substringMatcher(DataAdapter.tickets, ['text', 'id', 'project.name'], groupByProject)
      templates:
        suggestion: (n) ->
          template = "<div class='numbered-label'>
                        <span class='numbered-label__number'>#{n.id}</span>
                        <span class='numbered-label__label'>#{n.text}</span>
                      </div>"
          if n.groupTop
            template = template.insert("<div><span class='select-issues__project'>#{n.project.name}</span></div>", 0)
          return template
    $scope.activityData =
      displayKey: 'name'
      source: util.substringMatcher(DataAdapter.activities, ['name', 'id'])
      templates:
        suggestion: (n) -> "<div class='list-item'><span class='list-item__name'>#{n.name}</span><span class='list-item__description list-item__id'>#{n.id}</span></div>"


  ###
   change post mode.
   if tracking, restore tracked time.
  ###
  $scope.changeMode = () ->
    restoreSelected()
    if $scope.mode is "auto"
      if State.isTracking
        $scope.$broadcast 'timer-stop'
      $scope.mode = "manual"
    else
      $scope.mode = "auto"
      if State.isTracking
        # wait for complete switching
        $timeout () ->
          $scope.$broadcast 'timer-start', new Date() - trackedTime.millis
        , SWITCHING_TIME


  ###
   Workaround for restore selected state on switching view.
  ###
  restoreSelected = () ->
    return if not DataAdapter.selectedTicket
    tmpTicket   = DataAdapter.selectedTicket
    tmpActivity = DataAdapter.selectedActivity
    $timeout () ->
      DataAdapter.selectedTicket   = tmpTicket
      DataAdapter.selectedActivity = tmpActivity
    , SWITCHING_TIME / 2


  ###
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    return if preCheck() isnt CHECK.OK
    if State.isTracking
      checkResult = checkEntry()
      if checkResult is CHECK.CANCEL
        cancelSubmit()
      else if checkResult is CHECK.OK
        State.isTracking = false
        $scope.$broadcast 'timer-stop'
      State.title = Resource.string("extName")
    else
      State.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on clicked manual post button, send time entry.
  ###
  $scope.clickManual = () ->
    checkResult = checkEntry()
    return if checkResult isnt CHECK.OK
    postEntry($scope.time.min)


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    trackedTime = time
    if not State.isTracking
      postEntry(time.days * 60 * 24 + time.hours * 60 + time.minutes)
    else
      Log.debug("timer-stopped: submit canceled.")


  ###
   on timer ticked, update title.
  ###
  $scope.$on 'timer-tick', (e, data) ->
    return if not State.isTracking
    State.title = formatTime(data.millis)
    $scope.time.min = Math.floor(((data.millis / (60000)) % 60))


  ###
   calculate and format time.
  ###
  formatTime = (millis) ->
    time = {}
    time.s = Math.floor((millis / 1000) % 60)
    time.m = Math.floor(((millis / (60000)) % 60))
    time.h = Math.floor(((millis / (3600000)) % 24))

    for key, num of time
      num = '' + parseInt(num, 10)
      num = '0' + num while num.length < 2
      time[key] = num

    return "#{time.h}:#{time.m}:#{time.s}"


  ###
   send time entry.
  ###
  postEntry = (minutes) ->
    hours = minutes / 60
    hours = Math.floor(hours * 100) / 100
    total = DataAdapter.selectedTicket.total + hours
    DataAdapter.selectedTicket.total = Math.floor(total * 100) / 100
    conf =
      issueId:    DataAdapter.selectedTicket.id
      hours:      hours
      comment:    $scope.comment.text
      activityId: DataAdapter.selectedActivity.id
    url = DataAdapter.selectedTicket.url
    account = DataAdapter.getAccount(url)
    Redmine.get(account).submitTime(conf, submitSuccess, submitError(conf))
    Message.toast Resource.string("msgSubmitTimeEntry").format(DataAdapter.selectedTicket.text, hours)


  ###
   check time entry before starting track.
  ###
  preCheck = (minute) ->
    if not DataAdapter.selectedTicket
      Message.toast Resource.string("msgSelectTicket"), 2000
      return CHECK.NG
    if not DataAdapter.selectedActivity
      Message.toast Resource.string("msgSelectActivity"), 2000
      return CHECK.NG
    return CHECK.OK


  ###
   check time entry.
  ###
  checkEntry = (minute) ->
    return if preCheck() isnt CHECK.OK
    if $scope.comment.remain < 0
      Message.toast Resource.string("msgCommentTooLong"), 2000
      return CHECK.NG
    if $scope.time.min < ONE_MINUTE
      Message.toast Resource.string("msgShortTime"), 2000
      return CHECK.CANCEL
    return CHECK.OK


  ###
   cancel submit time entry
  ###
  cancelSubmit = () ->
    $scope.$broadcast 'timer-stop'
    State.isTracking = false


  ###
   show success message.
  ###
  submitSuccess = (msg, status) ->
    if msg?.time_entry?.id?
      Message.toast Resource.string("msgSubmitTimeSuccess")
    else
      submitError(msg, status)


  ###
   show failed message.
  ###
  submitError = (conf) -> (msg, status) ->
    Message.toast(Resource.string("msgSubmitTimeFail") + Resource.string("status").format(status), 3000)
    Log.warn conf


  ###
   Start Initialize.
  ###
  init()
