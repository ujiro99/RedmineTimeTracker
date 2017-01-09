'use strict'
{ app, BrowserWindow, Menu } = require('electron')
storage = require('electron-json-storage')

# adds debug features like hotkeys for triggering dev tools and reload
require('electron-debug')()

# prevent window being garbage collected
mainWindow = undefined

BOUND = "BOUND"
DEFAULT_BOUNDS = { width: 250, height: 550 }

_bound = {}

###*
 On closed listener.
###
onClosed = () ->
  # console.log('closed')
  # derefernece the window.
  mainWindow = null
  return

app.on 'window-all-closed', ->
  # console.log('window-all-closed')
  saveWindowBounds () ->
    if process.platform != 'darwin'
      app.quit()
  return

app.on 'activate', ->
  # console.log('activate')
  return if mainWindow
  getWindowBounds (bound) ->
    mainWindow = createMainWindow(bound)
  return

app.on 'ready', ->
  # console.log('ready')
  Menu.setApplicationMenu(Menu.buildFromTemplate(template))
  getWindowBounds (bound) ->
    mainWindow = createMainWindow(bound)
  return

# app.on 'will-finish-launching', ->
#   console.log('will-finish-launching')
#
# app.on 'before-quit', ->
#   console.log('before-quit')
#
# app.on 'will-quit', ->
#   console.log('will-quit')
#
# app.on 'quit', ->
#   console.log('quit')


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
  if bound.x? and bound.y?
    win.setPosition(bound.x, bound.y)
  win.loadURL 'file://' + __dirname + '/../views/index.html'
  win.on 'closed', onClosed
  return win

###*
 Save bounds of main window to storage.
###
saveWindowBounds = (callback) ->
  return if not mainWindow?
  bound = mainWindow.getContentBounds()
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
  if mainWindow?
    mainWindow.webContents.openDevTools()

