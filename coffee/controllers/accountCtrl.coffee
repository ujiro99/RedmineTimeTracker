timeTracker.controller 'AccountCtrl', ($scope, $modal, Redmine, Account, Project, Ticket, DataAdapter, Message, State, Resource, Analytics, Const, Log) ->

  ID_PASS = 'id_pass'

  $scope.data = DataAdapter
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = ID_PASS
  $scope.searchField = text: ''
  $scope.state = State
  $scope.R = Resource
  $scope.isCollapse = false


  ###
   Load the user ID associated to Authentication info.
  ###
  $scope.findAccount = () ->
    State.isSaving = true
    if not $scope.option.url? or $scope.option.url.length is 0
      Message.toast Resource.string("msgRequestInputURL")
      State.isSaving = false
      return
    $scope.option.url = util.getUrl $scope.option.url
    Redmine.remove({url: $scope.option.url})
    if $scope.authWay is ID_PASS
      option =
        name:   $scope.option.name
        url:    $scope.option.url
        id:     $scope.option.id
        pass:   $scope.option.pass
        numProjects: $scope.option.numProjects
    else
      option =
        name:   $scope.option.name
        url:    $scope.option.url
        apiKey: $scope.option.apiKey
        numProjects: $scope.option.numProjects
    Redmine.get(option).findUser(addAccount, failAuthentication)


  ###
   add account.
  ###
  addAccount = (msg, status) ->
    if msg?.user?.id?
      $scope.option.url = msg.account.url
      Account.addAccount msg.account, (result, account) ->
        if result
          State.isSaving = State.isAdding = false
          DataAdapter.addAccounts([account])
          Message.toast Resource.string("msgAuthSuccess"), 3000
          Analytics.sendEvent 'internal', 'auth', 'success'
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
      DataAdapter.removeAccounts([{url:url}])
      Message.toast Resource.string("msgAccountRemoved").format(url)
