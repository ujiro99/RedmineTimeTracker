timeTracker.factory "analytics", () ->

  AppPrefix = "/app/"
  AnalyticsCode = "UA-32234486-7"
  service = analytics.getService("RedmineTimeTracker")
  tracker = service.getTracker(AnalyticsCode)

  return {

    ###*
     Track a click on a button using the asynchronous tracking API.
     @method sendEvent
     @param {String}  category The name you supply for the group of objects you want to track (required).
     @param {String}  action   A string that is uniquely paired with each category, and commonly used to define the type of user interaction for the web object (required).
     @param {String}  label    An optional string to provide additional dimensions to the event data (optional).
     @param {Integer} value    An integer that you can use to provide numerical data about the user event (optional).
    ###
    sendEvent: (category, action, label, value) ->
      tracker.sendEvent category, action, label, value


    ###*
     Track a view using the asynchronous tracking API.
     @method sendView
     @param {String} view's name which will be tracked.
    ###
    sendView: (viewName) ->
      tracker.sendAppView AppPrefix + viewName


    ###*
     Set Tracking is permitted.
     @method setPermittion
     @param {Boolean} permitted  Is enable tracking.
    ###
    setPermittion: (permitted) ->
      service.getConfig().addCallback (config) ->
        config.setTrackingPermitted(permitted)

  }
