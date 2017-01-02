###*
 The class for handling desktop notification.
 @class
###
class TimerNotification

  ###*
   Notification default options.
  ###
  DEFAULT_OPTION:
    type:        "list"
    iconUrl:     "/images/icon_notification.png"
    title:       "Tracking finished"
    isClickable: true

  # HTTP status on send success.
  STATUS_OK: 200
  STATUS_CREATED: 201


  ###*
   Constructor.
   @constructor
  ###
  constructor: (@_Platform) ->


  ###*
   On time entry was send, show desktop notification.
   @param {Object} RTT - Interface to communicate with app.
   @param {Object} timeEntry - Send time entry.
   @param {Number} status - Send result.
   @param {Object} ticket - Tracked ticket.
   @param {String} mode - Tracking mode.
  ###
  onSendedTimeEntry: (RTT, timeEntry, status, ticket, mode) =>
    return if mode isnt "pomodoro"
    options = Object.merge(@DEFAULT_OPTION, {})
    options.message = ""

    if (status is @STATUS_OK) or (status is @STATUS_CREATED)
      options.items = [
        { title: "Ticket",   message: ticket.text }
        { title: "Hours",    message: util.formatMinutes(timeEntry.hours * 60) }
        { title: "Activity", message: timeEntry.activity.name }
      ]
    else
      options.title = "Sending failed..."
      options.items = [
        { title: "Ticket",      message: ticket.text }
        { title: "Hours",       message: util.formatMinutes(timeEntry.hours * 60) }
        { title: "HTTP STATUS", message: status }
      ]

    @_Platform.createNotification(options)
    @_Platform.addOnClickedListener (notificationId) =>
      @_Platform.clearNotification(notificationId)
      @_Platform.showAppWindow()


if RTT?
  # Register this plugin.
  RTT.registerPlugin("TimerNotification", TimerNotification)
else
  window.addEventListener("rtt_initialized", () ->
    RTT.registerPlugin("TimerNotification", TimerNotification))
