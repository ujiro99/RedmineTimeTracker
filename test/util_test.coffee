expect = chai.expect

describe 'util.coffee', ->

  describe 'getUrl', ->

    it "'http://redmine.com' should be 'http://redmine.com'", () ->
      url = util.getUrl("http://redmine.com")
      expect(url).to.equal("http://redmine.com")


    it "'https://redmine.com' should be 'https://redmine.com'", () ->
      url = util.getUrl("https://redmine.com")
      expect(url).to.equal("https://redmine.com")


    it "'http://redmine.com  ' should be 'http://redmine.com'", () ->
      url = util.getUrl("http://redmine.com  ")
      expect(url).to.equal("http://redmine.com")


    it "'http://redmine.com/' should be 'http://redmine.com'", () ->
      url = util.getUrl("http://redmine.com/")
      expect(url).to.equal("http://redmine.com")


    it "'http://redmine.com/redmine' should be 'http://redmine.com/redmine'", () ->
      url = util.getUrl("http://redmine.com/redmine")
      expect(url).to.equal("http://redmine.com/redmine")


    it "'http://redmine.com/redmine/' should be 'http://redmine.com/redmine'", () ->
      url = util.getUrl("http://redmine.com/redmine/")
      expect(url).to.equal("http://redmine.com/redmine")

