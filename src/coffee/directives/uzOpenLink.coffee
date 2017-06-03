timeTracker.directive 'uzOpenLink', (Platform) ->
  return {
    restrict: 'A'
    scope: {
      link: "=uzOpenLink"
    }
    link: (scope, element, attrs) ->
      isElectron = Platform.getPlarform() is 'electron'
      element.on 'click', () ->
        if isElectron
          Platform.openExternalLink(scope.link)
        else
          a = document.createElement('a')
          a.href = scope.link
          a.target='_blank'
          a.click()
  }
