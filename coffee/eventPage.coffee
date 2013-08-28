chrome.browserAction.onClicked.addListener (tab) ->
  chrome.windows.create
    url: "/views/timer.html"
    type: "popup"
    width: 280
    height: 100
  , (window) ->
    console.log "open timer"
