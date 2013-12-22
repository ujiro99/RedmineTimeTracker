timeTracker.controller 'OptionCtrl', ($scope, $timeout, Message, Account, Option, Analytics, State) ->

  DEFAULT_OPTION = { reportUsage: true }
  $scope.options = {}
  $scope.state = State


  ###
   restore option, and start watching options.
  ###
  Option.getOptions (options) ->
    $scope.options = options or DEFAULT_OPTION
    Analytics.setPermittion $scope.options.reportUsage
    # start watch changing.
    $scope.$watch 'options', watchOptions, true


  ###
   if option was changed, save it.
  ###
  watchOptions = (newVal, oldVal) ->
    if util.equals(newVal, oldVal) then return
    Analytics.setPermittion newVal.reportUsage
    $timeout ->
      Option.setOptions $scope.options, (result) ->
        if result
          Message.toast 'Option saved.'
        else
          Message.toast 'Failed to save.'
    , 500


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    Account.clearAccount (result) ->
      if result
        Message.toast "All data Cleared."
      else
        Message.toast "Clear Failed."


