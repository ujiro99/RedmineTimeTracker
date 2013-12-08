# this directive depend in twitter bootstrap's collapse.js .

timeTracker.directive 'uzCollapse', () ->

  link: (scope, element, attrs) ->

    scope.$watch attrs.uzCollapse, (collapse, before) ->
      if collapse is before then return
      if collapse
        element.collapse('show')
      else
        element.collapse('hide')
