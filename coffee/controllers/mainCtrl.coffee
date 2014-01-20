timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, Ticket, Project, Redmine, Account, State, Message, Analytics, Resource) ->

  DATA_SYNC = "DATA_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5

  $rootScope.messages = []


  Ticket.load (tickets) ->
    if not tickets?
      return
    Ticket.set tickets
    _updateIssues()


  ###
   update issues status.
  ###
  _updateIssues = () ->
    Account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]?
        return
      for t in Ticket.get()
        for account in accounts when account.url is t.url
          Redmine.get(account).getIssuesById t.id, (data) ->
            newParam =
              text: data.issue.subject
            Ticket.setParam  data.issue.url, data.issue.id, newParam
            if data.issue?.status.id is TICKET_CLOSED
              Ticket.remove {url: data.issue.url, id: data.issue.id }
              return
            if data.issue.spent_hours?
              total = Math.floor(data.issue.spent_hours * 100) / 100
              Ticket.setParam  data.issue.url, data.issue.id, total: total
          break


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


  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5
  chrome.alarms.create(DATA_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is DATA_SYNC
      Ticket.sync()
      Project.sync()


  Analytics.init {
    serviceName:   "RedmineTimeTracker"
    analyticsCode: "UA-32234486-7"
  }
  Analytics.sendView("/app/")

