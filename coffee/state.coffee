timeTracker.provider("State", (LogProvider) ->

  state =
    debug:             false
    log:               true
    logLevel:          LogProvider.Level.ALL
    title:             ""
    isTracking:        false
    isAdding:          false
    isSaving:          false
    isLoadingIssue:    false
    isCollapseSetting: true

  return {
    State: state
    $get: () -> return state
  }

)

