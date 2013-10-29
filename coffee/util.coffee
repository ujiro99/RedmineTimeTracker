@util = {

  ###
   get url
  ###
  getUrl: (url) ->
    url = $.trim(url)
    url = url.match(/(^https?:\/\/.+?)\//i, "")[1]


}
