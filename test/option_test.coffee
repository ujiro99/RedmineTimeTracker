expect = chai.expect

describe 'option.coffee', ->

  Option = null

  DEFAULT_OPTION =
    reportUsage: true
    isProjectStarEnable: true
    removeClosedTicket: true
    itemsPerPage: 20


  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_Option_) ->
      Option = _Option_


  describe 'getOptions()', ->

    it 'returns default properties.', () ->
      obj = Option.getOptions()
      for key, value of DEFAULT_OPTION
        expect(obj).to.have.property(key)

    it 'returns changed property.', () ->
      obj = Option.getOptions()
      obj.reportUsage = false
      obj = Option.getOptions()
      expect(obj.reportUsage).to.equal(false)


  describe 'onChanged', ->

    it 'calls changed callback.', (done) ->
      Option.onChanged (e) ->
        expect(e.object.reportUsage).to.equals(false)
        done()
      expect(Option.getOptions().reportUsage).to.equals(true)
      Option.getOptions().reportUsage = false

    it 'calls changed 2 callbacas.', (done) ->
      Option.onChanged (e) ->
        expect(e.object.reportUsage).to.equals(false)
      Option.onChanged (e) ->
        expect(e.object.isProjectStarEnable).to.equals(true)
        done()
      o = Option.getOptions()
      o.reportUsage = false
      o.isProjectStarEnable = true

    it 'calls changed callback only specified key.', (done) ->
      Option.getOptions().isProjectStarEnable = true
      Option.onChanged 'isProjectStarEnable', (e) ->
        expect(e).to.equals(false)
        done()
      Option.getOptions().isProjectStarEnable = false

    it 'calls changed callback only 2 specified key.', (done) ->
      Option.getOptions().isProjectStarEnable = true
      Option.onChanged 'reportUsage', (e) ->
        expect(e).to.equals(false)
      Option.onChanged 'isProjectStarEnable', (e) ->
        expect(e).to.equals(false)
        done()
      o = Option.getOptions()
      o.reportUsage = false
      o.isProjectStarEnable = false

    it 'null check.', () ->
      Option.getOptions().reportUsage = false
      expect(Option.getOptions().reportUsage).to.equals(false)

  ###
   loadOptions: () ->
   syncOptions: () ->
   clearAllOptions: (callback) ->
  ###


