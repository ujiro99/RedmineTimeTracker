chrome.app.runtime.onLaunched.addListener () -> 
  chrome.app.window.create '/views/timer.html',
    'bounds': { 'width': 280, 'height': 100 }
