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

