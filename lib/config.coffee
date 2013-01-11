_ = require('underscore')
fs = require('fs')
path = require('path')

configFileName = "config.json"

module.exports =
  getConfig : (appPath, callback) ->
    convertToJson = (error, file)->
      if !error then callback(null, JSON.parse(file))
      else
        callback(error)

    configPath = path.join(appPath, configFileName)
    if !fs.existsSync(configPath)
      throw new Error("#{configFileName} not found at path #{configPath}")
    else
      fs.readFile(configPath, "utf-8", convertToJson)


_.defaults module.exports, {configFileName}