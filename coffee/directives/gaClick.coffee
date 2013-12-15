timeTracker.directive 'gaClick', (analytics) ->

  _button = {}

  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', () ->
        analytics.sendEvent 'user', 'clicked', attrs.gaClick
  }
