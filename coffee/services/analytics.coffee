angular.module('analytics', [])
  .factory 'Analytics', ['$log', ($log) ->

    _service = null
    _tracker = null

    return {

      ###*
       Set parameter, and initialize.
       @method init
       @param param {Object} Parameter for Initialize (required).
       @param param.serviceName {String} service name (required).
       @param param.analyticsCode {String} google analytics code (required). ex) UA-32234486-7
      ###
      init: (param) ->
        _service = analytics.getService(param.serviceName)
        _tracker = _service.getTracker(param.analyticsCode)


      ###*
       Track a click on a button using the asynchronous tracking API.
       @method sendEvent
       @param category {String} The name you supply for the group of objects you want to track (required).
       @param action {String} A string that is uniquely paired with each category, and commonly used to define the type of user interaction for the web object (required).
       @param label {String} An optional string to provide additional dimensions to the event data (optional).
       @param value {Integer} An integer that you can use to provide numerical data about the user event (optional).
      ###
      sendEvent: (category, action, label, value) ->
        if not _tracker
          $log.error "please init analytics."
          return
        _tracker.sendEvent category, action, label, value


      ###*
       Track a view using the asynchronous tracking API.
       @method sendView
       @param viewName {String} view's name which will be tracked.
      ###
      sendView: (viewName) ->
        if not _tracker
          $log.error "please init analytics."
          return
        _tracker.sendAppView viewName


      ###*
       Set Tracking is permitted.
       @method setPermission
       @param permitted {Boolean} Is enable tracking.
      ###
      setPermission: (permitted) ->
        if not _service
          $log.error "please init analytics."
          return
        _service.getConfig().addCallback (config) ->
          config.setTrackingPermitted(permitted)

    }
  ]
