timeTracker.controller 'OptionCtrl', ($scope, $timeout, Message, Ticket, Account, DataAdapter, Option, Analytics, State, Resource) ->

  # delay time for syncOptions [ms]
  DELAY_TIME = 500

  $scope.options = {}
  $scope.state = State
  $scope.isSetting = false

  # promise object for cancel syncOptions
  timeoutPromise = null


  ###
   restore option, and start watching options.
  ###
  initialize = () ->
    $scope.options = Option.getOptions()
    Option.onChanged syncOptions


  ###
   if option was changed, save it.
  ###
  syncOptions = () ->
    $timeout.cancel(timeoutPromise)
    timeoutPromise = $timeout ->
      Option.syncOptions().then(sucessSyncOptions, failSyncOptions)
    , DELAY_TIME


  ###
   show saved message.
  ###
  sucessSyncOptions = () ->
    Message.toast Resource.string("msgOptionSaved")


  ###
   show save failed message.
  ###
  failSyncOptions = () ->
    Message.toast Resource.string("msgOptionSaveFailed")


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
    DataAdapter.clearTicket()
    Ticket.clear (result) ->
      $timeout ->
        $scope.isSetting = false
        if result
          Message.toast Resource.string("msgClearDataSucess").format('ticket')
        else
          Message.toast Resource.string("msgClearDataFail")
      , 1000


  initialize()
