timeTracker.factory "Const", () ->

  obj =

    NULLFUNC:         ()->
    OPTIONS:          "OPTIONS"
    STARRED:          "Starred"
    SHOW:             { DEFAULT: 0, NOT: 1, SHOW: 2 }
    ISSUE_PROPS:      ["status", "priority", "assignedTo", "tracker"]
    OK:               200
    NOT_FOUND:        404
    UNAUTHORIZED:     401
    ACCESS_ERROR:     0
    URL_FORMAT_ERROR: -1
    TASK_TYPE:        { ISSUE: 1, PROJECT: 2 }

  return obj
