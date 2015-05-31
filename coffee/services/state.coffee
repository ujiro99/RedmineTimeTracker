timeTracker.provider("State", () ->

  state =
    debug:       true
    isTracking:  false
    isAdding:    false
    isSaving:    false

  return {
    State: state
    $get: () -> return state
  }

)

