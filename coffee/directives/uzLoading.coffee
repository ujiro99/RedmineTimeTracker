timeTracker.directive 'uzLoading', () ->

  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      _button = Ladda.create(element[0])

      scope.$watch attrs.uzLoading, (loading) ->
        if loading
          _button.start()
          # element.addClass('loading')
          # if not attrs.hasOwnProperty('ngDisabled')
          #   element.addClass('disabled').attr('disabled', 'disabled')
          # element.data('reset-text', element.html())
          # element.html(element.data('loading-text'))
        else
          _button.stop()
          # element.removeClass('loading')
          # if not attrs.hasOwnProperty('ngDisabled')
          #   element.removeClass('disabled').removeAttr('disabled')
          # element.html(element.data('reset-text'))
  }
