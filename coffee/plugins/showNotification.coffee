RTT.addPlugin("showNotification", {

  onSendedTimeEntry: (RTT, params...) ->
    console.log("onSendedTimeEntry")

})
