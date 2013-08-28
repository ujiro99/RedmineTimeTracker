class ExtensionOptions

  API_KEY = "ApiKey"
  HOST = "Host"
  ID = "userId"
  USER = "/users/current.json"
  AJAX_TIME_OUT = 30 * 1000
  MESSAGE_DURATION = 2000

  ###
   Initialize Option page.
  ###
  init: ->
    setupEventBinding()
    restoreOptions()


  ###
   Setup page navigation events
  ###
  setupEventBinding = ->
    $("#navigation").on "click", "li", ->
      showSettingsPage @attributes.getNamedItem("controls").value
    $("#saveButton").on "click", ->
      saveOptions()


  ###
   Show settig page which clicked by user
  ###
  showSettingsPage = (controlsAttribute) ->
    if controlsAttribute is "general"
      $("#general").addClass "pageSelected"
      $("#about").removeClass "pageSelected"
      $("#navGeneral").addClass "selected"
      $("#navAbout").removeClass "selected"
    else if controlsAttribute is "about"
      $("#about").addClass "pageSelected"
      $("#general").removeClass "pageSelected"
      $("#navAbout").addClass "selected"
      $("#navGeneral").removeClass "selected"


  ###
   save
  ###
  saveOptions = () ->
    apiKey = $("##{API_KEY}").val()
    host = $("##{HOST}").val()
    loadUser(host, apiKey)
    .then(saveSucess, saveFail)


  ###
   sucess to save
  ###
  saveSucess = (res) ->
    localStorage[API_KEY] = res.apiKey
    localStorage[HOST] = res.host
    localStorage[ID] = res.id
    status = $("#status")
    status.html "Options Saved."
    setTimeout ->
      status.html ""
    , MESSAGE_DURATION


  ###
   fail to save
  ###
  saveFail = (res) ->
    status = $("#status")
    status.html "Save Failed. #{res}"
    setTimeout ->
      status.html ""
    , MESSAGE_DURATION


  ###
   restore
  ###
  restoreOptions = () ->
    apiKey = localStorage[API_KEY]
    host = localStorage[HOST]

    if not apiKey? or not host? then return

    $("##{API_KEY}").val apiKey
    $("##{HOST}").val host


  ###
   Load the user ID associated to Api Key.
  ###
  loadUser = (host, apiKey) ->
    d = new $.Deferred
    $.ajax(
      type: "GET"
      url: host + USER
      contentType: "application/json"
      headers:
        "X-Redmine-API-Key": apiKey
      timeout: AJAX_TIME_OUT
    ).then( (msg) ->
        if msg?.user?.id?
          d.resolve {
            host: host
            apiKey: apiKey
            id: msg.user.id
          }
        else
          d.reject(msg)
      , (msg) ->
         d.reject("faild to load user")
    )
    return d.promise()


$ ->
  extensionOptions = new ExtensionOptions()
  extensionOptions.init()

