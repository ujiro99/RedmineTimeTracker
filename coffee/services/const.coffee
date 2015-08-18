timeTracker.factory "Const", () ->

  obj =

    NULLFUNC:    ()->
    OPTIONS:     "OPTIONS"
    STARRED:     "Starred"
    SHOW:        { DEFAULT: 0, NOT: 1, SHOW: 2 }

  return obj

