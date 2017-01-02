AppWindow = {
  show: () ->
}

remote = {
  app:
    getLocale: () -> return 'en'
  getCurrentWindow: () -> return AppWindow
}

electron = {
  remote: remote
}
