(function() {
  $(function() {
    var openTimer;

    $(document).ready(function() {
      return $("#buttonLogin").click(openTimer);
    });
    return openTimer = function() {
      return chrome.windows.create({
        url: "/views/timer.html",
        type: "popup",
        width: 300,
        height: 200
      }, function(window) {
        return console.log("open timer");
      });
    };
  });

}).call(this);
