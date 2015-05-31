timeTracker.provider("Log", () ->

  class Log

    methods = [
      'log', 'debug', 'info', 'warn', 'error', 'dir', 'trace',
      'assert', 'dirxml', 'group', 'groupEnd', 'time', 'timeEnd',
      'count', 'profile', 'profileEnd'
    ]

    bindMethod = (m) =>
      if console[m] and options.enable
        this::[m] = console[m].bind(console)
      else
        this::[m] = () -> return

    constructor: (@options) ->
      bindMethod(m) for m in methods

  options =
    enable: false

  return {
    options: options
    $get: () -> return new Log(options)
  }

)

