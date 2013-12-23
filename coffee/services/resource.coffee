timeTracker.factory "Resource", () ->

  return {

    string: (key) ->
      return chrome.i18n.getMessage key

  }
