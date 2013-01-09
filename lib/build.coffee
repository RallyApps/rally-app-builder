_ = require('underscore')
fs = require 'fs'
path = require 'path'
async = require 'async'
mustache = require 'mustache'

getScript = require './build/get-script'
configFileName = "config.json"
appFileName = "App.html"
appDebugFileName = "App-debug.html"
deployFilePath = "deploy"
templatePath = path.resolve(__dirname, '../templates/')
sameExistsSync = fs.existsSync || path.existsSync

getGitRepo = (appPath, callback)->
  convertToJson = (error, file)->

  configPath = path.join(appPath, ".git", "config")
  if(sameExistsSync(configPath))
    fs.readFile(configPath, "utf-8", convertToJson)
  else
    console.log("git not found!")


getConfig = (appPath, callback) ->
  convertToJson = (error, file)->
    if !error then callback(null, JSON.parse(file))
    else
      callback(error)

  configPath = path.join(appPath, configFileName)
  if !sameExistsSync(configPath)
    throw new Error("#{configFileName} not found at path #{configPath}")
  else
    fs.readFile(configPath, "utf-8", convertToJson)


createDeployFile = ({appPath, templateData, templateFileName, directory}, callback)->
  appTemplate = fs.readFileSync(path.join(templatePath, templateFileName), "utf-8")
  fullDeployFilePath = path.resolve(appPath, directory)
  filePath = path.join(fullDeployFilePath, templateFileName)
  if(!sameExistsSync(fullDeployFilePath))
    fs.mkdirSync(fullDeployFilePath)
  compiledApp = mustache.render(appTemplate, templateData)
  fs.writeFile(filePath, compiledApp, callback)

buildDeployFiles = ({appPath, templateData, appFileName, appDebugFileName }, callback)->
  async.forEach(
    [
      {appPath, templateData, templateFileName: appDebugFileName, directory: '.'},
      {appPath, templateData, templateFileName: appFileName, directory: deployFilePath}
    ]
    createDeployFile
    callback
  )

module.exports = ({path}, callback)->
  try
    callback = callback || ()->
    appPath = path || process.cwd()
    getConfig(appPath, (error, configJson)->
      if error then callback error
      else
      getScript.getFiles(
        {configJson, appPath}
        (err, {javascript_files, css_files})->
          configJson.javascript_files = javascript_files
          configJson.css_files = css_files
          buildDeployFiles({appPath, templateData: configJson, appFileName, appDebugFileName }, callback)
      )
    )
  catch error
    callback error

#exports constants
_.defaults module.exports, {configFileName, appFileName, deployFilePath, appDebugFileName}