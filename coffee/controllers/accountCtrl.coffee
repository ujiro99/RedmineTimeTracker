timeTracker.controller 'AccountCtrl', ($scope, $timeout, $modal, Redmine, Account, Project, Ticket, DataAdapter, Message, State, Resource, Analytics, Option, Const, Log) ->

  ID_PASS = 'id_pass'
  API_KEY = 'api_key'
  DEFAULT_PARAM = { apiKey:'', id:'', pass:'', url:'', numProjects:50 }
  COLLAPSE_ANIMATION_DURATION = 100

  $scope.data = DataAdapter
  $scope.authParams = DEFAULT_PARAM
  $scope.options = Option.getOptions()
  $scope.authWay = ID_PASS
  $scope.searchField = text: ''
  $scope.state = State
  $scope.R = Resource


  ###
   Load the user ID associated to Authentication info.
  ###
  $scope.findAccount = () ->
    State.isSaving = true
    if not $scope.authParams.url? or $scope.authParams.url.length is 0
      Message.toast Resource.string("msgRequestInputURL")
      State.isSaving = false
      return
    $scope.authParams.url = util.getUrl $scope.authParams.url
    Redmine.remove({url: $scope.authParams.url})
    if $scope.authWay is ID_PASS
      authParams =
        url:    $scope.authParams.url
        id:     $scope.authParams.id
        pass:   $scope.authParams.pass
        name:   $scope.authParams.name
    else
      authParams =
        url:    $scope.authParams.url
        apiKey: $scope.authParams.apiKey
        name:   $scope.authParams.name
    Redmine.get(authParams).findUser(saveAccount, failAuthentication)


  ###
   add account.
  ###
  saveAccount = (msg, status) ->
    if msg?.user?.id?
      $scope.authParams.url = msg.account.url
      params = $scope.authParams
      if msg.account.apiKey
        delete params.id
        delete params.pass
      Account.addAccount params, (result, account) ->
        if result
          State.isSaving = false
          if DataAdapter.isAccountExists(account)
            DataAdapter.updateAccounts(account)
            Message.toast Resource.string("msgUpdateSuccess"), 3000
            Analytics.sendEvent 'internal', 'authUpdate', 'success'
          else
            State.isAdding = false
            State.isCollapseSetting = true
            DataAdapter.addAccounts(account)
            Message.toast Resource.string("msgAuthSuccess"), 3000
            Analytics.sendEvent 'internal', 'authAdd', 'success'
        else
          failAuthentication(null, status)
    else
      failAuthentication(msg, status)


  ###
   fail to save
  ###
  failAuthentication = (msg, status) ->
    State.isSaving = false
    if status is Const.URL_FORMAT_ERROR
      message = Resource.string("msgUrlFormatError")
    else if status is Const.ACCESS_ERROR
      message = Resource.string("msgAccessError") + Resource.string("status").format(status)
    else if status is Const.NOT_FOUND
      message = Resource.string("msgNotFoundError") + Resource.string("status").format(status)
    else
      message = Resource.string("msgAuthFail") + Resource.string("status").format(status)
    Message.toast message, 3000
    Analytics.sendEvent 'internal', 'authFail', status


  ###
   filter account.
  ###
  $scope.accountFilter = (account) ->
    if account.url is Const.STARRED then return false
    if $scope.searchField.text.isBlank() then return true
    return (account.url + "").contains($scope.searchField.text)


  ###
   open Account Setting area for modify setting.
  ###
  $scope.openAccountSetting = (url) ->
    # not change state if now saving.
    return if State.isSaving

    State.isSetting = true
    State.isAdding = false
    State.isCollapseSetting = false

    # use copy data to avoid changing original one.
    $scope.authParams = angular.copy(DataAdapter.getAccount(url))
    if $scope.authParams.apiKey
      $scope.authWay = API_KEY
    else
      $scope.authWay = ID_PASS


  ###
   toggle Account Setting area.
  ###
  $scope.toggleAccountSetting = () ->
    # not change state if now saving.
    return if State.isSaving

    if State.isCollapseSetting # to be open
      $scope.authParams = DEFAULT_PARAM
      State.isAdding = true
      $scope.state.isSetting = false
    else # to be close
      $timeout () ->
        $scope.authParams = DEFAULT_PARAM
        State.isAdding = false
        State.isSetting = false
      , COLLAPSE_ANIMATION_DURATION
    State.isCollapseSetting = !State.isCollapseSetting


  ###
   open dialog for remove account.
  ###
  $scope.openRemoveAccount = (url) ->
    modal = $modal.open
      templateUrl: '/views/removeAccount.html'
      controller: removeAccountCtrl
    modal.result.then () ->
      removeAccount(url)
    , () -> # canceled


  ###
   controller for remove account dialog.
  ###
  removeAccountCtrl = ($scope, $modalInstance, Resource) ->
    $scope.R = Resource
    $scope.ok = () ->
      $modalInstance.close true
    $scope.cancel = () ->
      $modalInstance.dismiss 'canceled.'
  removeAccountCtrl.$inject = ['$scope', '$modalInstance', 'Resource']


  ###
   remove account from chrome sync.
  ###
  removeAccount = (url) ->
    Account.removeAccount url, () ->
      Log.debug("account removed : " + url)
      Redmine.remove({url: url})
      DataAdapter.removeAccounts({url: url})
      Message.toast Resource.string("msgAccountRemoved").format(url)
