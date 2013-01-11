_ = require('underscore')
request = require('request')

url ={
  init:"http://goo.gl/3EGlk",
  clone:"http://goo.gl/JQ1Sr",
  build:"http://goo.gl/NNBfx",
  _default:"http://goo.gl/YFzGP"
}

module.exports =
  log:(action)->
    logUrl = url[action] || url._default
    console.log(logUrl)
    request(logUrl, ()->)

