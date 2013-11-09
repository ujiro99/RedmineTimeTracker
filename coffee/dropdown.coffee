timeTracker.directive 'dropdown', () ->
  return {
    restrict: 'E'
    template: "<div class='dropdown'>" +
              "<span tabindex='0' class='dropdown-toggle'></span>" +
              "<div class='dropdown-text'>{{selected[0].text}}</div>" +
              "<ul class='dropdown-content'>" +
              "<li ng-repeat='item in items' ng-click='selected[0] = item'>" +
              "<a><span>{{item.text}}</span></a>" +
              "</li></ul></div>"
    scope:
      items: '='
      selected: '='
  }
