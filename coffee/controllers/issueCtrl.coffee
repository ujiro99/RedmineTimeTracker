timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.accounts = []
  $scope.projects = []
  $scope.queries  = []
  $scope.issues   = []

  # selected
  $scope.selectedAccount = []
  $scope.selectedProject = []
  $scope.selectedQuery   = []
  # typeahead data
  $scope.accountData = null
  $scope.projectData = null
  $scope.queryData   = null

  $scope.searchField = text: ''
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0
  $scope.state = State

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0



  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts = accounts
      $scope.selectedAccount[0] = $scope.accounts[0]
      initializeSearchform()
    $scope.editState = new IssueEditState($scope)


  ###
   Initialize .
  ###
  initializeSearchform = () ->
    # account
    accountsBh = new Bloodhound
      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.url)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: $scope.accounts
    accountsBh.initialize()
    $scope.accountData =
      displayKey: 'url'
      source: accountsBh.ttAdapter()
    # projects
    projectsBh = new Bloodhound
      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.text)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: $scope.projects
    projectsBh.initialize()
    $scope.projectData =
      displayKey: 'text'
      source: projectsBh.ttAdapter()
    # query
    queryBh = new Bloodhound
      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.name)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: $scope.queries
    queryBh.initialize()
    $scope.queryData =
      displayKey: 'name'
      source: queryBh.ttAdapter()


   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
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
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   on change projects, update selected.
  ###
  $scope.$watch 'projects', () ->
    if $scope.projects.length is 0
      $scope.selectedProject.clear()
      return

    selected = $scope.selectedProject[0]
    if not selected?
      $scope.selectedProject[0] = $scope.projects[0]
      return

    found = $scope.projects.some (ele) -> ele.equals(selected)
    if not found
      $scope.selectedProject[0] = $scope.projects[0]
  , true


  ###
   Start Initialize.
  ###
  init()
