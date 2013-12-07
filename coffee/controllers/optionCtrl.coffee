timeTracker.controller 'OptionCtrl', ($scope, $redmine, $account, $message, state) ->

  $scope.accounts = []
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = 'id_pass'
  $scope.searchText = ''
  $scope.isSaving = false
  $scope.isAdding = false
  $scope.state = state


  ###
   Initialize Option page.
  ###
  init = ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts[0]? then return
      for account in accounts
        loadProject account

  init()


  ###
   load project.
  ###
  loadProject = (account) ->
    $redmine(account).loadProjects loadProjectSuccess, loadProjectError


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
      $scope.accounts.push o
      $message.toast "Loaded : " + o.url
    else
      loadProjectError msg


  ###
   show fail message.
  ###
  loadProjectError = (msg) ->
    $message.toast "Load Project Failed."


  ###
   Load the user ID associated to Authentication info.
  ###
  $scope.addAccount = () ->
    $scope.isSaving = true
    if not $scope.option.url? or $scope.option.url.length is 0
      $message.toast "Please input Redmine Server URL."
      $scope.isSaving = false
      return
    $scope.option.url = util.getUrl $scope.option.url
    $redmine($scope.option).findUser(addAccount, failAuthentication)


  ###
   add account.
  ###
  addAccount = (msg) ->
    $scope.isSaving = $scope.isAdding = false
    if msg?.user?.id?
      account =
        url:    $scope.option.url
        apiKey: $scope.option.apiKey
        id:     $scope.option.id
        pass:   $scope.option.pass
        userId: msg.user.id
      $account.addAccount account, (result) ->
        if result
          $message.toast "Succeed authentication!"
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
    $message.toast "Failed authentication."


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    $account.clearAccount (result) ->
      if result
        $scope.accounts.clear()
        $message.toast "All data Cleared."
      else
        $message.toast "Clear Failed."


  ###
   filter account and projects.
  ###
  $scope.accountFilter = (account) ->
    if $scope.searchText.isBlank() then return true
    return (account.url + "").contains($scope.searchText) or
           account.projects.some (prj) ->
             prj.name.toLowerCase().contains($scope.searchText.toLowerCase())


  ###
   toggle account add form visible.
  ###
  $scope.toggleForm = () ->
    $scope.isAdding = !$scope.isAdding


  ###
   remove account from chrome sync.
  ###
  $scope.removeAccount = (url) ->
    $account.removeAccount url, () ->
      $redmine({url: url}, true) # delete
      for a, i in $scope.accounts when a.url is url
        $scope.accounts.splice i, 1
        break
      $message.toast url + ' removed.'

