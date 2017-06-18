timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, $q, $modal, Ticket, Project, Account, State, DataAdapter, Message, Platform, Resource, Option, Log, Analytics, RedmineLoader) ->

  # represents 5 minuts [msec]
  MINUTE_5 = 5 * 60 * 1000

  # List for toast Message.
  $rootScope.messages = []
  # Global state
  $scope.state = State
  # Root font size
  $scope.options = Option.getOptions()

  ###
   Initialize.
  ###
  init = () ->
    deferred = $q.defer()
    deferred.promise
      .then(_setLoginLister)
      .then(_initializeGoogleAnalytics)
      .then(_initializeDataFromChrome)
      .then(_initializeDataFromRedmine)
      .then(_initializeEvents)
      .then(_startDataSync)
    deferred.resolve()

  ###
   initialize events.
  ###
  _initializeEvents = () ->
    Log.debug "[4] initializeEvents start"
    DataAdapter.addEventListener DataAdapter.ACCOUNT_ADDED, RedmineLoader.fetchAllData
    DataAdapter.addEventListener DataAdapter.ACCOUNT_UPDATED, RedmineLoader.fetchAllData
    DataAdapter.addEventListener DataAdapter.SELECTED_PROJECT_CHANGED, _syncSelectedProject
    DataAdapter.addEventListener DataAdapter.PROJECTS_CHANGED, () ->
      Project.syncLocal(DataAdapter.getProjects())
    DataAdapter.addEventListener DataAdapter.TICKETS_CHANGED, () ->
      Ticket.syncLocal(DataAdapter.tickets)
    Option.onChanged('reportUsage', (val) -> Analytics.setPermission(val))
    Option.onChanged('hideNonTicketProject',  _toggleProjectHidden)
    Log.debug "[4] initializeEvents success"

  ###
   count project's issues count on all accounts.
  ###
  _toggleProjectHidden = (enableHide) ->
    if enableHide
      for a in Account.getAccounts()
        _loadIssueCount(a)()
    else
      DataAdapter.updateProjects()

  ###
   request a setup of redmine account to user.
  ###
  _requestAddAccount = () ->
    $timeout () ->
      State.isAddingAccount = true
      State.isCollapseSetting = false
    , 500
    $timeout () ->
      $location.hash('accounts')
      $anchorScroll()
    , 1000
    $timeout () ->
      Message.toast(Resource.string("msgRequestAddAccount_0"), 5000)
    , 1500
    $timeout () ->
      Message.toast(Resource.string("msgRequestAddAccount_1"), 5000)
    , 2500

  ###
   initialize GoogleAnalytics.
  ###
  _initializeGoogleAnalytics = () ->
    Log.debug "[1] initializeGoogleAnalytics start"
    Analytics.init {
      serviceName:   "RedmineTimeTracker"
      analyticsCode: "UA-32234486-7"
    }
    Analytics.sendView(Platform.getPlarform())
    Log.debug "[1] initializeGoogleAnalytics success"

  ###
   initialize Data from chrome storage.
  ###
  _initializeDataFromChrome = () ->
    Log.debug "[2] initializeDataFromChrome start"
    Option.loadOptions()
      .then(_initializeAccount)
      .then(_initializeProject)
      .then(_initializeTicket)
      .then(() ->
        Log.debug "[2] initializeDataFromChrome success."
      , () ->
        Log.warn "[2] initializeDataFromChrome failed")

  ###
   Initialize account from chrome storage.
  ###
  _initializeAccount = () ->
    Account.load().then (accounts) ->
      if accounts and not accounts.isEmpty()
        DataAdapter.addAccounts(accounts)
      else
        _requestAddAccount()

  ###
   Initialize project from chrome storage.
  ###
  _initializeProject = () ->
    Project.load()
      .then((projects) ->
        DataAdapter.addProjects(projects)
        # restore last selected project.
        Platform.load(Platform.SELECTED_PROJECT))
      .then((selected) ->
        if not selected? then return
        projects = DataAdapter.getProjects(selected.url)
        project = projects.find (p) -> p.equals(selected)
        DataAdapter.selectedProject = project)

  ###
   Initialize issues status.
  ###
  _initializeTicket = () ->
    Ticket.load()
      .then((res) -> DataAdapter.toggleIsTicketShow(res.tickets))

  ###
   initialize Data from Redmine.
  ###
  _initializeDataFromRedmine = () ->
    Log.debug "[3] initializeDataFromRedmine start "
    accounts = DataAdapter.getAccount()
    $q.all(RedmineLoader.fetchAllData(accounts))
      .finally(-> Log.debug "[3] initializeDataFromRedmine success")

  ###*
   Start data synchronization.
  ###
  _startDataSync = () ->
    window.setInterval(() ->
      Ticket.sync(DataAdapter.tickets)
      Project.sync(DataAdapter.getProjects())
    , MINUTE_5)

  ###*
   Sync a selected project to chrome storage.
  ###
  _syncSelectedProject = () ->
    selected = DataAdapter.selectedProject
    obj = {
      url: selected.url
      id: selected.id
    }
    Platform.save(Platform.SELECTED_PROJECT, obj)

  ###*
   Set proxy login event lister.
  ###
  _setLoginLister = () ->
    return if 'electron' isnt Platform.getPlarform()
    isShowingModal = false
    Platform.setLoginLister (callback) ->
      return if isShowingModal
      isShowingModal = true
      modal = $modal.open {
        templateUrl: Platform.getPath('/views/proxyLogin.html')
        controller: loginCtrl
      }
      modal.result.then (auth) ->
        isShowingModal = false
        callback(auth)
      , () ->
        isShowingModal = false
        callback(null) # canceled

  ###*
   Controller for input login infomation dialog.
  ###
  loginCtrl = ($scope, $modalInstance, Resource) ->
    $scope.R = Resource
    $scope.ok = () ->
      $modalInstance.close {
        username: this.username
        password: this.password
      }
    $scope.cancel = () ->
      $modalInstance.dismiss 'canceled.'
  loginCtrl.$inject = ['$scope', '$modalInstance', 'Resource']


  ###
   Start Initialize.
  ###
  init()

