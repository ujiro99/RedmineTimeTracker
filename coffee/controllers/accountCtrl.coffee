timeTracker.controller 'AccountCtrl', ($scope, $modal, Redmine, Account, Message, State, Resource) ->

  $scope.accounts = []
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = 'id_pass'
  $scope.searchText = ''
  $scope.state = State
  $scope.isSaving = false
  $scope.R = Resource


  ###
   Initialize Option page.
  ###
  init = ->
    Account.getAccounts (accounts) ->
      if not accounts? or not accounts[0]? then return
      for account in accounts
        loadProject account

  init()


  ###
   load project.
  ###
  loadProject = (account) ->
    Redmine.get(account).loadProjects loadProjectSuccess, loadProjectError


  ###
   show loaded project.
   if project is already loaded, overwrites by new project.
  ###
  loadProjectSuccess = (msg) ->
    if msg.projects?
      o =
        url: msg.projects[0].account.url
        projects: msg.projects
      for a, i in $scope.accounts when a.url is o.url
        $scope.accounts.splice i, 1
        break
      $scope.accounts.push o
      Message.toast Resource.string("msgLoadProjectSuccess").format(o.url)
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
  $scope.addAccount = () ->
    $scope.isSaving = true
    if not $scope.option.url? or $scope.option.url.length is 0
      Message.toast Resource.string("msgRequestInputURL")
      $scope.isSaving = false
      return
    $scope.option.url = util.getUrl $scope.option.url
    Redmine.remove({url: $scope.option.url})
    Redmine.get($scope.option).findUser(addAccount, failAuthentication)


  ###
   add account.
  ###
  addAccount = (msg) ->
    if msg?.user?.id?
      account =
        url:    $scope.option.url
        apiKey: $scope.option.apiKey
        id:     $scope.option.id
        pass:   $scope.option.pass
        userId: msg.user.id
      Account.addAccount account, (result) ->
        if result
          $scope.isSaving = $scope.state.isAdding = false
          Message.toast Resource.string("msgAuthSuccess"), 3000
          loadProject account
        else
          failAuthentication null
    else
      failAuthentication msg


  ###
   fail to save
  ###
  failAuthentication = (msg) ->
    $scope.isSaving = false
    Message.toast Resource.string("msgAuthFail"), 3000


  ###
   filter account and projects.
  ###
  $scope.accountFilter = (account) ->
    if $scope.searchText.isBlank() then return true
    return (account.url + "").contains($scope.searchText) or
           account.projects.some (prj) ->
             prj.name.toLowerCase().contains($scope.searchText.toLowerCase())


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
      Message.toast Resource.string("msgAccountRemoved").format(url)
