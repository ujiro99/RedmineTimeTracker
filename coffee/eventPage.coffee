chrome.app.runtime.onLaunched.addListener () ->
  chrome.app.window.create '/views/index.html',
    'bounds': { 'width': 250, 'height': 380 }
