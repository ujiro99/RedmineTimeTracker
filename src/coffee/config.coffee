timeTracker.config (LogProvider, StateProvider, PlatformProvider) ->
  if StateProvider.State.debug
    console.dir StateProvider.State
    PlatformProvider.openDevTools()
  LogProvider.options.enable = StateProvider.State.log
  LogProvider.options.level =  StateProvider.State.logLevel

timeTracker.config ($translateProvider, PlatformProvider) ->
  $translateProvider.useStaticFilesLoader({
    prefix: '../_locales/',
    suffix: '/messages.json'
  })
  lang = PlatformProvider.getLanguage()
  console.debug("Language: " + lang)
  $translateProvider.preferredLanguage(lang)
  $translateProvider.fallbackLanguage('en')
  $translateProvider.useSanitizeValueStrategy('escape')
