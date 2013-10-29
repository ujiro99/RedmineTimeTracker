@timeTracker = angular.module('timeTracker', ['ngResource'])

timeTracker.factory("$message", ['$rootScope', ($rootScope) ->

  MESSAGE_DURATION = 2000

  return {

    ###
     show message page bottom.
    ###
    toast: (msg, duration) ->
      duration = duration or MESSAGE_DURATION
      $rootScope.message = msg
      if not $rootScope.$$phase then $rootScope.$apply()
      setTimeout ->
        $rootScope.message = ""
        if not $rootScope.$$phase then $rootScope.$apply()
      , duration
  }
])

timeTracker.controller('MainCtrl', ['$rootScope', '$ticket', ($rootScope, $ticket) ->

  TICKET_SYNC = "TICKET_SYNC"
  MINUTE_5 = 5

  $rootScope.message = ""

  $ticket.load (tickets) ->
    $ticket.tickets = tickets

  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5
  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      $ticket.sync()

])
