timeTracker.directive 'uzPagination', ($window, $timeout) ->
  return {
    restrict: 'E'
    template: "<pagination class='pagination-small'" +
                          "boundary-links='true'" +
                          "total-items='totalItems'" +
                          "page='page'" +
                          "items-per-page='itemsPerPage'" +
                          "max-size='maxSize'" +
                          "previous-text='&lsaquo;'" +
                          "next-text='&rsaquo;'" +
                          "first-text='&laquo;'" +
                          "last-text='&raquo;'></pagination>"
    scope:
      page:         '='
      totalItems:   '='
      itemsPerPage: '='

    link: (scope, element, attrs) ->

      # minimum number of elements in the bar.
      MIN_SIZE = 4
      # default class name for animation.
      CLASS_NAME = "paging"
      # class name on animate.
      CLASS_NAME_ON_ANIMATE = "paging-active"

      # Limit number for pagination size.
      scope.maxSize = 1

      # width of all arrows
      arrowWidth = null

      # paging content's container
      container = null

      # container's animation duration [msec]
      duration = 0

      ###*
      # get element's duration.
      # @param {Dom Object} elem - target element
      # @return {Number} animation duration [msec]
      ###
      getTransitionDuration = (elem) ->
        t = elem.css("transition-duration")
        msec = /(\d*\.?\d+)ms$/
        sec = /(\d*\.?\d+)s$/
        matchs = msec.exec(t)
        if matchs then return matchs[1] - 0
        matchs = sec.exec(t)
        console.log(matchs)
        if matchs then return (matchs[1] - 0) * 1000

      ###*
      # animate container, and fix pagination bar's size.
      ###
      animate = () ->
        container.addClass(CLASS_NAME_ON_ANIMATE)
        $timeout () ->
          container.removeClass(CLASS_NAME_ON_ANIMATE)
        , duration
        fixSize()

      ###*
      # calculate pagination bar's size, and fix it.
      ###
      fixSize = () ->
        alist = element.find('a')
        if alist.length <= MIN_SIZE then return
        arrowWidth = arrowWidth or ($(alist[0]).outerWidth(true) + $(alist[1]).outerWidth(true)) * 2
        buttonWidth = 0
        wlist = for a in alist then $(a).outerWidth(true)
        buttonWidth = Math.max.apply({}, wlist)
        scope.maxSize = Math.floor((element.outerWidth() - arrowWidth) / buttonWidth)
        scope.maxSize = 1 if scope.maxSize < 1

      # initialize variables
      container = angular.element(attrs.container)
      container.addClass(CLASS_NAME)
      duration = getTransitionDuration(container)

      # resize pagination bar and fire animation.
      scope.$watch 'page', animate
      scope.$watch 'totalItems', fixSize
      angular.element($window).on 'resize', () ->
        scope.$apply fixSize
  }
