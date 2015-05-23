timeTracker.controller 'headerCtrl', ($scope, Account, Redmine, Project, DataAdapter, Message, Resource, Analytics) ->

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
