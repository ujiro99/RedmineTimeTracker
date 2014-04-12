angular.module('chrome', [])
  .factory 'Chrome', ['$log', ($log) ->
    if chrome?
      return chrome
    else
      $log.error "chrome api not exists."
      return null
  ]
