timeTracker.controller 'headerCtrl', ($scope, DataAdapter, Const) ->

  # data
  $scope.data = DataAdapter
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
   Close application.
  ###
  $scope.closeWindow = () ->
    window.close()

  $scope.toggleStar = (project) ->
    if project.show is Const.SHOW.DEFAULT
      project.show = Const.SHOW.SHOW
    else
      project.show = project.show % 2 + 1
