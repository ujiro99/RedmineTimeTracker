timeTracker.directive 'btnLoading', () ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.$watch attrs.btnLoading, (loading) ->
        if loading
          if not attrs.hasOwnProperty('ngDisabled')
            element.addClass('disabled').attr('disabled', 'disabled')
          element.data('reset-text', element.html())
          element.html(element.data('loading-text'))
        else
          if not attrs.hasOwnProperty('ngDisabled')
            element.removeClass('disabled').removeAttr('disabled')
          element.html(element.data('reset-text'))
  }
