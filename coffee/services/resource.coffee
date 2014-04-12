timeTracker.factory "Resource", (Chrome) ->

  return {

    string: (key) ->
      return Chrome.i18n.getMessage key

  }
