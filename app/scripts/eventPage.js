chrome.app.runtime.onLaunched.addListener(function() {
  return chrome.app.window.create('/views/index.html', {
    'bounds': {
      'width': 250,
      'height': 550
    }
  });
});

/*
//@ sourceMappingURL=eventPage.js.map
*/