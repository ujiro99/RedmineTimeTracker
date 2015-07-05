timeTracker.controller 'OptionCtrl', ($scope, $timeout, Message, Ticket, Project, Account, DataAdapter, Option, Analytics, State, Resource) ->

  # delay time for setOptions [ms]
  DELAY_TIME = 500

  $scope.options = {}
  $scope.state = State
  $scope.isSetting = false

  # promise object for cancel setOptions
  timeoutPromise = null


  ###
   if option was changed, save it.
  ###
  watchOptions = (newVal, oldVal) ->
    if util.equals(newVal, oldVal) then return
    Analytics.setPermission newVal.reportUsage
    $timeout.cancel(timeoutPromise)
    timeoutPromise = $timeout ->
      Option.setOptions $scope.options, (result) ->
        if result
          Message.toast Resource.string("msgOptionSaved")
        else
          Message.toast Resource.string("msgOptionSaveFailed")
    , DELAY_TIME


  ###
   restore option, and start watching options.
  ###
  initialize = () ->
    $scope.options = Option.getOptions()
    Analytics.setPermission $scope.options.reportUsage
    # start watch changing.
    $scope.$watch 'options', watchOptions, true


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    Account.clearAccount (result) ->
      if result
        Message.toast Resource.string("msgClearDataSucess").format('all data')
      else
        Message.toast Resource.string("msgClearDataFail")


  ###
   clear ticket data.
  ###
  $scope.clearTickets = () ->
    $scope.isSetting = true
    DataAdapter.tickets = []
    Ticket.clear (result) ->
      $timeout ->
        if result
          Message.toast Resource.string("msgClearDataSucess").format('ticket')
        else
          Message.toast Resource.string("msgClearDataFail")
      , 1000


  initialize()
