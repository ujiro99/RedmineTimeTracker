'use strict'
electron = require('electron')
storage = require('electron-json-storage')
app = electron.app

# adds debug features like hotkeys for triggering dev tools and reload
require('electron-debug')()

# prevent window being garbage collected
mainWindow = undefined

###*
 On closed listener.
###
onClosed = () ->
  # derefernece the window.
  mainWindow = null
  return

createMainWindow = ->
  win = new (electron.BrowserWindow)({
    width: 600
    height: 400
  })
  win.loadURL 'file://' + __dirname + '/../views/index.html'
  win.webContents.openDevTools()
  win.on 'closed', onClosed
  return win

app.on 'window-all-closed', ->
  if process.platform != 'darwin'
    app.quit()
  return

app.on 'activate', ->
  if !mainWindow
    mainWindow = createMainWindow()
  return

app.on 'ready', ->
  mainWindow = createMainWindow()
  return
