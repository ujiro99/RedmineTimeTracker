timeTracker.controller 'headerCtrl', ($scope, DataAdapter, Const, Option) ->

  # data
  $scope.data = DataAdapter
  # option
  $scope.options = Option.getOptions()
  # is header dropdown active?
  $scope.isActive = false

  ###
   select project.
   @param {projectModel} project - clicked object.
  ###
  $scope.selectProject = (project) ->
    DataAdapter.selectedProject = project
    $scope.isActive = false

  ###
   Toggle star on project.
  ###
  $scope.toggleStar = (project) ->
    if project.show is Const.SHOW.DEFAULT
      project.show = Const.SHOW.SHOW
    else
      project.show = project.show % 2 + 1
    DataAdapter.addProjects([project])
