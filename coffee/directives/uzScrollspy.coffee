timeTracker.directive "scrollSpy", ($window) ->
  restrict: "A"
  controller: ($scope) ->
    $scope.spies = []
    @addSpy = (spyObj) ->
      $scope.spies.push spyObj
    return

  link: (scope, elem, attrs) ->
    spyElems     = {}
    $scroller    = $(attrs.scroller or $window)
    $scrollDoc   = $(attrs.scrollDoc or $window)
    offsetTop    = attrs.offsetTop - 0 or 0
    offsetBottom = attrs.offsetBottom - 0 or 0

    # update spies
    _updateSpies = (spies) ->
      validSpies = []

      for spy in spies
        if spyElems[spy.id]?
          validSpies.push spy
          continue
        # catch case where a `spy` does not have an associated `id` anchor
        spyElem = $scroller.find("#" + spy.id)
        if spyElem.offset()?
          spyElems[spy.id] = spyElem
          validSpies.push spy

      scope.spies = validSpies


    # find target, and highlight it.
    _highlightSpy = () ->
      target = null

      # cycle through `spy` elements to find which to highlight
      for spy in scope.spies
        spy.out()
        top = spyElems[spy.id].offset().top
        buttom = top + spyElems[spy.id].height()
        if top <= offsetTop and buttom > offsetTop
          target = spy

      # select the last `spy` if the scrollbar is at the bottom of the page
      if $scroller.scrollTop() + $(window).height() >= $scrollDoc.height() + offsetBottom
        target = scope.spies[scope.spies.length - 1]

      target?.in()


    # assign events.
    scope.$watch("spies", _updateSpies, true)
    $scroller.scroll(_highlightSpy)


timeTracker.directive "spy", ($location, $anchorScroll, $timeout) ->
  restrict: "A"
  require: "^scrollSpy"
  link: (scope, elem, attrs, affix) ->

    elem.click () ->
      $location.hash attrs.spy
      $anchorScroll()

    # to wait ng-include, use timeout
    $timeout () ->
      affix.addSpy
        id: attrs.spy
        in: -> elem.addClass "active"
        out: -> elem.removeClass "active"
    , 100
