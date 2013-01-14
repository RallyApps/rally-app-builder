_ = require('underscore')
request = require('request')
fs = require('fs')
path = require('path')



module.exports =

  parseConfigFile : (fileContents)->
    matched = fileContents.match(/url =.*github\.com.*/)
    fullUrlLine = matched && matched[0]
    url = fullUrlLine.split("=").pop().trim()
    return url

  gatherGitInfo : (appPath, callback)->
    callback = callback|| ()->
    processConfigFile = (error, file)=>
      if error then callback(error)
      else callback(null,@parseConfigFile(file))
    gitConfigPath = path.join(appPath, ".git", "config")
    if(fs.existsSync(gitConfigPath))
      fs.readFile(gitConfigPath, "utf-8", processConfigFile)
    else
      callback()

  log:(action)->
    logUrl = @url[action] || @url._default
    console.log(logUrl)
    request(logUrl, ()->)

  url :
    init:"http://goo.gl/3EGlk",
    clone:"http://goo.gl/JQ1Sr",
    build:"http://goo.gl/NNBfx",
    _default:"http://goo.gl/YFzGP"


