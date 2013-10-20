chrome.app.runtime.onLaunched.addListener () ->
  chrome.app.window.create '/views/index.html',
    'bounds': { 'width': 280, 'height': 100 }
