timeTracker.provider("State", (LogProvider) ->

  state =
    debug:          true
    log:            true
    logLevel:       LogProvider.Level.ALL
    isTracking:     false
    isAdding:       false
    isSaving:       false
    isLoadingIssue: false

  return {
    State: state
    $get: () -> return state
  }

)

