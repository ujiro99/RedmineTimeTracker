@timeTracker = angular.module('timeTracker', ['ngResource', 'ui.bootstrap', 'timer'])

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

timeTracker.controller('MainCtrl', ['$rootScope', '$scope', '$ticket', ($rootScope, $scope, $ticket) ->

  TICKET_SYNC = "TICKET_SYNC"
  MINUTE_5 = 5

  $rootScope.messages = []

  $ticket.load (tickets) ->
    $ticket.set tickets

  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5

  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      $ticket.sync()

])
