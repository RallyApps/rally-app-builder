_ = require('lodash')
fs = require('fs')
pathUtils = require('path')

configFileName = "config.json"

_updateConfig = (config)->
  config.server = config.server || "https://rally1.rallydev.com"
  config

saveConfig = ({path, config}, callback)->
  configPath = pathUtils.join(path, configFileName)
  fs.writeFile(configPath, JSON.stringify(config, null, '    '), callback)

getConfig = (path, callback) ->
  convertToJson = (error, file)->
    if !error
      config = JSON.parse(file)
      _updateConfig(config)
      saveConfig({config, path})
      callback(null, config)
    else
      callback(error)

  configPath = pathUtils.join(path, configFileName)
  if !fs.existsSync(configPath)
    throw new Error("#{configFileName} not found at path #{path}")
  else
    fs.readFile(configPath, "utf-8", convertToJson)

getAppSourceRoot = (path, callback) ->
  getConfig path, (err, config) ->
    root = pathUtils.resolve path
    localFiles = _.filter config.javascript, (jsFile) -> !jsFile.match /^.*\/\//
    dirNames = localFiles.map (appFilePath) ->
      pathUtils.dirname pathUtils.resolve pathUtils.join root, appFilePath
    common = root
    while(!_.every(dirNames, (dir) -> dir.indexOf(common) == 0))
      common = pathUtils.resolve common, '..'
    callback null, common

module.exports = {_updateConfig,getConfig,saveConfig,getAppSourceRoot}
_.defaults module.exports, {configFileName}
