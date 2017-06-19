timeTracker.provider("State", (LogProvider) ->

  state =
    debug:             false
    log:               true
    logLevel:          LogProvider.Level.INFO
    title:             "RedmineTimeTracker"
    isAutoTracking:    false
    isPomodoring:      false
    isAddingAccount:   false
    isSaving:          false
    isLoadingAllData:  false  # flag for reload button.
    isLoadingIssue:    false
    isLoadingVisible:  true   # flag for issue loading icon.
    isCollapseSetting: true

  return {
    State: state
    $get: () -> return state
  }

)

