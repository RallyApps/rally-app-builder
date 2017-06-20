_ = require('lodash')
fs = require('fs')
pathUtils = require('path')

configFileName = "config.json"

saveConfig = ({path, config}, callback)->
  configPath = pathUtils.join(path, configFileName)
  fs.writeFile(configPath, JSON.stringify(config, null, '    '), callback)

getConfig = (path, callback) ->
  convertToJson = (error, file)->
    if !error
      callback(null, JSON.parse(file))
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

module.exports = {getConfig,saveConfig,getAppSourceRoot}
_.defaults module.exports, {configFileName}
