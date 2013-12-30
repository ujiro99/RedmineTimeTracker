timeTracker.directive 'uzPagination', ($window) ->

  MIN_SIZE = 4

  return {
    restrict: 'E'
    template: "<pagination class='pagination-small'" +
                          "boundary-links='true'" +
                          "total-items='totalItems'" +
                          "page='currentPage'" +
                          "items-per-page='itemsPerPage'" +
                          "max-size='maxSize'" +
                          "previous-text='&lsaquo;'" +
                          "next-text='&rsaquo;'" +
                          "first-text='&laquo;'" +
                          "last-text='&raquo;'></pagination>"

    scope:
      currentPage:  '='
      totalItems:   '='
      itemsPerPage: '='

    link: (scope, element, attrs) ->

      # Limit number for pagination size.
      scope.maxSize = 1

      # calculate pagination bar's size.
      calculateSize = () ->
        a = element.find('a')
        if a.length <= MIN_SIZE then return
        minWidth = ($(a[0]).outerWidth(true) + $(a[1]).outerWidth(true)) * 2
        buttonWidth = angular.element(a[a.length - 3]).outerWidth(true)
        scope.maxSize = Math.floor((element.outerWidth() - minWidth) / buttonWidth)
        scope.maxSize = 1 if scope.maxSize < 1

      # resize pagination bar
      scope.$watch 'currentPage', calculateSize
      scope.$watch 'totalItems', calculateSize
      angular.element($window).on 'resize', () ->
        scope.$apply calculateSize
  }
