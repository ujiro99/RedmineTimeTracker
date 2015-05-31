timeTracker.config (LogProvider, StateProvider) ->
  console.dir StateProvider.State
  LogProvider.options.enable = StateProvider.State.debug
