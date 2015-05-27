timeTracker.controller 'TimerCtrl', ($scope, $timeout, Account, Redmine, Ticket, DataAdapter, Message, State, Resource) ->

  ONE_MINUTE = 1
  COMMENT_MAX = 255
  SWITCHING_TIME = 300

  $scope.state = State
  $scope.data = DataAdapter
  $scope.projects = {}
  $scope.comment =
    text: ""
    MaxLength: COMMENT_MAX
    remain: COMMENT_MAX
  $scope.mode = "auto"
  $scope.time = { min: 0 }
  $scope.tickets = []

  trackedTime = {}

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0


  ###
   Initialize.
  ###
  init = () ->
    $scope.tickets = Ticket.getSelectable()
    DataAdapter.selectedTicket = Ticket.getSelected()
    initializeSearchform()


  ###
   change activity according to selected ticket
  ###
  $scope.$watch 'selectedTicket.url', (url) ->
    if not url then return
    $scope.activityData =
      displayKey: 'name'
      source: util.substringMatcher($scope.projects[url].activities, 'name')


  ###
   Initialize search form.
  ###
  initializeSearchform = () ->
    $scope.ticketData =
      displayKey: 'text'
      source: util.substringMatcher($scope.tickets, 'text')
    $scope.activityData =
      displayKey: 'name'
      source: util.substringMatcher([], 'name')


  ###
   change post mode.
   if tracking, restore tracked time.
  ###
  $scope.changeMode = () ->
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
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    if not DataAdapter.selectedTicket then return
    if State.isTracking
      if $scope.comment.remain < 0
        Message.toast Resource.string("msgCommentTooLong")
        return
      State.isTracking = false
      $scope.$broadcast 'timer-stop'
    else
      State.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on clicked manual post button, send time entry.
  ###
  $scope.clickManual = () ->
    if $scope.comment.remain < 0
      Message.toast Resource.string("msgCommentTooLong")
      return
    postEntry($scope.time.min)


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    trackedTime = time
    if not State.isTracking
      postEntry(time.days * 60 * 24 + time.hours * 60 + time.minutes)


  ###
   send time entry.
  ###
  postEntry = (minutes) ->
    if minutes >= ONE_MINUTE
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
      Redmine.get(DataAdapter.selectedAccount).submitTime(conf, submitSuccess, submitError)
      Message.toast Resource.string("msgSubmitTimeEntry").format(DataAdapter.selectedTicket.text, hours)
    else
      Message.toast Resource.string("msgShortTime")


  ###
   show success message.
  ###
  submitSuccess = (msg) ->
    if msg?.time_entry?.id?
      Message.toast Resource.string("msgSubmitTimeSuccess")
    else
      submitError msg


  ###
   show failed message.
  ###
  submitError = (msg) ->
    Message.toast Resource.string("msgSubmitTimeFail")


  ###
   Start Initialize.
  ###
  init()
