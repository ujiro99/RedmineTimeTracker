timeTracker.factory "Resource", ($translate) ->

  return {

    string: (key, data) ->
      if Array.isArray(data)
        x = {}
        for a, i in data
          x["arg" + i] = a
        data = x
      else if Object.isObject(data)
        # nothing to do
      else
        data = { arg0: data }

      return $translate.instant(key + ".message", data)

  }
