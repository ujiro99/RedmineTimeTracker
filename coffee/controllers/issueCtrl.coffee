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
    $scope.accountData =
      displayKey: 'url'
      source: substringMatcher($scope.accounts, 'url')

    # projects
    $scope.projectData =
      displayKey: 'text'
      source: substringMatcher($scope.projects, 'text')

    # query
    $scope.queryData =
      displayKey: 'name'
      source: substringMatcher($scope.queries, 'name')


  substringMatcher = (objects, key) ->
    return findMatches = (query, cb) ->
      matches = []
      substrRegexs = []
      queries = []
      for q in query.split(' ') when not q.isBlank()
        queries.push q
        substrRegexs.push new RegExp(q, 'i')

      for obj in objects
        isAllMatch = true
        for r in substrRegexs
          isAllMatch = isAllMatch and r.test(obj[key])

        matches.push(obj) if isAllMatch

      cb(matches, queries)


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
