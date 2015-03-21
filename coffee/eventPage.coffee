ID = "main"
URL = '/views/index.html'
BOUND = "BOUND"
DEFAULT_BOUNDS =
  'width': 250,
  'height': 550

# open window
chrome.app.runtime.onLaunched.addListener () ->

  # load saved poisiton.
  chrome.storage.local.get BOUND, (bounds) ->

    windowOptions =
      'id': ID
      'innerBounds': bounds.BOUND or DEFAULT_BOUNDS # restore window size.
      'frame': "none"

    # create window.
    chrome.app.window.create URL, windowOptions, () ->

      # remember window size and position.
      chrome.app.window.get(ID).onClosed.addListener () ->
        innerBounds = chrome.app.window.get(ID).innerBounds
        bounds =
          top:    innerBounds.top
          left:   innerBounds.left
          height: innerBounds.height
          width:  innerBounds.width
        chrome.storage.local.set BOUND: bounds
