timeTracker.filter 'checked', () ->

  return (options) ->
    return [] if (not options) or (not options.length)
    return [options[0]] if options[0].checked
    return options.filter (o) -> o.checked

