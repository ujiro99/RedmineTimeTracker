timeTracker.controller('OptionCtrl', ['$scope', '$redmine', '$account', '$message', ($scope, $redmine, $account, $message) ->

  $scope.option = { apiKey:'', url:'' }

  ###
   Initialize Option page.
  ###
  init = ->
    # restore accounts
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts[0]? then return
      url    = accounts[0].url
      apiKey = accounts[0].apiKey
      $scope.$apply ->
        $scope.option.url    = url
        $scope.option.apiKey = apiKey


  ###
   Load the user ID associated to Api Key.
  ###
  $scope.saveOptions = () ->
    url = $scope.option.url
    apiKey = $scope.option.apiKey
    $redmine(url, apiKey).user.get(saveSucess, saveFail)


  ###
   sucess to save
  ###
  saveSucess = (msg) ->
    if msg?.user?.id?
      account =
        apiKey: $scope.option.apiKey
        url:    $scope.option.url
        userId: msg.user.id
      $account.addAccount account, (result) ->
        if result
          $message.toast "Option Saved."
          $message.toast "Your user ID is #{msg.user.id}."
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
