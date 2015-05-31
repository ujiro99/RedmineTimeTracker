timeTracker.provider("Log", () ->

  class Log

    @LogLevel:
      ALL:    -99
      DEBUG:   -1
      INFO:     0
      WARN:     1
      ERROR:    2
      OFF:     99

    methods = [
      {name: 'log',             level:  Log.LogLevel.INFO}
      {name: 'debug',           level:  Log.LogLevel.DEBUG}
      {name: 'info',            level:  Log.LogLevel.INFO}
      {name: 'warn',            level:  Log.LogLevel.WARN}
      {name: 'error',           level:  Log.LogLevel.ERROR}
      {name: 'dir',             level:  Log.LogLevel.INFO}
      {name: 'trace',           level:  Log.LogLevel.INFO}
      {name: 'assert',          level:  Log.LogLevel.INFO}
      {name: 'dirxml',          level:  Log.LogLevel.INFO}
      {name: 'group',           level:  Log.LogLevel.ERROR}
      {name: 'groupCollapsed',  level:  Log.LogLevel.ERROR}
      {name: 'groupEnd',        level:  Log.LogLevel.ERROR}
      {name: 'time',            level:  Log.LogLevel.ALL}
      {name: 'timeEnd',         level:  Log.LogLevel.ALL}
      {name: 'count',           level:  Log.LogLevel.ALL}
      {name: 'profile',         level:  Log.LogLevel.ALL}
      {name: 'profileEnd',      level:  Log.LogLevel.ALL}
    ]

    bindMethod = (obj, enable, level) =>
      if console[obj.name] and enable and obj.level >= level
        this::[obj.name] = console[obj.name].bind(console)
      else
        this::[obj.name] = () -> return

    constructor: (options) ->
      for obj in methods
        bindMethod(obj, options.enable, options.level)

  options =
    enable: false
    level: Log.LogLevel.OFF

  return {
    options: options
    Level: Log.LogLevel
    $get: () -> return new Log(options)
  }

)

