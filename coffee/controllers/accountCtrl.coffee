timeTracker.controller 'AccountCtrl', ($scope, Redmine, Account, Message) ->

  $scope.accounts = []
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = 'id_pass'
  $scope.searchText = ''
  $scope.isSaving = false
  $scope.isAdding = false


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
      Message.toast "Loaded : " + o.url
    else
      loadProjectError msg


  ###
   show fail message.
  ###
  loadProjectError = (msg) ->
    Message.toast "Load Project Failed."


  ###
   Load the user ID associated to Authentication info.
  ###
  $scope.addAccount = () ->
    $scope.isSaving = true
    if not $scope.option.url? or $scope.option.url.length is 0
      Message.toast "Please input Redmine Server URL."
      $scope.isSaving = false
      return
    $scope.option.url = util.getUrl $scope.option.url
    Redmine.remove({url: $scope.option.url})
    Redmine.get($scope.option).findUser(addAccount, failAuthentication)


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
      Account.addAccount account, (result) ->
        if result
          Message.toast "Succeed authentication!"
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
    Message.toast "Failed authentication."


  ###
   filter account and projects.
  ###
  $scope.accountFilter = (account) ->
    if $scope.searchText.isBlank() then return true
    return (account.url + "").contains($scope.searchText) or
           account.projects.some (prj) ->
             prj.name.toLowerCase().contains($scope.searchText.toLowerCase())


  ###
   remove account from chrome sync.
  ###
  $scope.removeAccount = (url) ->
    Account.removeAccount url, () ->
      Redmine.get({url: url}, true) # delete
      for a, i in $scope.accounts when a.url is url
        $scope.accounts.splice i, 1
        break
      Message.toast url + ' removed.'

