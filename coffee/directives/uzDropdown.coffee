timeTracker.directive 'uzDropdown', () ->
  return {
    restrict: 'E'
    template: "<div class='dropdown'>" +
              "<span tabindex='0' class='dropdown-toggle'></span>" +
              "<div class='dropdown-text'>{{$eval(selectedFormat)}}</div>" +
              "<div class='dropdown-box'><ul class='dropdown-content'>" +
              "<li ng-repeat='item in items' ng-click='selected[0] = item'>" +
              "<a><span>{{$eval($parent.format)}}</span></a>" +
              "</li></ul></div></div>"
    scope:
      items: '='
      selected: '='
    link: (scope, element, attrs) ->
      scope.format = attrs.format or "item.text"
      scope.selectedFormat = attrs.selectedFormat or "selected[0].text"
  }
