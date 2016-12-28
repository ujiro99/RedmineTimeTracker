if (this.MockPlugin == undefined) {

    class MockPlugin {

        sendTimeEntry(cb) {
            cb && cb();
        }

        sendedTimeEntry(cb) {
            cb && cb();
        }

    }

}
