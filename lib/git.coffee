_ = require('lodash')
request = require('request')
fs = require('fs')
path = require('path')



module.exports =
  removeProtocol:(url)->
    return url.split(":")[1];

  parseConfigFile : (fileContents)->
    matched = fileContents.match(/url =.*github\.com.*/)
    fullUrlLine = matched && matched[0]
    url = @removeProtocol(fullUrlLine.split("=").pop().trim())
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



