timeTracker.controller 'TimerCtrl', ($scope, $timeout, Redmine, Project, Ticket, DataAdapter, Message, State, Resource, Option, Log) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255
  SWITCHING_TIME = 250
  CHECK = OK: 0, CANCEL: 1, NG: -1

  $scope.state = State
  $scope.data = DataAdapter
  $scope.comment =
    text: ""
    maxLength: COMMENT_MAX
    remain: COMMENT_MAX
  $scope.time = { min: 0 }
  $scope.countDownSec = Option.getOptions().pomodoroTime * 60 # sec

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0

  auto = pomodoro = manual = null

  ###
   Initialize.
  ###
  init = () ->
    initializeSearchform()
    auto = new Auto()
    pomodoro = new Pomodoro()
    manual = new Manual()
    $scope.mode = auto

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
        suggestion: (n) -> "<div class='list'><div class='list-item'>
                              <span class='list-item__name'>#{n.name}</span>
                              <span class='list-item__description list-item__id'>#{n.id}</span>
                            </div></div>"

  ###
   change post mode.
   if tracking, restore tracked time.
  ###
  $scope.changeMode = (direction) ->
    restoreSelected()
    $scope.mode.onNextMode(direction)
    $scope.mode.onChanged()

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
    $scope.mode.onSubmit()

  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    $scope.mode.onTimerStopped(time)

  ###
   on timer ticked, update title.
  ###
  $scope.$on 'timer-tick', (e, time) ->
    if (not State.isAutoTracking) and (not State.isPomodoring)
      return
    State.title = formatTime(time.millis)
    $scope.time.min = Math.floor(time.millis / (60000))

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
    hours = Math.floor(hours * 100) / 100 # 0.00
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
  preCheck = () ->
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
  checkEntry = (min) ->
    return if preCheck() isnt CHECK.OK
    if $scope.comment.remain < 0
      Message.toast Resource.string("msgCommentTooLong"), 2000
      return CHECK.NG
    if min < ONE_MINUTE
      Message.toast Resource.string("msgShortTime"), 2000
      return CHECK.CANCEL
    return CHECK.OK

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


  class Auto

    name: "auto"
    trackedTime: {}

    onChanged: () =>
      if State.isAutoTracking
        $timeout () => # wait for complete switching
          $scope.$broadcast 'timer-start', new Date() - @trackedTime.millis
        , SWITCHING_TIME

    onNextMode: (direction) =>
      if State.isAutoTracking
        $scope.$broadcast 'timer-stop'
      if direction > 0
        $scope.mode = manual
      else
        $scope.mode = pomodoro

    onSubmit: () =>
      return if preCheck() isnt CHECK.OK
      if State.isAutoTracking
        State.isAutoTracking = false
        State.title = Resource.string("extName")
        checkResult = checkEntry($scope.time.min)
        if checkResult is CHECK.CANCEL
          $scope.$broadcast 'timer-clear'
        else if checkResult is CHECK.OK
          $scope.$broadcast 'timer-stop'
      else
        State.isAutoTracking = true
        $scope.$broadcast 'timer-start'

    onTimerStopped: (time) =>
      if State.isAutoTracking # store temporary
        @trackedTime = time
      else
        postEntry(time.days * 60 * 24 + time.hours * 60 + time.minutes)


  class Pomodoro

    name: "pomodoro"
    trackedTime: {}

    onChanged: () =>
      if State.isPomodoring
        $timeout () => # wait for complete switching
          $scope.countDownSec = @trackedTime.millis / 1000
          $scope.$broadcast 'timer-start', $scope.countDownSec
        , SWITCHING_TIME

    onNextMode: (direction) =>
      if State.isPomodoring
        $scope.$broadcast 'timer-stop'
      if direction > 0
        $scope.mode = auto
      else
        $scope.mode = manual

    onSubmit: () =>
      return if preCheck() isnt CHECK.OK
      if State.isPomodoring
        State.isPomodoring = false
        State.title = Resource.string("extName")
        checkResult = checkEntry(($scope.countDownSec / 60) - ($scope.time.min + 1))
        if checkResult is CHECK.CANCEL
          $scope.$broadcast 'timer-clear'
        else if checkResult is CHECK.OK
          $scope.$broadcast 'timer-stop'
      else
        State.isPomodoring = true
        $scope.countDownSec = Option.getOptions().pomodoroTime * 60 # sec
        $scope.$broadcast 'timer-start', $scope.countDownSec

    onTimerStopped: (time) =>
      if State.isPomodoring # store temporary
        @trackedTime = time
      else
        postEntry(Math.round(($scope.countDownSec / 60) - Math.round(time.millis / 1000 / 60)))


  class Manual

    name: "manual"
    trackedTime: {}

    onChanged: () =>
      # nothing to do

    onNextMode: (direction) =>
      if direction > 0
        $scope.mode = pomodoro
      else
        $scope.mode = auto

    onSubmit: () =>
      checkResult = checkEntry($scope.time.min)
      return if checkResult isnt CHECK.OK
      postEntry($scope.time.min)

    onTimerStopped: (time) =>
      # nothing to do

  ###
   Start Initialize.
  ###
  init()

