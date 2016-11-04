timeTracker.controller 'OptionCtrl', ($scope, $timeout, Message, Ticket, Account, DataAdapter, Option, Analytics, State, Resource, Log, PluginManager) ->

  # delay time for syncOptions [ms]
  DELAY_TIME = 500

  # Global options.
  $scope.options = Option.getOptions()
  # Global states
  $scope.state = State
  # true if option modifying
  $scope.isSetting = false

  # promise object for cancel syncOptions
  timeoutPromise = null


  ###
   restore option, and start watching options.
  ###
  initialize = () ->
    Option.onChanged syncOptions
    loadSavedPlugins()


  ###
   if option was changed, save it.
  ###
  syncOptions = (propName) ->
    $timeout.cancel(timeoutPromise)
    timeoutPromise = $timeout ->
      Option.syncOptions(propName).then(sucessSyncOptions, failSyncOptions)
    , DELAY_TIME


  ###
   show saved message.
  ###
  sucessSyncOptions = (propName) ->
    if propName.startsWith("isCollapse") then return
    Message.toast Resource.string("msgOptionSaved")


  ###
   show save failed message.
  ###
  failSyncOptions = () ->
    Message.toast Resource.string("msgOptionSaveFailed")


  ###
   Load plugins from saved in the Option.
  ###
  loadSavedPlugins = () ->
    pluginUrls = $scope.options.plugins
    Log.debug("loadSavedPlugins")
    for url in pluginUrls
      Log.debug(url)
      PluginManager.loadPluginUrl(url)


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    Account.clearAccount (result) ->
      if result
        Message.toast Resource.string("msgClearDataSucess", 'all data')
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
          Message.toast Resource.string("msgClearDataSucess", 'ticket')
        else
          Message.toast Resource.string("msgClearDataFail")
      , 1000


  initialize()
