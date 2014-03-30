timeTracker.controller 'AccountCtrl', ($scope, $modal, Redmine, Account, Project, Ticket, Message, State, Resource, Analytics) ->

  ID_PASS = 'id_pass'

  $scope.accounts = []
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = ID_PASS
  $scope.searchField = text: ''
  $scope.state = State
  $scope.R = Resource


  ###
   Initialize.
  ###
  init = ->
    Account.getAccounts (accounts) ->
      if not accounts? or not accounts[0]? then return
      for account in accounts
        loadProject account


  ###
   load project.
  ###
  loadProject = (account) ->
    Redmine.get(account).loadProjects loadProjectSuccess(account), loadProjectError


  ###
   show loaded project.
   if project is already loaded, overwrites by new project.
  ###
  loadProjectSuccess = (account) -> (msg) ->
    if msg.projects?
      for a, i in $scope.accounts when a.url is msg.url
        $scope.accounts.splice i, 1
        break
      account.projectCount = msg.projects.length
      $scope.accounts.push account
      Message.toast Resource.string("msgLoadProjectSuccess").format(account.url)
    else
      loadProjectError msg


  ###
   show fail message.
  ###
  loadProjectError = (msg) ->
    Message.toast Resource.string("msgLoadProjectFail")


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
        url:    $scope.option.url
        id:     $scope.option.id
        pass:   $scope.option.pass
    else
      option =
        url:    $scope.option.url
        apiKey: $scope.option.apiKey
    Redmine.get(option).findUser(addAccount, failAuthentication)


  ###
   add account.
  ###
  addAccount = (msg) ->
    if msg?.user?.id?
      $scope.option.url = msg.account.url
      Account.addAccount msg.account, (result) ->
        if result
          State.isSaving = State.isAdding = false
          Message.toast Resource.string("msgAuthSuccess"), 3000
          Analytics.sendEvent 'internal', 'auth', 'success'
          loadProject msg.account
        else
          failAuthentication null
    else
      failAuthentication msg


  ###
   fail to save
  ###
  failAuthentication = (msg) ->
    State.isSaving = false
    Message.toast Resource.string("msgAuthFail"), 3000
    Analytics.sendEvent 'internal', 'auth', 'fail'


  ###
   filter account.
  ###
  $scope.accountFilter = (account) ->
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
      Redmine.remove({url: url})
      for a, i in $scope.accounts when a.url is url
        $scope.accounts.splice i, 1
        break
      Project.removeUrl url
      Ticket.removeUrl url
      Message.toast Resource.string("msgAccountRemoved").format(url)


  ###
   Start Initialize.
  ###
  init()
