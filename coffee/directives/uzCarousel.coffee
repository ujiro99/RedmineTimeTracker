timeTracker.directive 'uzCarousel', ($window, $timeout) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      # default class name for animation.
      CLASS_NAME = "carousel"
      # on animate.
      CLASS_NAME_ON_ANIMATE = CLASS_NAME + "-active"
      # on animate to left.
      CLASS_NAME_TO_LEFT    = CLASS_NAME + "-to-left"
      # on animate to rignt.
      CLASS_NAME_TO_RIGHT   = CLASS_NAME + "-to-right"

      # paging content's container
      container = null
      # container's animation duration [msec]
      duration = 0
      # animation state
      isAnimating = false
      # direction of current animation
      preDirection = 0
      # promise of current animation
      prePromise = null

      ###*
      # get element's duration.
      # @param {Dom Object} elem - target element
      # @return {Number} animation duration [msec]
      ###
      getTransitionDuration = (elem) ->
        t = elem.css("transition-duration")
        re_msec = /(\d*\.?\d+)ms$/
        re_sec = /(\d*\.?\d+)s$/
        matchs = re_msec.exec(t)
        if matchs then return matchs[1] - 0
        matchs = re_sec.exec(t)
        if matchs then return (matchs[1] - 0) * 1000

      ###*
      # start animate container
      # @param {Number} direction - to left  : x  > 0
      #                             to right : x =< 0
      ###
      animateEnter = (direction) ->
        if direction > 0
          classDirection = CLASS_NAME_TO_LEFT
        else
          classDirection = CLASS_NAME_TO_RIGHT
        isAnimating = true
        container.addClass(CLASS_NAME_ON_ANIMATE)
        container.addClass(classDirection)
        return $timeout () ->
          animateExit(direction)
        , duration

      ###*
      # finish animation
      # @param {Number} direction - to left  : x  > 0
      #                             to right : x =< 0
      ###
      animateExit = (direction) ->
        if direction > 0
          classDirection = CLASS_NAME_TO_LEFT
        else
          classDirection = CLASS_NAME_TO_RIGHT
        container.removeClass(CLASS_NAME_ON_ANIMATE)
        container.removeClass(classDirection)
        isAnimating = false

      # initialize variables
      container = angular.element(attrs.container)
      container.addClass(CLASS_NAME)
      duration = getTransitionDuration(container)
      console.log(duration)

      # start animation on click.
      element.on 'click', (e) ->
        if isAnimating # exit current animation
          $timeout.cancel(prePromise)
          animateExit(preDirection)
        xCenter = e.view.outerWidth / 2
        preDirection = e.screenX - xCenter
        prePromise = animateEnter(preDirection)
  }
