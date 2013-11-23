timeTracker = angular.module('timeTracker', ['ui.bootstrap', 'timer'])

timeTracker.factory "$message", ($rootScope, $timeout) ->

  MESSAGE_DURATION = 1500
  ANIMATION_DURATION = 1000
  W_PADDING = 40
  H_PADDING = 8
  STYLE_HIDDEN = 'height': 0, opacity: 0

  _strScale = (str) ->
    e = $("#ruler")
    width = e.text(str).get(0).offsetWidth
    height = e.text(str).get(0).offsetHeight
    e.empty()
    return w: width, h: height

  return {

    ###
     show message page bottom.
    ###
    toast: (text, duration) ->
      duration = duration or MESSAGE_DURATION
      msg = {
        text: text
        style: STYLE_HIDDEN
      }

      $rootScope.messages.push msg

      scale = _strScale(text)
      rows = Math.ceil(( scale.w + W_PADDING ) / $(window).width())
      $timeout ->
        msg.style = 'height': H_PADDING + rows * scale.h, opacity: 1
      , 10
      $timeout ->
        msg.style = STYLE_HIDDEN
      , duration
      $timeout ->
        $rootScope.messages.shift()
      , duration + ANIMATION_DURATION

  }

timeTracker.controller 'MainCtrl', ($rootScope, $scope, $ticket, $redmine, $account) ->

  TICKET_SYNC = "TICKET_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5

  _redmine = {}

  $rootScope.messages = []


  $ticket.load (tickets) ->
    if not tickets? or tickets.length is 0
      return
    $ticket.set tickets
    $scope.$broadcast 'ticketLoaded'
    _removeClosedIssues()


  _removeClosedIssues = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      _redmine = $redmine(accounts[0])
      for t in $ticket.get()
        _redmine.issues.getById t.id, (data, status, headers, config) ->
          if data.issue?.status.id is TICKET_CLOSED
            $ticket.remove {id: data.issue.id, url: data.issue.url}


  $scope.$on 'notifyAccountChanged', () ->
    $scope.$broadcast 'accountChanged'


  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5

  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      $ticket.sync()

