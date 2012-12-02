_ = require('underscore')
fs = require 'fs'
path = require 'path'
mustache = require 'mustache'
configFileName = "config.json"


sameExists = fs.existsSync || path.existsSync

getScript = (scriptPath) ->

assertConfigExists = (appPath) ->
  configPath = path.join(appPath, configFileName)
  if(!sameExists(configPath))
    throw new Error("#{configFileName} not found at path #{configPath}")

module.exports = (args, callback)->
  try
    callback = callback || ()->
    appPath = args.path ||  process.cwd()
    assertConfigExists(appPath)
    callback()
  catch error
    callback error

