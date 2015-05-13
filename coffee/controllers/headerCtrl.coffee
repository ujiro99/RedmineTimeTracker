timeTracker.controller 'headerCtrl', ($scope, Account, Redmine, Project, DataAdapter, Message, Resource, Analytics) ->

  $scope.data = DataAdapter

  # project filter string.
  $scope.projectSearchText = ""

  # http request canceled.
  STATUS_CANCEL = 0


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.data._accounts.set(accounts)
      $scope.data.accounts.set(accounts)
      for account in $scope.data.accounts
        account.projects = []
        params =
          page: 1
          limit: 50
        Redmine.get(account).loadProjects _updateProject, _errorLoadProject, params


  ###
   update projects by redmine's data.
  ###
  _updateProject = (data) =>
    if data.projects?
      for account in $scope.data.accounts when account.url is data.projects[0].url
        account.projects.set(data.projects)
    else
      _errorLoadProject data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadFail")


  ###
   select project.
   @param {projectModel} project - clicked object.
  ###
  $scope.selectProject = (project) ->
    $scope.data.selectedProject = project


  ###
   Start Initialize.
  ###
  init()
  
