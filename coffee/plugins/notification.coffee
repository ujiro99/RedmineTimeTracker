###
 The class for handling desktop notification.
###
class Notification

  ###
   Notifications default options.
  ###
  DEFAULT_OPTION:
    type:        "list"
    iconUrl:     "/images/icon_notification.png"
    title:       "Tracking finished"
    isClickable: true

  # HTTP status on send success.
  STATUS_OK: 200
  STATUS_CREATED: 201


  ###
   Constructor.
  ###
  constructor: () ->
    chrome.notifications.onClicked.addListener (notificationId) =>
      chrome.notifications.clear(notificationId)
      @_showWindow()


  ###
   On time entry was sended, show desktop notification.
   @param RTT       {Object} Interface to communicate with app.
   @param timeEntry {Object} Sended time entry.
   @param status    {Number} Send result.
   @param ticket    {Object} Tracked ticket.
   @param mode      {String} Tracking mode.
  ###
  onSendedTimeEntry: (RTT, timeEntry, status, ticket, mode) =>
    return if mode isnt "pomodoro"
    options = Object.merge(@DEFAULT_OPTION, {})
    options.message = "Pomodoro finished." # will be ignored by chrome

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

    chrome.notifications.create(null, options)


  ###
   Shows app window if hided, on click notification.
  ###
  _showWindow: () ->
    currentWindow = chrome.app.window.current()
    currentWindow.show()


# Register this plugin.
RTT.registerPlugin("Notification", new Notification())
