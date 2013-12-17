timeTracker.controller 'OptionCtrl', ($scope, $timeout, $message, $account, option, analytics, state) ->

  DEFAULT_OPTION = { reportUsage: true }
  $scope.options = {}
  $scope.state = state


  ###
   restore option, and start watching options.
  ###
  option.getOptions (options) ->
    $scope.options = options or DEFAULT_OPTION
    analytics.setPermittion $scope.options.reportUsage

    # start watch changing.
    $scope.$watch 'options.reportUsage', (newVal, oldVal) ->
      if newVal is oldVal then return
      analytics.setPermittion newVal
      $timeout ->
        option.setOptions $scope.options, (result) ->
          if result
            $message.toast 'Option saved.'
          else
            $message.toast 'Failed to save.'
      , 500


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    $account.clearAccount (result) ->
      if result
        $message.toast "All data Cleared."
      else
        $message.toast "Clear Failed."


