timeTracker.directive 'uzFocus', ($timeout) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      # find element. if not find, don't works focus.
      elem = document.querySelector(attrs.uzFocus)
      return if not elem

      element.on "click", () ->
        # wait fo animattion.
        $timeout((() -> elem.focus()), 200)

  }
