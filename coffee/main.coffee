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

timeTracker.controller('MainCtrl', ['$rootScope', '$scope', ($rootScope, $scope) ->
  $rootScope.message = ""
  $scope.tickets = {}
])
