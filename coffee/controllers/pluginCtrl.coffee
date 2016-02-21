timeTracker.controller 'PluginCtrl', ($scope, PluginManager, Resource, Message, Log, Option) ->

  $scope.options = Option.getOptions()
  $scope.inputField = { text: '' }
  $scope.plugins = []


  $scope.clickAddPlugin = (url) ->
    return if not url or not url.isUrl()
    PluginManager.loadPluginUrl(url)


  $scope.clickRemovePlugin = (pluginName) ->
    return if not pluginName
    PluginManager.removePlugin(pluginName)


  init = () ->
    PluginManager.addEventListener(PluginManager.UPDATED_PLUGIN, updatePlugins)
    PluginManager.addEventListener(PluginManager.LOAD_FAILED, loadPluginFailed)
    loadSavedPlugins()


  loadSavedPlugins = () ->
    pluginUrls = $scope.options.plugins
    Log.debug("loadSavedPlugins")
    Log.debug(pluginUrls)
    for url in pluginUrls
      PluginManager.loadPluginUrl(url)


  updatePlugins = () ->
    Log.debug("updatePlugins")
    $scope.plugins = []
    list = PluginManager.listPlugins()
    for name, pluginOb of list
      $scope.plugins.push({ name: name })
      Log.debug("plugin: { name: " + name + "}")


  loadPluginFailed = (msg) ->
    Message.toast "load plugin failed."
    # Message.toast Resource.string("msgRequestInputURL")


  init()
