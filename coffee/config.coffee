timeTracker.config (LogProvider, StateProvider) ->
  if not StateProvider.State.debug
    console.dir StateProvider.State
  LogProvider.options.enable = StateProvider.State.debug
  LogProvider.options.level =  StateProvider.State.logLevel
