@timeTracker = angular.module('timeTracker', ['ui.bootstrap', 'timer'])

timeTracker.factory("$message", ['$rootScope', '$timeout', ($rootScope, $timeout) ->

  MESSAGE_HEIGHT = 24
  MESSAGE_DURATION = 1500
  ANIMATION_DURATION = 50

  return {

    ###
     show message page bottom.
    ###
    toast: (text, duration) ->
      duration = duration or MESSAGE_DURATION
      msg = {
        text: text
        style: 'height': 0
      }

      $rootScope.messages.push msg

      $timeout ->
        msg.style.height = MESSAGE_HEIGHT
      , 10
      $timeout ->
        msg.style.height = 0
      , duration
      $timeout ->
        $rootScope.messages.shift()
      , duration + ANIMATION_DURATION
  }
])

timeTracker.controller('MainCtrl', ['$rootScope', '$scope', '$ticket', '$redmine', '$account',  ($rootScope, $scope, $ticket, $redmine, $account) ->

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

])
