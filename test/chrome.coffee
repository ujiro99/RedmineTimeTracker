angular.module('chrome', []).factory 'Chrome', () ->
  return {
    storage:
      local:
        get: () -> return true
        set: () -> return true
      sync:
        get: () -> return true
        set: () -> return true
    runtime:
      lastError: null
  }
