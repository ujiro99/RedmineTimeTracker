pf = 'electron'
if typeof chrome isnt "undefined" then pf = 'chrome'
timeTracker = angular.module('timeTracker',
  ['ui.bootstrap',
   'ui.timepicker',
   'ngRoute',
   'ngAnimate',
   'timer',
   'analytics',
   'siyfion.sfTypeahead',
   pf,
   'pascalprecht.translate'
  ])
