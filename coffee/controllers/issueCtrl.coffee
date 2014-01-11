timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics) ->

  STATUS_CANCEL = 0
  MODE = {ISSUE: "Issues", PROJECT: "Projects"}

  $scope.accounts = []
  $scope.currentPage = 1
  $scope.issues = []
  $scope.itemsPerPage = 50
  $scope.listData = {}
  $scope.mode = MODE.ISSUE
  $scope.projects = []
  $scope.projectsInList = []
  $scope.searchText = ''
  $scope.selected = []
  $scope.selectedAccount = []
  $scope.selectedProject = []
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts = accounts
      $scope.selectedAccount[0] = $scope.accounts[0]
    $scope.projects = Project.getSelectable()
    $scope.editState = new IssueEditState($scope, Ticket, State, Message, Resource)


  ###
   start getting issues.
  ###
  $scope.$on 'accountAdded', (e, account) ->
    Redmine.get(account).getIssuesOnUser(getIssuesSuccess)
    if not $scope.selectedAccount[0]
      $scope.selectedAccount[0] = $scope.accounts[0]


  ###
   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    # remove a account
    if $scope.selectedAccount[0]?.url is url
      $scope.selectedAccount[0] = $scope.accounts[0]
    # remove projects
    newPrjs = (p for p, i in $scope.projects when p.url isnt url)
    $scope.projects.clear()
    for p in newPrjs then $scope.projects.push p
    if $scope.selectedProject[0]?.url is url
      $scope.selectedProject[0] = $scope.projects[0]


  ###
   on change selected, start loading.
  ###
  $scope.$watch 'selected[0]', () ->
    $scope.currentPage = 1
    $scope.editState.load($scope.currentPage)


  ###
   on change currentPage, start loading.
  ###
  $scope.$watch 'currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load($scope.currentPage)


  ###
   on change projects, update selected.
  ###
  $scope.$watch 'projects', (b, a) ->
    if $scope.projects.length is 0
      $scope.selectedProject.clear()
    if not $scope.selectedProject[0]?
      $scope.selectedProject[0] = $scope.projects[0]
  , true


  ###
   add assigned issues.
  ###
  getIssuesSuccess = (data) ->
    if not data? then return
    Ticket.addArray data.issues
    Ticket.sync()


  ###
   change edit mode.
  ###
  $scope.changeMode = () ->
    if $scope.mode is MODE.ISSUE
      $scope.mode = MODE.PROJECT
      $scope.editState = new ProjectEditState($scope, Project, State, Message, Resource)
    else
      $scope.mode = MODE.ISSUE
      $scope.editState = new IssueEditState($scope, Ticket, State, Message, Resource)


  ###
   base state.
  ###
  class BaseEditState

    @inject: []
    @SHOW: { DEFAULT: 0, NOT: 1, SHOW: 2 }


    ###
     check item was contained in selectableTickets.
    ###
    isContained: (item) ->
      selectable = $scope.listData.getSelectable()
      found = selectable.some (e) -> item.equals e
      return found


    ###
     on user selected item.
    ###
    onClickItem: (item) ->
      if @isContained(item)
        @removeItem(item)
      else
        @addItem(item)


    ###
     add selected item.
    ###
    addItem: (item) ->
      item.show = BaseEditState.SHOW.SHOW
      $scope.listData.add item
      $scope.listData.setParam item.url, item.id, {show: BaseEditState.SHOW.SHOW}
      Message.toast Resource.string("msgAdded").format(item.text)


    ###
     remove selected item.
    ###
    removeItem: (item) ->
      item.show = BaseEditState.SHOW.NOT
      $scope.listData.setParam item.url, item.id, {show: BaseEditState.SHOW.NOT}


    ###
     filter issues by searchText.
    ###
    listFilter: (item) ->
      if $scope.searchText.isBlank() then return true
      return (item.id + "").contains($scope.searchText) or
             item.text.toLowerCase().contains($scope.searchText.toLowerCase())


    ###
     load data.
    ###
    load: (page) ->


    ###
     open link on other window.
    ###
    openLink: (url) ->
      a = document.createElement('a')
      a.href = url
      a.target='_blank'
      a.click()


    ###
     calculate tooltip position.
    ###
    onMouseMove: (e) ->
      if e.clientY > $window.innerHeight / 2
        $scope.tooltipPlace = 'top'
      else
        $scope.tooltipPlace = 'bottom'


  ###
   controller for issue edit mode.
  ###
  class IssueEditState extends BaseEditState

    @inject: ['$scope', 'Ticket', 'State', 'Message', 'Resource']

    constructor: (@$scope, @listData, @State, @Message, @Resource) ->
      @$scope.listData = listData
      @$scope.selected = @$scope.selectedProject


    removeItem: (item) ->
      selected = $scope.listData.getSelected()[0]
      if State.isTracking and item.equals selected
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    ###
     load issues according selected project.
    ###
    load: (page) ->
      if not $scope.selectedProject[0]?
        $scope.issues.clear()
        return
      account = (a for a in $scope.accounts when $scope.selectedProject[0].url is a.url)[0]
      projectId = $scope.selectedProject[0].id
      params =
        page: page
        limit: $scope.itemsPerPage
      Redmine.get(account).getIssuesOnProject(projectId, params, @loadSuccess, @loadError)


    ###
     on loading success, update issue list
    ###
    loadSuccess: (data) ->
      return if $scope.selectedProject[0].url isnt data.url
      return if $scope.currentPage - 1 isnt data.offset / data.limit
      $scope.totalItems = data.total_count
      for issue in data.issues
        for t in Ticket.get() when issue.equals t
          issue.show = t.show
      $scope.issues = data.issues


    ###
     show fail message.
    ###
    loadError: (data, status) ->
      if status is STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadIssueFail")


  ###
   controller for project edit mode.
  ###
  class ProjectEditState extends BaseEditState

    @inject: ['$scope', 'Project', 'State', 'Message', 'Resource']

    constructor: (@$scope, @listData, @State, @Message, @Resource) ->
      @$scope.listData = listData
      @$scope.selected = @$scope.selectedAccount


    removeItem: (item) ->
      selected = Ticket.getSelected()[0]
      if State.isTracking and item.url is selected.url
        return
      super(item)
      Message.toast Resource.string("msgRemoved").format(item.text)


    load: (page) ->
      if not $scope.selectedAccount[0]?
        $scope.projectsInList.clear()
        return
      account = $scope.selectedAccount[0]
      params =
        page: page
        limit: $scope.itemsPerPage
      Redmine.get(account).loadProjects @loadSuccess, @loadError, params


    loadSuccess: (data) ->
      return if $scope.selectedAccount[0].url isnt data.url
      return if $scope.currentPage - 1 isnt data.offset / data.limit
      $scope.totalItems = data.total_count
      if data.projects?
        $scope.projectsInList = data.projects
      else
        @loadError data


    loadError: (data, status) ->
      if status is STATUS_CANCEL then return
      Message.toast Resource.string("msgLoadFail")


  ###
   Start Initialize.
  ###
  init()
