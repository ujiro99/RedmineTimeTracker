timeTracker.directive 'uzAutoHeight', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->

    _maximize = () ->
      elems = element.children(attrs.uzAutoHeight)
      heights = for e in elems then e.offsetHeight
      height = Math.max.apply {}, heights
      element.height(height)

    _listner = () -> element.find('*').length

    scope.$watch _listner, (after, before) ->
      return if after is before
      # for animation
      $timeout _maximize, 10
      $timeout _maximize, 400
