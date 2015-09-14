timeTracker.factory "Const", () ->

  obj =

    NULLFUNC:    ()->
    OPTIONS:     "OPTIONS"
    STARRED:     "Starred"
    SHOW:        { DEFAULT: 0, NOT: 1, SHOW: 2 }
    ISSUE_PROPS: ["status", "priority", "assignedTo", "tracker"]

  return obj

