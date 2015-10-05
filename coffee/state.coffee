timeTracker.provider("State", (LogProvider) ->

  state =
    debug:          false
    log:            true
    logLevel:       LogProvider.Level.INFO
    isTracking:     false
    isAdding:       false
    isSaving:       false
    isLoadingIssue: false

  return {
    State: state
    $get: () -> return state
  }

)

