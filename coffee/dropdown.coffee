timeTracker.directive 'dropdown', () ->
  return {
    restrict: 'E'
    template: "<div class='dropdown'>" +
              "<span tabindex='0' class='dropdown-toggle'></span>" +
              "<div class='dropdown-text'>{{selected[0].text}}</div>" +
              "<ul class='dropdown-content'>" +
              "<li ng-repeat='item in items' ng-click='onClickItem(item)'>" +
              "<a><span>{{item.text}}</span></a>" +
              "</li></ul></div>"
    scope:
      items: '='
      selected: '='
    link: (scope, ele, attr) ->
      scope.onClickItem = (item) ->
        scope.selected[0] = item
  }
