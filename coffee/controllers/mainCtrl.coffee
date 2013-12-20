timeTracker.controller 'MainCtrl', ($rootScope, $scope, $ticket, $redmine, $account, analytics) ->

  TICKET_SYNC = "TICKET_SYNC"
  MINUTE_5 = 5
  TICKET_CLOSED = 5

  $rootScope.messages = []


  $ticket.load (tickets) ->
    if not tickets?
      return
    $ticket.set tickets
    $scope.$broadcast 'ticketLoaded'
    _updateIssues()


  _updateIssues = () ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      for t in $ticket.get()
        for account in accounts when account.url is t.url
          $redmine(account).getIssuesById t.id, (data, status, headers, config) ->
            if data.issue?.status.id is TICKET_CLOSED
              $ticket.remove {url: data.issue.url, id: data.issue.id }
              return
            if data.issue.spent_hours?
              total = Math.floor(data.issue.spent_hours * 100) / 100
              $ticket.setParam  data.issue.url, data.issue.id, total: total


  alarmInfo =
    when: Date.now() + 1
    periodInMinutes: MINUTE_5


  chrome.alarms.create(TICKET_SYNC, alarmInfo)
  chrome.alarms.onAlarm.addListener (alarm) ->
    if alarm.name is TICKET_SYNC
      $ticket.sync()


  analytics.sendView("")

