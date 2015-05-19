timeTracker.controller 'headerCtrl', ($scope, Account, Redmine, Project, DataAdapter, Message, Resource, Analytics) ->

  # data
  $scope.data = DataAdapter
  # is header dropdown active?
  $scope.isActive = false
  # project filter string.
  $scope.projectSearchText = ""

  # http request canceled.
  STATUS_CANCEL = 0


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      DataAdapter.addAccounts(accounts)
      for account in accounts
        params =
          page: 1
          limit: 50
        Redmine.get(account).loadProjects _updateProject, _errorLoadProject, params


  ###
   update projects by redmine's data.
  ###
  _updateProject = (data) =>
    if data.projects?
      DataAdapter.addProjects(data.projects)
      Message.toast Resource.string("msgLoadProjectSuccess").format(data.projects[0].url)
    else
      _errorLoadProject data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadProjectFail")


  ###
   select project.
   @param {projectModel} project - clicked object.
  ###
  $scope.selectProject = (project) ->
    DataAdapter.selectedProject = project
    $scope.isActive = false


  ###
   Start Initialize.
  ###
  init()

