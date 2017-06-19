timeTracker.controller 'headerCtrl', ($scope, DataAdapter, RedmineLoader, Const, Option, State) ->

  # data
  $scope.data = DataAdapter
  # option
  $scope.options = Option.getOptions()
  # is header dropdown active?
  $scope.isActive = false
  # global state.
  $scope.state = State


  ###*
   Select project.
   @param {projectModel} project - clicked object.
  ###
  $scope.selectProject = (project) ->
    DataAdapter.selectedProject = project
    $scope.isActive = false


  ###*
   Toggle star on project.
   @param {projectModel} project - clicked object.
  ###
  $scope.toggleStar = (project) ->
    if project.show is Const.SHOW.DEFAULT
      project.show = Const.SHOW.SHOW
    else
      project.show = project.show % 2 + 1
    DataAdapter.addProjects([project])


  ###*
   Reload project and tickets.
  ###
  $scope.reload = () ->
    accounts = DataAdapter.getAccount()
    RedmineLoader.fetchAllData(accounts)
