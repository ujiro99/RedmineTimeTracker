timeTracker.controller 'MainCtrl', ($rootScope, $scope, $timeout, $location, $anchorScroll, $window, Ticket, Redmine, Account, State, Message, Analytics, Resource) ->

  TICKET_SYNC = "TICKET_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5

  $rootScope.messages = []


  Ticket.load (tickets) ->
    if not tickets?
      return
    Ticket.set tickets
    $scope.$broadcast 'ticketLoaded'
    _updateIssues()


  _updateIssues = () ->
    Account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]?
        requestAddAccount()
        return
      for t in Ticket.get()
        for account in accounts when account.url is t.url
          Redmine.get(account).getIssuesById t.id, (data) ->
            newParam =
              subject: data.issue.subject
              text: data.issue.id + ' ' + data.issue.subject
            Ticket.setParam  data.issue.url, data.issue.id, newParam
            if data.issue?.status.id is TICKET_CLOSED
              Ticket.remove {url: data.issue.url, id: data.issue.id }
              return
            if data.issue.spent_hours?
              total = Math.floor(data.issue.spent_hours * 100) / 100
              Ticket.setParam  data.issue.url, data.issue.id, total: total


  ###
   request a setup of redmine account to user.
  ###
  requestAddAccount = () ->
    State.isAdding = true
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
  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      Ticket.sync()


  Analytics.init {
    serviceName:   "RedmineTimeTracker"
    analyticsCode: "UA-32234486-7"
  }
  Analytics.sendView("/app/")

