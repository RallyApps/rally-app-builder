_ = require('lodash')
fs = require('fs')
{join} = require('path')

configFileName = "config.json"


_updateConfig = (config)->
  config.server = config.server || "https://rally1.rallydev.com"
  config

saveConfig = ({path, config}, callback)->
  configPath = join(path, configFileName)
  fs.writeFile(configPath, JSON.stringify(config, null, '   '), callback)

getConfig = (path, callback) ->
  convertToJson = (error, file)->
    if !error
      config = JSON.parse(file)
      _updateConfig(config)
      saveConfig({config, path})
      callback(null, config)
    else
      callback(error)

  configPath = join(path, configFileName)
  if !fs.existsSync(configPath)
    throw new Error("#{configFileName} not found at path #{path}")
  else
    fs.readFile(configPath, "utf-8", convertToJson)



module.exports = {_updateConfig,getConfig,saveConfig}
_.defaults module.exports, {configFileName}