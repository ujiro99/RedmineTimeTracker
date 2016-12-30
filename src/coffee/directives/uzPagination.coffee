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
      currentPage:  '='
      totalItems:   '='
      itemsPerPage: '='

    link: (scope, element, attrs) ->

      # minimum number of elements in the bar.
      MIN_SIZE = 4
      # default class name for animation.
      CLASS_NAME = "paging"
      # on animate.
      CLASS_NAME_ON_ANIMATE = "paging-active"
      # on paging to left.
      CLASS_NAME_PAGING_TO_LEFT = "paging-left"
      # on paging to right.
      CLASS_NAME_PAGING_TO_RIGHT = "paging-right"
      # If pagination is omitted, stretch width.
      CLASS_NAME_STRETCH = "pagination--stretch"
      # element enter.
      CLASS_ENTER = ".ng-enter"

      # Limit number for pagination size.
      scope.maxSize = 1
      # width of all arrows
      arrowWidth = null
      # paging content's container
      container = null
      # container's animation duration [msec]
      duration = 0
      # how many times starting animate.
      animateCount = 0

      ###*
      # get element's duration.
      # @param {Object} elem - Dom object of target element.
      # @return {Number} animation duration [msec]
      ###
      getTransitionDuration = (elem) ->
        t = elem.css("transition-duration")
        msec = /(\d*\.?\d+)ms$/
        sec = /(\d*\.?\d+)s$/
        matchs = msec.exec(t)
        if matchs then return matchs[1] - 0
        matchs = sec.exec(t)
        if matchs then return (matchs[1] - 0) * 1000

      ###*
      # animate container, and fix pagination bar's size.
      ###
      animate = (newPage, oldPage) ->
        if newPage > oldPage
          direction = CLASS_NAME_PAGING_TO_LEFT
        else
          direction = CLASS_NAME_PAGING_TO_RIGHT
        animateCount++
        container.addClass(CLASS_NAME_ON_ANIMATE)
        container.addClass(direction)
        clearAnimate(direction, duration)
        scope.currentPage = newPage
        fixSize()

      ###*
      # Clear animate if animation finished.
      ###
      clearAnimate = (direction, delay) ->
        $timeout () ->
          animateCount--
          if animateCount isnt 0 then return
          if container.find(CLASS_ENTER).length is 0
            container.removeClass(direction)
            container.removeClass(CLASS_NAME_ON_ANIMATE)
          else
            # animation is working yet, retry.
            animateCount++
            clearAnimate(direction, 100)
        , delay

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
        pagination = angular.element(element.find('.pagination')[0])
        if scope.maxSize < scope.totalItems / scope.itemsPerPage
          pagination.addClass(CLASS_NAME_STRETCH)
        else
          pagination.removeClass(CLASS_NAME_STRETCH)

      # initialize variables
      container = angular.element(attrs.container)
      container.addClass(CLASS_NAME)
      duration = getTransitionDuration(container)
      scope.page = scope.currentPage

      # resize pagination bar and fire animation.
      scope.$watch 'page', animate
      scope.$watch 'totalItems', fixSize
      angular.element($window).on 'resize', () ->
        scope.$apply fixSize
  }
