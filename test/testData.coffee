timeTracker.value "TestData", ()->

  SHOW = { DEFAULT: 0, NOT: 1, SHOW: 2 }

  return {

    prj1: [
      {
        url: "http://redmine.com"
        urlIndex: 0
        id: 0
        text: "prj1_0"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 1
        text: "prj1_1"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 2
        text: "prj1_2"
        show: SHOW.DEFAULT
      }
    ]

    prj2: [
      {
        url: "http://redmine.com2"
        urlIndex: 1
        id: 0
        text: "prj2_0"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com2"
        urlIndex: 1
        id: 1
        text: "prj2_1"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com2"
        urlIndex: 1
        id: 2
        text: "prj2_2"
        show: SHOW.DEFAULT
      }
    ]

    prj3: [
      {
        url: "http://redmine.com3"
        urlIndex: 2
        id: 0
        text: "prj3_0"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com3"
        urlIndex: 2
        id: 1
        text: "prj3_1"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com3"
        urlIndex: 2
        id: 2
        text: "prj3_2"
        show: SHOW.DEFAULT
      }
    ]

    prj10: [
      {
        url: "http://redmine.com"
        urlIndex: 0
        id: 0
        text: "prj1_0"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 1
        text: "prj1_1"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 2
        text: "prj1_2"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 3
        text: "prj1_3"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 4
        text: "prj1_4"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 5
        text: "prj1_5"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 6
        text: "prj1_6"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 7
        text: "prj1_7"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 8
        text: "prj1_8"
        show: SHOW.DEFAULT
      }, {
        url: "http://redmine.com"
        urlIndex: 0
        id: 9
        text: "prj1_9"
        show: SHOW.DEFAULT
      }
    ]

    prjObj:
      "http://redmine.com" :
        index: 0
        0:
          text: "prj1_0"
          show: SHOW.DEFAULT
      "http://redmine.com2" :
        index: 1
        0:
          text: "prj2_0"
          show: SHOW.DEFAULT
      "http://redmine.com3" :
        index: 2
        0:
          text: "prj3_0"
          show: SHOW.DEFAULT

    prjOldFormat:                                     # version <= 0.5.7
      "http://redmine.com" :
        index: 2
        0:
          text: "prj1_0"
          show: SHOW.DEFAULT
      "http://redmine.com2" :
        index: 3
        0:
          text: "prj2_0"
          show: SHOW.DEFAULT
      "http://redmine.com3" :
        index: 4
        0:
          text: "prj3_0"
          show: SHOW.DEFAULT

    ticketList: [
      {
        id: 0,
        text: "ticket0",
        url: "http://redmine.com",
        project:
          id: 0
          text: "prj1_0",
        show: SHOW.DEFAULT
      }, {
        id: 1,
        text: "ticket1",
        url: "http://redmine.com",
        project:
          id: 0
          text: "prj1_0",
        show: SHOW.NOT
      }, {
        id: 2,
        text: "ticket2",
        url: "http://redmine.com",
        project:
          id: 0
          text: "prj1_0",
        show: SHOW.SHOW
      }
    ]

    ticketList2: [
      {
        id: 0,
        text: "ticket0",
        url: "http://redmine.com",
        project:
          id: 0
          text: "prj1_0",
        show: SHOW.DEFAULT
      }, {
        id: 0,
        text: "ticket2",
        url: "http://redmine.com2",
        project:
          id: 0
          text: "prj2_0",
        show: SHOW.NOT
      }, {
        id: 0,
        text: "ticket3",
        url: "http://redmine.com3",
        project:
          id: 0
          text: "prj3_0",
        show: SHOW.SHOW
      }
    ]

    ticketOnChrome: [
      # id | text      | url_index | prj_id |    show
      [ 0,  "ticket0",      0,         0,     SHOW.DEFAULT ],
      [ 0,  "ticket2",      1,         0,     SHOW.NOT     ],
      [ 0,  "ticket3",      2,         0,     SHOW.SHOW    ]
    ]

    ticketOnChromeOld: [
      # id | text      | url_index | prj_id |    show
      [ 0,  "ticket0",      2,         0,     SHOW.DEFAULT ],
      [ 0,  "ticket2",      3,         0,     SHOW.NOT     ],
      [ 0,  "ticket3",      4,         0,     SHOW.SHOW    ]
    ]

    queries: {
      "queries": [{"id":0, "name":"aaa", "is_public":true}, {"id":2, "name":"bbb"}]
      "total_count":2
      "offset":0
      "limit":25
    }

    user: {
      "user":{
        "id":1
        "login":"admin"
        "firstname":"Redmine"
        "lastname":"Admin"
        "mail":"test@gmail.com"
        "created_on":"2013-08-22T14:24:27Z"
      }
    }

    time_entries: {
      "time_entries":[{"id":1097,"project":{"id":9,"name":"その他"},"issue":{"id":235},"user":{"id":3,"name":"yujiro takeda"},"activity":{"id":8,"name":"設計作業"},"hours":1.25,"comments":"スケジュール修正","spent_on":"2014-07-03","created_on":"2014-07-03T13:32:56Z","updated_on":"2014-07-03T13:32:56Z"},{"id":1096,"project":{"id":9,"name":"その他"},"issue":{"id":235},"user":{"id":3,"name":"yujiro takeda"},"activity":{"id":8,"name":"設計作業"},"hours":1.25,"comments":"メール送信","spent_on":"2014-07-03","created_on":"2014-07-03T11:25:00Z","updated_on":"2014-07-03T11:25:00Z"}]
      "total_count":2
      "offset":0
      "limit":25
    }

    statuses: [
      {
        id: 1
        name: "New"
        is_default: true
        is_closed: false
      }, {
        id: 2
        name: "Closed"
        is_default: false
        is_closed: true
      }
    ]

  }
