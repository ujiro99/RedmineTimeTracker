timeTracker = angular.module('timeTracker', ['ui.bootstrap', 'ngAnimate', 'timer'])

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

  $rootScope.messages = []


  $ticket.load (tickets) ->
    if not tickets?
      return
    $ticket.set tickets
    $scope.$broadcast 'ticketLoaded'
    _updateIssues()


  _updateIssues = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      for t in $ticket.get()
        for account in accounts when account.url is t.url
          $redmine(account).getIssuesById t.id, (data, status, headers, config) ->
            if data.issue?.status.id is TICKET_CLOSED
              $ticket.remove {url: data.issue.url, id: data.issue.id }
              return
            if data.issue.spent_hours?
              total = Math.floor(data.issue.spent_hours * 100) / 100
              $ticket.setParam  data.issue.url, data.issue.id, total: total


  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5


  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      $ticket.sync()

