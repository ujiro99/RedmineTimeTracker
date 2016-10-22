timeTracker.controller 'AboutCtrl', ($scope, $http) ->

  $http.get('/manifest.json').success (data) ->
    $scope.version = data.version
