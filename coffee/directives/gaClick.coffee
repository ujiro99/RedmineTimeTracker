timeTracker.directive 'gaClick', (Analytics) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', () ->
        Analytics.sendEvent 'user', 'clicked', attrs.gaClick
  }
