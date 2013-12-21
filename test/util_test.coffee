expect = chai.expect

describe 'util.coffee', ->

  describe 'getUrl', ->

    dataset = [
      'http://redmine.com'
      'https://redmine.com'
      'http://redmine.com  '
      'http://redmine.com/'
      'http://redmine.com/redmine'
      'http://redmine.com/redmine/'
      'http://redmine.com?param=anyparameter'
    ]

    expects = [
      'http://redmine.com'
      'https://redmine.com'
      'http://redmine.com'
      'http://redmine.com'
      'http://redmine.com/redmine'
      'http://redmine.com/redmine'
      'http://redmine.com'
    ]

    for data, i in dataset
      e = expects[i]

      it data + " should be " + e, () ->
        url = util.getUrl(data)
        expect(url).to.equal(e)


  describe 'Object.equals', ->

    describe 'compare object', ->

      it "objA should be equals objB", () ->
        objA = {}
        objB = {}
        expect(util.equals objA, objB).to.be.true

      it "objA should be equals objB", () ->
        objA = {paramA: 1, paramB: "aaa", paramC: true}
        objB = {paramA: 1, paramB: "aaa", paramC: true}
        expect(util.equals objA, objB).to.be.true

      it "objA should not be equals objB", () ->
        objA = {paramA: 1, paramB: "aaa", paramC: true}
        objB = {paramA: 2, paramB: "aaa", paramC: true}
        expect(util.equals objA, objB).to.be.false

      it "objA should not be equals objB", () ->
        objA = {paramA: 1, paramB: "aaa", paramC: true}
        objB = {paramA: 1, paramB: "aab", paramC: true}
        expect(util.equals objA, objB).to.be.false

      it "objA should not be equals objB", () ->
        objA = {paramA: 1, paramB: "aaa", paramC: true}
        objB = {paramA: 1, paramB: "aaa", paramC: false}
        expect(util.equals objA, objB).to.be.false


    describe 'compare object in object', ->

      it "objA should be equals objB", () ->
        objA = {paramA: {paramB: "aaa", paramC: true}}
        objB = {paramA: {paramB: "aaa", paramC: true}}
        expect(util.equals objA, objB).to.be.true

      it "objA should not be equals objB", () ->
        objA = {paramA: {paramB: "aaa", paramC: true}}
        objB = {paramA: {paramB: "aab", paramC: true}}
        expect(util.equals objA, objB).to.be.false

    describe 'compare array', ->

      it "aryA should be equals aryB", () ->
        aryA = []
        aryB = []
        expect(util.equals aryA, aryB).to.be.true

      it "aryA should be equals aryB", () ->
        aryA = [0,1,2]
        aryB = [0,1,2]
        expect(util.equals aryA, aryB).to.be.true

      it "aryA should not be equals aryB", () ->
        aryA = [0,1,2]
        aryB = [0,1]
        expect(util.equals aryA, aryB).to.be.false

    describe 'compare array in object', ->

      it "aryA should be equals aryB", () ->
        aryA = {param: [0,1,2]}
        aryB = {param: [0,1,2]}
        expect(util.equals aryA, aryB).to.be.true

      it "aryA should be equals aryB", () ->
        aryA = {param: [0,1,2]}
        aryB = {param: [0,1,3]}
        expect(util.equals aryA, aryB).to.be.false

