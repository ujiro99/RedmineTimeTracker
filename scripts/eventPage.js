chrome.app.runtime.onLaunched.addListener(function() {
  return chrome.app.window.create('/views/index.html', {
    'bounds': {
      'width': 250,
      'height': 380
    }
  });
});

/*
//@ sourceMappingURL=eventPage.js.map
*/