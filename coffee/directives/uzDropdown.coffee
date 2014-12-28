angular.module('uz', [])
  .directive 'uzDropdown', ($timeout) ->
    return {
      restrict: 'E'
      template: "<div class='dropdown'>" +
                "<input tabindex='0'" +
                       "class='dropdown-text dropdown-toggle'" +
                       "ng-model='keyword'" +
                       "ng-keydown='onKeydown($event.keyCode)'></input>" +
                "<div class='dropdown-box'><ul class='dropdown-content'>" +
                "<li ng-repeat='item in result = (items | filter:itemFilter)'" +
                    "ng-click='selected[0] = item' " +
                    "ng-class='{active: item === selected[0]}'>" +
                "<a><span>{{$eval($parent.format)}}</span></a>" +
                "</li>" +
                "</ul></div>"
                # "format: <span>{{format}}</span>" +
                # "keyword: <span>{{keyword}}</span>"
                # "result: <pre><code>{{result}}</code></pre>" +
                # "selected: <pre><code>{{selected[0]}}</code></pre>"
      scope:
        items: '='
        selected: '='
        itemFilter: '=filter'
      link: (scope, element, attrs) ->
        KEY_ENTER   = 13
        KEY_UP      = 38
        KEY_DOWN    = 40

        selectIndex = 0

        scope.format = attrs.format or "item.text"
        scope.keyword = ''
        scope.reslut = ''
        scope.selectedFormat = attrs.selectedFormat or "selected[0].text"
        scope.itemFilter = (item) ->
          return eval(scope.format).match(scope.keyword)
        scope.onKeydown = (keycode) ->
          if keycode is KEY_ENTER
            $timeout(() -> angular.element(element[0].querySelector(".dropdown-toggle"))[0].blur())
          else if keycode is KEY_DOWN then selectIndex++
          else if keycode is KEY_UP then selectIndex--

          if selectIndex < 0
            selectIndex = 0
          if selectIndex >= scope.result.length
            selectIndex = scope.result.length - 1

          scope.selected[0] = scope.result[selectIndex]

        element[0].querySelector(".dropdown-toggle").onblur = () ->
          scope.keyword = eval("scope." + scope.selectedFormat)
    }
