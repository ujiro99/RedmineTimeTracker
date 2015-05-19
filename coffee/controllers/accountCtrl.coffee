timeTracker.controller 'AccountCtrl', ($scope, $modal, Redmine, Account, Project, Ticket, DataAdapter, Message, State, Resource, Analytics) ->

  ID_PASS = 'id_pass'

  $scope.accounts = DataAdapter.accounts
  $scope.option = { apiKey:'', id:'', pass:'', url:'' }
  $scope.authWay = ID_PASS
  $scope.searchField = text: ''
  $scope.state = State
  $scope.R = Resource


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
          Redmine.get(msg.account).getIssuesOnUser(getIssuesSuccess)
          Message.toast Resource.string("msgAuthSuccess"), 3000
          Analytics.sendEvent 'internal', 'auth', 'success'
          loadProject msg.account
        else
          failAuthentication null
    else
      failAuthentication msg


  ###
   add assigned issues and projects.
  ###
  getIssuesSuccess = (data) ->
    if not data? then return
    # show assigned project.
    activeProject = {}
    for i in data.issues
      activeProject[i.url] = activeProject[i.url] or {}
      activeProject[i.url][i.project.id] = true
    for url, ids of activeProject
      for id in Object.keys(ids)
        Project.setParam url, id - 0, {show: Project.SHOW.SHOW}
    # show assigned ticket.
    Ticket.addArray data.issues
    Ticket.sync()


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
      # for a, i in $scope.accounts when a.url is url
      #   $scope.accounts.splice i, 1
      #   break
      Project.removeUrl url
      Ticket.removeUrl url
      Message.toast Resource.string("msgAccountRemoved").format(url)

