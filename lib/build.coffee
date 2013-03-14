_ = require 'underscore'
fs = require 'fs'
path = require 'path'
async = require 'async'
mustache = require 'mustache'
getScript = require './build/get-script'
git = require('./git')
appFileName = "App.html"
appDebugFileName = "App-debug.html"
deployFilePath = "deploy"
templatePath = path.resolve(__dirname, '../templates/')

{getConfig,configFileName} = require('./config')

createDeployFile = ({appPath, templateData, templateFileName, directory}, callback)->
  console.log "Creating #{templateFileName}"
  appTemplate = fs.readFileSync(path.join(templatePath, templateFileName), "utf-8")
  fullDeployFilePath = path.resolve(appPath, directory)
  filePath = path.join fullDeployFilePath, templateFileName
  if(!fs.existsSync(fullDeployFilePath))
    fs.mkdirSync fullDeployFilePath
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
        (err, {javascript_files, css_files,remote_javascript_files,local_javascript_files})->
          configJson.javascript_files = javascript_files
          configJson.css_files = css_files
          configJson.remote_javascript_files = remote_javascript_files
          configJson.local_javascript_files = local_javascript_files
          buildDeployFiles({appPath, templateData: configJson, appFileName, appDebugFileName }, callback)
      )
    )
  catch error
    callback error

#exports constants
_.defaults module.exports, {configFileName, appFileName, deployFilePath, appDebugFileName}