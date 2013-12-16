timeTracker.controller 'OptionCtrl', ($scope, $timeout, $message, option, analytics) ->

  $scope.options = { reportUsage: true }


  ###
   restore option, and start watching options.
  ###
  option.getOptions (options) ->
    $scope.options = options or {}
    analytics.setPermittion options.reportUsage

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
        for a in $scope.accounts
          $redmine(a, true) # delete
        $scope.accounts.clear()
        $message.toast "All data Cleared."
      else
        $message.toast "Clear Failed."


