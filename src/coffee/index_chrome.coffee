class RedmineTimeTracker

  @ID: "main"
  @URL: "/views/index.html"
  @BOUND: "BOUND"
  @DEFAULT_BOUNDS: { width: 250, height: 550 }
  @GA_PARAM: { serviceName: "RedmineTimeTracker", analyticsCode: "UA-32234486-7" }


  constructor: () ->
    @ga = @initGoogleAnalytics()
    chrome.runtime.onInstalled.addListener(@onInstalled)
    chrome.app.runtime.onLaunched.addListener(@onLaunched)


  onLaunched: (details) =>
    details or details = {}
    @ga.sendEvent "app", "launched", details.source, 1

    # load saved position.
    chrome.storage.local.get RedmineTimeTracker.BOUND, (bounds) ->

      windowOptions = {
        id: RedmineTimeTracker.ID
        innerBounds: bounds.BOUND or RedmineTimeTracker.DEFAULT_BOUNDS # restore window size.
      }
      # create window.
      chrome.app.window.create RedmineTimeTracker.URL, windowOptions, () ->

        # remember window size and position.
        chrome.app.window.get(RedmineTimeTracker.ID).onClosed.addListener(@onClosed)


  onClosed: () =>
    innerBounds = chrome.app.window.get(RedmineTimeTracker.ID).innerBounds
    bounds =
      top:    innerBounds.top
      left:   innerBounds.left
      height: innerBounds.height
      width:  innerBounds.width
    chrome.storage.local.set { BOUND: bounds }


  onInstalled: (details) =>
    @ga.sendEvent "app", "installed", details.reason, 1


  initGoogleAnalytics: () =>
    service = analytics.getService(RedmineTimeTracker.GA_PARAM.serviceName)
    service.getTracker(RedmineTimeTracker.GA_PARAM.analyticsCode)


# start up
new RedmineTimeTracker()
