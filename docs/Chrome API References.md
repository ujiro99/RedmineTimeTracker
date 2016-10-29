# Chrome API References

|  no | file name | line | code | program | api | instance | instance method |
|  ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
|  1 | README.md | 9 | [Redmine Time Tracker on Chrome web Store](https://chrome.google.com/webstore/detail/redmine-time-tracker/dmmneannhefdfnmkfheapickfaialefp?utm_source=chrome-ntp-launcher) | no | meta |  |  |
|  2 | test/project_test.coffee | 33 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  3 | test/project_test.coffee | 62 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  4 | test/project_test.coffee | 74 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  5 | test/project_test.coffee | 78 | Chrome.storage.sync.get = (arg1, callback) -> | no | test |  |  |
|  6 | test/project_test.coffee | 91 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  7 | test/project_test.coffee | 95 | Chrome.storage.sync.get = (arg1, callback) -> | no | test |  |  |
|  8 | test/project_test.coffee | 109 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  9 | test/project_test.coffee | 112 | Chrome.runtime.lastError = true | no | test |  |  |
|  10 | test/project_test.coffee | 114 | Chrome.storage.sync.get = (arg1, callback) -> | no | test |  |  |
|  11 | test/project_test.coffee | 125 | Chrome.runtime.lastError = null | no | test |  |  |
|  12 | test/project_test.coffee | 131 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  13 | test/project_test.coffee | 156 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  14 | test/project_test.coffee | 169 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  15 | test/project_test.coffee | 180 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  16 | test/project_test.coffee | 191 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  17 | test/project_test.coffee | 203 | Chrome.storage.local.set = (arg, callback) -> | no | test |  |  |
|  18 | app/_locales/pl/messages.json | 4 | description: "Nazwa rozszerzenia google chrome." | no | none |  |  |
|  19 | test/ticket_test.coffee | 36 | Chrome.runtime.lastError = null # fix state. | no | test |  |  |
|  20 | test/ticket_test.coffee | 37 | Chrome.storage.local.set = (arg, callback) -> | no | test |  |  |
|  21 | test/ticket_test.coffee | 41 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  22 | test/ticket_test.coffee | 45 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  23 | test/ticket_test.coffee | 49 | Chrome.storage.sync.get = (arg1, callback) -> | no | test |  |  |
|  24 | test/ticket_test.coffee | 57 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  25 | test/ticket_test.coffee | 68 | it 'shuld return error message of Chrome.', (done) -> | no | test |  |  |
|  26 | test/ticket_test.coffee | 70 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  27 | test/ticket_test.coffee | 72 | Chrome.runtime.lastError = true | no | test |  |  |
|  28 | test/ticket_test.coffee | 92 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  29 | test/ticket_test.coffee | 125 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  30 | test/ticket_test.coffee | 168 | Chrome.storage.sync.set = (arg, callback) -> | no | test |  |  |
|  31 | test/ticket_test.coffee | 186 | Chrome.storage.local.get = (arg, callback) -> | no | test |  |  |
|  32 | test/ticket_test.coffee | 217 | Chrome.storage.local.get = getData | no | test |  |  |
|  33 | test/ticket_test.coffee | 218 | Chrome.storage.sync.get = getData | no | test |  |  |
|  34 | test/ticket_test.coffee | 228 | Chrome.storage.local.get = (arg, callback) -> | no | test |  |  |
|  35 | test/ticket_test.coffee | 231 | callback TICKET: TestData.ticketOnChrome.add [[ 0, "ticket4", 3, 0, SHOW.SHOW]] | no | test |  |  |
|  36 | test/ticket_test.coffee | 248 | Chrome.storage.local.get = (arg1, callback) -> | no | test |  |  |
|  37 | src/coffee/chromereload.coffee | 17 | if data and data.command == 'reload' then chrome.runtime.reload() | yes | runtime.reload |  |  |
|  38 | src/coffee/controllers/mainCtrl.coffee | 114 | # update settings specified by user, using saved data on chrome. | no | comment |  |  |
|  39 | src/coffee/controllers/mainCtrl.coffee | 284 | Chrome.load(Chrome.SELECTED_PROJECT)) | yes | storage.get |  |  |
|  40 | src/coffee/controllers/mainCtrl.coffee | 314 | Chrome.alarms.create(DATA_SYNC, alarmInfo) | yes | alarms |  |  |
|  41 | src/coffee/controllers/mainCtrl.coffee | 315 | Chrome.alarms.onAlarm.addListener (alarm) -> | yes | alarms |  |  |
|  42 | src/coffee/controllers/mainCtrl.coffee | 329 | Chrome.save(Chrome.SELECTED_PROJECT, obj) | yes | storage.set |  |  |
|  43 | src/coffee/eventPage.coffee | 12 | chrome.runtime.onInstalled.addListener(@sendInstalledEvent) | yes | runtime.onInstalled |  |  |
|  44 | src/coffee/eventPage.coffee | 13 | chrome.app.runtime.onLaunched.addListener(@openWindow) | yes | app.runtime.onLaunched |  |  |
|  45 | src/coffee/eventPage.coffee | 20 | chrome.storage.local.get RedmineTimeTracker.BOUND, (bounds) -> | yes | storage.get |  |  |
|  46 | src/coffee/eventPage.coffee | 27 | chrome.app.window.create RedmineTimeTracker.URL, windowOptions, () -> | yes | window.create |  |  |
|  47 | src/coffee/eventPage.coffee | 30 | chrome.app.window.get(RedmineTimeTracker.ID).onClosed.addListener () -> | yes | window.onClosed |  |  |
|  48 | src/coffee/eventPage.coffee | 31 | innerBounds = chrome.app.window.get(RedmineTimeTracker.ID).innerBounds | yes | innerBounds | yes | innerBounds.top   <br/>innerBounds.left  <br/>innerBounds.height<br/>innerBounds.width  |
|  49 | src/coffee/eventPage.coffee | 37 | chrome.storage.local.set { BOUND: bounds } | yes | storage.set |  |  |
|  50 | src/coffee/plugins/notification.coffee | 24 | @_Chrome.notifications.onClicked.addListener (notificationId) => | yes | notification |  |  |
|  51 | src/coffee/plugins/notification.coffee | 25 | @_Chrome.notifications.clear(notificationId) | yes | notification |  |  |
|  52 | src/coffee/plugins/notification.coffee | 56 | @_Chrome.notifications.create(null, options) | yes | notification |  |  |
|  53 | src/coffee/plugins/notification.coffee | 63 | currentWindow = @_Chrome.app.window.current() | yes | window.current | yes | currentWindow.show() |
|  54 | src/coffee/services/account.coffee | 110 | decrypt the account data, only to sync on chrome. | no | comment |  |  |
|  55 | src/coffee/services/account.coffee | 124 | encrypt the account data, only to sync on chrome. | no | comment |  |  |
|  56 | src/coffee/services/account.coffee | 176 | Chrome.storage.sync.get ACCOUNTS, (item) -> | yes | storage.get |  |  |
|  57 | src/coffee/services/account.coffee | 177 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  58 | src/coffee/services/account.coffee | 215 | Chrome.storage.sync.set ACCOUNTS: accounts, () -> | yes | storage.set |  |  |
|  59 | src/coffee/services/account.coffee | 216 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  60 | src/coffee/services/account.coffee | 238 | Chrome.storage.sync.set ACCOUNTS: accounts, () -> | yes | storage.set |  |  |
|  61 | src/coffee/services/account.coffee | 239 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  62 | src/coffee/services/account.coffee | 255 | Chrome.storage.local.clear() | yes | storage.clear |  |  |
|  63 | src/coffee/services/account.coffee | 256 | Chrome.storage.sync.clear () -> | yes | storage.clear |  |  |
|  64 | src/coffee/services/account.coffee | 257 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  65 | src/coffee/services/chrome.coffee | 13 | @param storage  {Object}   Storage area on chrome. | no | comment |  |  |
|  66 | src/coffee/services/chrome.coffee | 21 | if chrome.runtime.lastError? then callback(null); return | yes | runtime.lastError |  |  |
|  67 | src/coffee/services/chrome.coffee | 27 | @param storage  {Object}   Storage area on chrome. | no | comment |  |  |
|  68 | src/coffee/services/chrome.coffee | 38 | if chrome.runtime.lastError? then callback(false); return | yes | runtime.lastError |  |  |
|  69 | src/coffee/services/chrome.coffee | 47 | @_load chrome.storage.local, key, (local) => | yes | storage.get |  |  |
|  70 | src/coffee/services/chrome.coffee | 53 | @_load chrome.storage.sync, key, (sync) => | yes | storage.get |  |  |
|  71 | src/coffee/services/chrome.coffee | 54 | if chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  72 | src/coffee/services/chrome.coffee | 69 | @_save chrome.storage.local, key, value, (res) => | yes | storage.set |  |  |
|  73 | src/coffee/services/chrome.coffee | 74 | @_save chrome.storage.sync, key, value, (res) => | yes | storage.set |  |  |
|  74 | src/coffee/services/option.coffee | 54 | Chrome.storage.sync.get Const.OPTIONS, (item) -> | yes | storage.get |  |  |
|  75 | src/coffee/services/option.coffee | 55 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  76 | src/coffee/services/option.coffee | 74 | Chrome.storage.sync.set saveData, () -> | yes | storage.set |  |  |
|  77 | src/coffee/services/option.coffee | 75 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  78 | src/coffee/services/option.coffee | 91 | Chrome.storage.local.clear() | yes | storage.clear |  |  |
|  79 | src/coffee/services/option.coffee | 92 | Chrome.storage.sync.clear () -> | yes | storage.clear |  |  |
|  80 | src/coffee/services/option.coffee | 93 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  81 | src/coffee/services/project.coffee | 15 | @param urlIndex {Number} project id's index on Chrome.storage. | no | comment |  |  |
|  82 | src/coffee/services/project.coffee | 114 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  83 | src/coffee/services/project.coffee | 122 | convert projects to format of chrome. all projects are unique. | no | comment |  |  |
|  84 | src/coffee/services/project.coffee | 168 | return Chrome.load(Project.PROJECT) | yes | storage.get |  |  |
|  85 | src/coffee/services/project.coffee | 186 | @_sync(projects, Chrome.storage.sync) | no | comment |  |  |
|  86 | src/coffee/services/project.coffee | 201 | @_sync(projects, Chrome.storage.local) | no | comment |  |  |
|  87 | src/coffee/services/resource.coffee | 6 | return Chrome.i18n.getMessage key | yes | i18n |  |  |
|  88 | src/coffee/services/ticket.coffee | 124 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  89 | src/coffee/services/ticket.coffee | 125 | deferred.reject({message: "Chrome.runtime error."}) | no | none |  |  |
|  90 | src/coffee/services/ticket.coffee | 154 | return Chrome.load(TICKET) | yes | storage.get |  |  |
|  91 | src/coffee/services/ticket.coffee | 176 | _sync(tickets, Chrome.storage.sync) | yes | storage.set |  |  |
|  92 | src/coffee/services/ticket.coffee | 191 | _sync tickets, Chrome.storage.local | yes | storage.set |  |  |
|  93 | src/coffee/services/ticket.coffee | 216 | Chrome.storage.local.set TICKET: [] | yes | storage.set |  |  |
|  94 | src/coffee/services/ticket.coffee | 217 | Chrome.storage.sync.set TICKET: [], () -> | yes | storage.set |  |  |
|  95 | src/coffee/services/ticket.coffee | 218 | if Chrome.runtime.lastError? | yes | runtime.lastError |  |  |
|  96 | src/jade/index.jade | 69 | script(src='../scripts/services/chrome.js') | no | none |  |  |


# Alternative Api

|  **no.** | **Chrome API** | **Alt API** |
|  :------: | :------: | :------: |
|  1 | alarms | setTimeout |
|  2 | app.runtime.onLaunched | app#Event: ‘will-finish-launching’ |
|  3 | i18n | angular.i18n |
|  4 | innerBounds | win.getContentBounds() |
|  5 | notification | Notification API |
|  6 | runtime.lastError | - |
|  7 | runtime.onInstalled | - |
|  8 | runtime.reload | app.relaunch([options]) |
|  9 | storage.clear | electron-json-storage |
|  10 | storage.get | electron-json-storage |
|  11 | storage.set | electron-json-storage |
|  12 | window.create | new BrowserWindow() |
|  13 | window.current | BrowserWindow.fromId(id) |
|  14 | window.onClosed | app#Event: ‘window-all-closed’ |
