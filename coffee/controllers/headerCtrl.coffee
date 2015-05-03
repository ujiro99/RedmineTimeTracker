timeTracker.controller 'headerCtrl', ($scope, Account, Redmine, Project, Message, Resource, Analytics) ->

  # list data
  $scope.accounts = []
  $scope.projects = [] # projectModel

  # selected
  $scope.selectedAccount = {}
  $scope.selectedProject = {}

  # project filter string.
  $scope.projectSearchText = ""

  # http request canceled.
  STATUS_CANCEL = 0


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts.set(accounts)
      $scope.selectedAccount = $scope.accounts[0]


  ###
   When account added and not selected, update selected account.
  ###
  $scope.$on 'accountAdded', (e, account) ->
    if not $scope.selectedAccount
      $scope.selectedAccount = $scope.accounts[0]


  ###
   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    # remove a account
    if $scope.selectedAccount?.url is url
      $scope.selectedAccount = $scope.accounts[0]
    # remove projects
    newPrjs = (p for p in $scope.projects when p.url isnt url)
    $scope.projects.set(newPrjs)
    # update selected project if removed.
    if $scope.selectedProject?.url is url
      $scope.selectedProject = $scope.projects[0]


  ###
   on change selected Account, load projects.
  ###
  $scope.$watch 'selectedAccount', (account) ->
    # if account is fixed, load projects from redmine.
    if account and account.url
      params =
        page: 1
        limit: 50
      Redmine.get(account).loadProjects _updateProject, _errorLoadProject, params


  ###
   update projects by redmine's data.
  ###
  _updateProject = (data) =>
    return if not $scope.selectedAccount
    return if $scope.selectedAccount.url isnt data.url
    if data.projects?
      $scope.projects.set(data.projects)
    else
      _errorLoadProject data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadFail")


  ###
   on change projects, update selected project.
   - if projects is empty.
   - if project not selected.
   - if selected project is not included current projects.
  ###
  $scope.$watch('projects', () ->
    if $scope.projects.length is 0
      $scope.selectedProject = null
      return

    selected = $scope.selectedProject
    if not selected?
      $scope.selectedProject = $scope.projects[0]
      return

    found = $scope.projects.some (ele) -> ele.equals(selected)
    if not found
      $scope.selectedProject = $scope.projects[0]

  , true)


  ###
   filter project.
   @param {projectModel} project - filtering object.
  ###
  $scope.projectFilter = (project) ->
    if $scope.projectSearchText.isBlank() then return true
    # reg = new RegExp($scope.projectSearchText, 'i')
    # return reg.test(project.id + " " + project.text)
    return (project.id + " " + project.text).toLowerCase().contains($scope.projectSearchText.toLowerCase())


  ###
   select project.
   @param {projectModel} project - clicked object.
  ###
  $scope.selectProject = (project) ->
    $scope.selectedProject = project


  ###
   Start Initialize.
  ###
  init()
  
