'use strict'
{ app, BrowserWindow, Menu } = require('electron')
{ autoUpdater } = require("electron-auto-updater")
isDev = require('electron-is-dev')
storage = require('electron-json-storage')


if isDev
  # adds debug features like hotkeys for triggering dev tools and reload
  require('electron-debug')()
else
  autoUpdater.checkForUpdates()

# Show DevTools if set debug mode.
storage.get 'debug', (err, debug) ->
  if debug
    require('electron-debug')({ showDevTools: true })


LOGIN = "login"
BOUND = "bound"
PROXY_AUTH = "proxy_auth"
DEFAULT_BOUNDS = { width: 250, height: 550 }

# prevent window being garbage collected
_mainWindow = undefined
_bound = {}
_event = {}
_triedSavedAccount = false
_proxyAuthCallback = null


###*
 On closed listener.
###
onClosed = () ->
  # console.log('closed')
  # derefernece the window.
  _mainWindow = null
  return

app.on 'window-all-closed', ->
  # console.log('window-all-closed')
  saveWindowBounds () ->
    if process.platform != 'darwin'
      app.quit()
  return

app.on 'activate', ->
  # console.log('activate')
  return if _mainWindow
  getWindowBounds (bound) ->
    _mainWindow = createMainWindow(bound)
  return

app.on 'ready', ->
  # console.log('ready')
  Menu.setApplicationMenu(Menu.buildFromTemplate(template))
  getWindowBounds (bound) ->
    _mainWindow = createMainWindow(bound)
  return

app.on 'login', (event, webContents, request, authInfo, callback) ->
  if authInfo.isProxy
    event.preventDefault()
    if _proxyAuthCallback?
      _proxyAuthCallback = callback
      return

    _proxyAuthCallback = callback

    # If proxy password is already exists, use it.
    storage.get PROXY_AUTH, (err, auth) ->
      # console.log(auth)
      if err
        console.log('Failed to get auth.')
      else if not _triedSavedAccount and auth? and auth.password?
        _proxyAuthCallback(auth.username, auth.password)
        _proxyAuthCallback = null
        _triedSavedAccount = true
      else
        func = _event[LOGIN]
        return _proxyAuthCallback(null, null) if not func?
        func (auth) ->
          return if not auth?
          _proxyAuthCallback(auth.username, auth.password)
          _proxyAuthCallback = null
          _triedSavedAccount = false
          storage.set PROXY_AUTH, auth, (err) ->
            return if not err
            console.log('Failed to set window bounds.')

autoUpdater.on 'update-downloaded', (event, releaseNotes, releaseName) ->
  index = dialog.showMessageBox({
    message: "Update Available."
    detail: releaseName + "\n\n" + releaseNotes
    buttons: ["Update now", "Later"]
  })
  if index is 0
    autoUpdater.quitAndInstall()

###*
 Rectangle Object
 @typedef {object} Rectangle
 @param {number} x - The x coordinate of the origin of the rectangle
 @param {number} y - The y coordinate of the origin of the rectangle
 @param {number} width
 @param {number} height
###

###*
 @param {Rectangle} bound - Window size and position.
 @return {BrowserWindow} Main window instance.
###
createMainWindow = (bound) ->
  if bound.width
    bound = bound
  else if _bound.width
    bound = _bound
  else
    bound = DEFAULT_BOUNDS
  win = new (BrowserWindow)({
    width: bound.width
    height: bound.height
  })
  win.setMenu(null)
  if bound.x? and bound.y?
    win.setPosition(bound.x, bound.y)
  win.loadURL 'file://' + __dirname + '/../views/index.html'
  win.on 'closed', onClosed
  return win

###*
 Save bounds of main window to storage.
###
saveWindowBounds = (callback) ->
  return if not _mainWindow?
  bound = _mainWindow.getContentBounds()
  # console.log(bound)
  storage.set BOUND, bound, (err) ->
    if err
      console.log('Failed to set window bounds.')
    callback and callback()

###*
 Get bounds of main window from storage.
###
getWindowBounds = (callback) ->
  storage.get BOUND, (err, bound) ->
    # console.log(bound)
    if err
      console.log('Failed to get window bounds.')
    else
      _bound = bound
    callback and callback(bound)

# Create the Application's main menu
template = [{
    label: "Application",
    submenu: [
        { label: "About Application", selector: "orderFrontStandardAboutPanel:" },
        { type: "separator" },
        { label: "Quit", accelerator: "Command+Q", click: () -> app.quit() }
    ]}, {
    label: "Edit",
    submenu: [
        { label: "Undo", accelerator: "CmdOrCtrl+Z", selector: "undo:" },
        { label: "Redo", accelerator: "Shift+CmdOrCtrl+Z", selector: "redo:" },
        { type: "separator" },
        { label: "Cut", accelerator: "CmdOrCtrl+X", selector: "cut:" },
        { label: "Copy", accelerator: "CmdOrCtrl+C", selector: "copy:" },
        { label: "Paste", accelerator: "CmdOrCtrl+V", selector: "paste:" },
        { label: "Select All", accelerator: "CmdOrCtrl+A", selector: "selectAll:" }
    ]}
]

exports.openDevTools = () ->
  if _mainWindow?
    _mainWindow.webContents.openDevTools()

###*
 @callback onInputEndListener
 @param {object} auth - Login information
 @param {string} auth.username - Username.
 @param {string} auth.password - Login password.
###

###*
 @callback onLoginListener
 @param {onInputEndListener} func - Function which will be called when user inputted login information.
###

###*
 Set proxy login event lister.
 @param {onLoginListener} func - Function which will be called when fired app's 'login' event.
###
exports.onLogin = (func) ->
  _event[LOGIN] = func

