describe 'util.coffee のテスト', ->

  describe 'getUrl', ->

    it "should be http://ujiroredmine.herokuapp.com", () ->

      url = util.getUrl("http://ujiroredmine.herokuapp.com/issues/1.json")
      expect(url).to.equal("http://ujiroredmine.herokuapp.com")
