timeTracker.config (LogProvider, StateProvider) ->
  if not StateProvider.State.debug
    console.dir StateProvider.State
  LogProvider.options.enable = StateProvider.State.log
  LogProvider.options.level =  StateProvider.State.logLevel

timeTracker.config ($translateProvider) ->
  $translateProvider.useStaticFilesLoader({
    prefix: '../_locales/',
    suffix: '/messages.json'
  })
  lang = chrome.i18n.getUILanguage()
  console.log("Language: " + lang)
  $translateProvider.preferredLanguage(lang)
  $translateProvider.fallbackLanguage('en')
  $translateProvider.useSanitizeValueStrategy('escape')
