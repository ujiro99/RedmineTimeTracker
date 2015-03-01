timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.accounts = []
  $scope.projects = []
  $scope.queries  = []
  $scope.issues   = []

  # selected
  $scope.selectedAccount = {}
  $scope.selectedProject = {}
  $scope.selectedQuery   = {}

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

  # http request canceled.
  STATUS_CANCEL = 0

  # don't use query
  QUERY_ALL_ID = 'All'


  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts.set(accounts)
      $scope.selectedAccount = $scope.accounts[0]
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
    # update selected project if remoed.
    if $scope.selectedProject?.url is url
      $scope.selectedProject = $scope.projects[0]


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
   on change selected Account, load projects.
  ###
  $scope.$watch 'selectedAccount', (newVal) ->
    account = newVal
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
      loadError data


  ###
   show error message.
  ###
  _errorLoadProject = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadFail")


  ###
   on change selected Project, load issues and queries.
  ###
  $scope.$watch 'selectedProject', (newVal) ->
    if not newVal
      $scope.queries.clear()
      return

    # load issues
    loadIssuesFirstPage()

    account = $scope.selectedAccount
    if account and account.url
      params =
        page: 1
        limit: 50
      Redmine.get(account).loadQueries(params)
        .success(_updateQuery)
        .error(_errorLoadQuery)


  ###
   update query by redmine's data.
  ###
  _updateQuery = (data) =>
    return if not $scope.selectedProject
    return if $scope.selectedProject.url isnt data.url
    newQueries = []
    newQueries.push {id: QUERY_ALL_ID, name: 'All'}
    for query in data.queries
      # filter the project-specific query
      if query.project_id
        if query.project_id is $scope.selectedProject.id
          newQueries.push query
      else
        newQueries.push query
    $scope.queries.set(newQueries)


  ###
   show error messaga.
  ###
  _errorLoadQuery = (data, status) =>
    if status is STATUS_CANCEL then return
    Message.toast Resource.string("msgLoadQueryFail")


  ###
   on change selected Query, set query to project, and udpate issues.
  ###
  $scope.$watch 'selectedQuery.id', (newVal) ->
    if not $scope.selectedProject then return
    if not $scope.selectedQuery then return

    targetId  = $scope.selectedProject.id
    targetUrl = $scope.selectedProject.url
    queryId = $scope.selectedQuery.id
    if queryId is QUERY_ALL_ID then queryId = undefined
    $scope.selectedProject.queryId = queryId
    Project.setParam(targetUrl, targetId, { 'queryId': queryId })
    loadIssuesFirstPage()


  # load issues on P.1
  loadIssuesFirstPage = () ->
    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   Start Initialize.
  ###
  init()
