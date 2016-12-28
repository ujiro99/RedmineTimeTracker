expect = chai.expect

describe 'PluginManager.coffee', ->

  PluginManager = null
  $rootScope = null

  beforeEach () ->
    angular.mock.module('timeTracker')
    inject (_PluginManager_, _$rootScope_) ->
      PluginManager = _PluginManager_
      $rootScope = _$rootScope_


  class testPlugin
    constructor: (@_Platform) ->
    onSendTimeEntry: (cb) ->
      cb and cb()
    ###*
     On time entry was send, show desktop notification.
     @param {Object} RTT - Interface to communicate with app.
     @param {Function} cb - Callback function.
    ###
    onSendedTimeEntry: (RTT, cb) ->
      cb and cb()


  describe 'constructor(window, Analytics, Log)', ->
    it 'should have working PluginManager service.', () ->
      expect(PluginManager).not.to.equal null
      expect(RTT).not.to.equal null


  describe 'registerPlugin(name, pluginClass)', ->
    it 'should be able to call registerPlugin() from RTT object.', () ->
      pluginName = 'mockPlugin'
      RTT.registerPlugin(pluginName, testPlugin)
      expect(PluginManager.listPlugins()[pluginName]).not.to.equal(null)


  describe 'unregisterPlugin(name)', ->
    it 'should be able to call unregisterPlugin() from RTT object.', () ->
      pluginName = 'mockPlugin'
      RTT.registerPlugin(pluginName, testPlugin)
      RTT.unregisterPlugin(pluginName)
      expect(PluginManager.listPlugins()[pluginName]).to.be.undefined


  describe 'listPlugins()', ->
    it 'should returns empty object, if not registered.', () ->
      expect(PluginManager.listPlugins()).to.be.empty

    it 'should returns a plugin.', () ->
      pluginName = 'mockPlugin'
      RTT.registerPlugin(pluginName, testPlugin)
      expect(PluginManager.listPlugins()[pluginName]).not.to.equal(null)

    it 'should returns two plugins.', () ->
      pluginName1 = 'plugin2'
      pluginName2 = 'plugin2'
      RTT.registerPlugin(pluginName1, testPlugin)
      RTT.registerPlugin(pluginName2, testPlugin)
      expect(PluginManager.listPlugins()[pluginName1]).not.to.equal(null)
      expect(PluginManager.listPlugins()[pluginName2]).not.to.equal(null)


  describe 'loadPluginUrl(url, cb)', ->
    it 'should calls loaded callback.', (done) ->
      url = './mockPlugin.js'
      if not location.hostname.isBlank() # on karma
        url = './base/test/mockPlugin.js'
      setTimeout () -> $rootScope.$apply()
      PluginManager.loadPluginUrl(url, (param) ->
        expect(param).to.equal(url)
        done()
      )


  describe 'notify(event, args...)', ->
    it 'should calls loaded callback.', (done) ->
      RTT.registerPlugin('mockPlugin', testPlugin)
      setTimeout () -> $rootScope.$apply()
      PluginManager.notify(PluginManager.events.SENDED_TIME_ENTRY, () -> done())
