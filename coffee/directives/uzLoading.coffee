timeTracker.directive 'uzLoading', () ->

  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      CLASS_LOADING = 'loading'
      CLASS_DISABLED = 'disabled'

      scope.$watch attrs.uzLoading, (loading) ->
        if loading
          element.addClass(CLASS_LOADING)
          if not attrs.hasOwnProperty('ngDisabled')
            element.addClass(CLASS_DISABLED)
        else
          element.removeClass(CLASS_LOADING)
          if not attrs.hasOwnProperty('ngDisabled')
            element.removeClass(CLASS_DISABLED)
  }
