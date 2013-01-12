_ = require('underscore')
request = require('request')
fs = require('fs')
path = require('path')



module.exports =
  _gatherGitInfo : (appPath, callback)->
    callback = callback|| ()->
    processConfigFile = (error, file)->
      if error then callback(error)
      else
        repoUrl = file.match( /https:\/\/github.com\/\.git/)

        callback()
    gitConfigPath = path.join(appPath, ".git", "config")
    if(fs.existsSync(gitConfigPath))
      fs.readFile(gitConfigPath, "utf-8", processConfigFile)
    else
      console.log("git not found!")

  log:(action)->
    logUrl = @url[action] || @url._default
    console.log(logUrl)
    request(logUrl, ()->)

  url :
    init:"http://goo.gl/3EGlk",
    clone:"http://goo.gl/JQ1Sr",
    build:"http://goo.gl/NNBfx",
    _default:"http://goo.gl/YFzGP"


