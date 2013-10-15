var AnalyticsCode = 'UA-32234486-8';
var service = analytics.getService('RedmineTimeTracker');
var tracker = service.getTracker(AnalyticsCode);

/**
 * Track a click on a button using the asynchronous tracking API.
 */
function trackButtonClick(e) {
  tracker.sendEvent('ButtonClick', e.target.id, 'clicked');
}

/**
 * Set up your event handlers for `button` elements.
 */
document.addEventListener('DOMContentLoaded', function () {
  tracker.sendAppView(this.title);
  var buttons = document.querySelectorAll('button');
  for (var i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', trackButtonClick);
  }
});

