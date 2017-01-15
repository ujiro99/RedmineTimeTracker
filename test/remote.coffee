AppWindow = {
  show: () ->
}

remote = {
  app:
    getLocale: () -> return 'en'
  getCurrentWindow: () -> return AppWindow
  require: (path) -> return path
}

electron = {
  remote: remote
}
