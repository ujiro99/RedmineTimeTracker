timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, Ticket, Project, Redmine, Account, State, Message, Analytics, Chrome, Resource, Option) ->

  DATA_SYNC = "DATA_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5
  NOT_FOUND = 404
  UNAUTHORIZED = 401

  $rootScope.messages = []


  Ticket.load (tickets) ->
    if not tickets?
      return
    updateIssues()


  Option.getOptions (options) ->
    $scope.options = options


  ###
   update issues status.
  ###
  updateIssues = () ->
    Account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]?
        return
      for t in Ticket.get()
        for account in accounts when account.url is t.url
          Redmine.get(account).getIssuesById t.id, issueFound, issueNotFound
          break


  ###
   when issue found, update according to status.
  ###
  issueFound = (data) ->
    newParam =
      text: data.issue.subject
    Ticket.setParam  data.issue.url, data.issue.id, newParam
    if data.issue?.status.id is TICKET_CLOSED
      Ticket.remove {url: data.issue.url, id: data.issue.id }
      return
    if data.issue.spent_hours?
      total = Math.floor(data.issue.spent_hours * 100) / 100
      Ticket.setParam  data.issue.url, data.issue.id, total: total


  ###
   when issue not found, remove issue.
  ###
  issueNotFound = (data, status) ->
    if status is NOT_FOUND or status is UNAUTHORIZED
      Ticket.remove {url: data.issue.url, id: data.issue.id }
      return


  ###
   check account exist.
  ###
  Account.getAccounts (accounts) ->
    if not accounts? or not accounts?[0]?
      requestAddAccount()
      return


  ###
   request a setup of redmine account to user.
  ###
  requestAddAccount = () ->
    $timeout () ->
      State.isAdding = true
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
   scroll to positon.
  ###
  $scope.scroll = (position) ->
    $location.hash(position)
    $anchorScroll()


  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5
  Chrome.alarms.create(DATA_SYNC, alarmInfo)
  Chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is DATA_SYNC
      Ticket.sync()
      Project.sync()


  Analytics.init {
    serviceName:   "RedmineTimeTracker"
    analyticsCode: "UA-32234486-7"
  }
  Analytics.sendView("/app/")

