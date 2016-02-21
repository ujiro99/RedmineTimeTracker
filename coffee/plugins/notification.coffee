###
 The class for handling desktop notification.
###
class Notification

  ###
   Notifications default options.
  ###
  DEFAULT_OPTION:
    type:        "basic"
    iconUrl:     "/images/icon_128.png"
    title:       "Tracking finished"
    isClickable: true


  ###
   Constructor.
  ###
  constructor: () ->
    chrome.notifications.onClicked.addListener (notificationId) =>
      @_showWindow()
      chrome.notifications.clear(notificationId)


  ###
   On time entry was sended, show desktop notification.
   @param RTT       {Object} Interface to communicate with app.
   @param timeEntry {Object} Sended time entry.
   @param ticket    {Object} Tracked ticket.
   @param mode      {String} Tracking mode.
  ###
  onSendedTimeEntry: (RTT, timeEntry, ticket, mode) =>
    return if mode isnt "pomodoro"
    options = {}
    options.message = mode + " finished."
    options.contextMessage = ticket.text + ": " + util.formatMinutes(timeEntry.hours * 60)
    options = Object.merge(@DEFAULT_OPTION, options)
    chrome.notifications.create(null, options)


  ###
   Shows app window if hided, on click notification.
  ###
  _showWindow: () ->
    currentWindow = chrome.app.window.current()
    currentWindow.show()


# register plugin
RTT.addPlugin("Notification", new Notification())
