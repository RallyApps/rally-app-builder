_ = require('underscore')
fs = require('fs')
{join} = require('path')

configFileName = "config.json"

module.exports =
  getConfig : (path, callback) ->
    convertToJson = (error, file)->
      if !error then callback(null, JSON.parse(file))
      else
        callback(error)

    configPath = join(path, configFileName)
    if !fs.existsSync(configPath)
      throw new Error("#{configFileName} not found at path #{path}")
    else
      fs.readFile(configPath, "utf-8", convertToJson)
  saveConfig : ({path,config},callback)->
    configPath = join(path, configFileName)
    fs.writeFile(configPath,JSON.stringify(config,null,'   '),callback)


_.defaults module.exports, {configFileName}