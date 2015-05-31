timeTracker.provider("State", (LogProvider) ->

  state =
    debug:       true
    logLevel:    LogProvider.Level.DEBUG
    isTracking:  false
    isAdding:    false
    isSaving:    false

  return {
    State: state
    $get: () -> return state
  }

)

