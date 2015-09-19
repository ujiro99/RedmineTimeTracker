timeTracker.directive 'uzHover', () ->
  return {
    restrict: 'A'
    scope: false
    link: (scope, element, attrs) ->

      element.on 'mouseenter', ->
        scope.$apply ->
          scope.$eval(attrs.uzHover + " = true")

      element.on 'mouseleave', ->
        scope.$apply ->
          scope.$eval(attrs.uzHover + " = false")

  }
