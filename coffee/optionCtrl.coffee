timeTracker.controller('OptionCtrl', ['$scope', '$http', '$account', '$message', ($scope, $http, $account, $message) ->

  USER = "/users/current.json?include=memberships"
  AJAX_TIME_OUT = 30 * 1000

  $scope.status = ""
  $scope.option = { apiKey:'', host:'' }


  ###
   Initialize Option page.
  ###
  init = ->
    # restore accounts
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts[0]? then return
      host   = accounts[0].host
      apiKey = accounts[0].apiKey
      $scope.$apply ->
        $scope.option.host   = host
        $scope.option.apiKey = apiKey


  ###
   Load the user ID associated to Api Key.
  ###
  $scope.saveOptions = () ->
    config =
      method: "GET"
      url: $scope.option.host + USER
      headers:
        "X-Redmine-API-Key": $scope.option.apiKey
      timeout: AJAX_TIME_OUT
    $http(config)
      .success(saveSucess)
      .error(saveFail)


  ###
   sucess to save
  ###
  saveSucess = (msg) ->
    if msg?.user?.id?
      account =
        apiKey: $scope.option.apiKey
        host: $scope.option.host
        userId: msg.user.id
      $account.addAccount account, (result) ->
        if result
          $message.toast "Options Saved."
        else
          saveFail null
    else
      saveFail msg


  ###
   fail to save
  ###
  saveFail = (msg) ->
    $message.toast "Save Failed. #{msg}"


  ###
   clear all account data.
  ###
  $scope.clearOptions = () ->
    $account.clearAccount (result) ->
      if result
        $message.toast "Options Cleared."
      else
        $message.toast "Clear Failed."


  ###
   Initialize
  ###
  init()

])
