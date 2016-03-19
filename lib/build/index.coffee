_ = require 'lodash'
fs = require 'fs'
pathUtil = require 'path'
async = require 'async'
mustache = require 'mustache'
getScript = require './get-script'
css = require './css'
shell = require('shelljs')

appFileName = "App.html"
appExternalFileName = "App-external.html"
appUncompressedFileName = "App-uncompressed.html"
appDebugFileName = "App-debug.html"
deployFilePath = "deploy"
templateDirectory = pathUtil.resolve(__dirname, '../../templates/')

configModule = require('../config')

runScript = (configJson, appPath, step, callback)->
  if step not in ['prebuild', 'postbuild'] then return callback("Unknown script step #{step}")
  script = configJson?.scripts?[step]
  if script?
    console.log("Running #{step} script: '#{script}'")
    shell.pushd(appPath)
    shell.exec script, (err)->
      shell.popd()
      callback(err)
  else
    callback()

createDeployFile = ({appPath, templateData, templateFileName, directory}, callback)->
  console.log "Creating #{templateFileName}"
  templateBase = templateData.templates
  appTemplate = fs.readFileSync(pathUtil.join(templateBase, templateFileName), "utf-8")
  fullDeployFilePath = pathUtil.resolve(appPath, directory)
  filePath = pathUtil.join fullDeployFilePath, templateFileName
  if(!fs.existsSync(fullDeployFilePath))
    fs.mkdirSync fullDeployFilePath
  compiledApp = mustache.render(appTemplate, templateData)
  fs.writeFile(filePath, compiledApp, callback)

buildDeployFiles = ({appPath, templateData, appFileName, appExternalFileName, appDebugFileName, appUncompressedFileName }, callback)->
  templateBase = templateData.templates
  async.forEach(
    [
      {templateFileName: appDebugFileName, directory: '.'},
      {templateFileName: appFileName, directory: deployFilePath}
      {templateFileName: appExternalFileName, directory: deployFilePath}
      {templateFileName: appUncompressedFileName, directory: deployFilePath, compress:false}
    ]
    (options, cb)->
      options = _.extend {
        appPath
        templateData
      }, options
      createDeployFile options, cb
    callback
  )

runBuild = (configJson, appPath, callback)->
  getScript.getFiles {configJson, appPath,compress:false},
    (err, {javascript_files, css_files, remote_javascript_files, local_javascript_files, uncompressed_javascript_files, uncompressed_css_files, css_file_names, html_files})->
      if err
        callback err
      else
        configJson.javascript_files = javascript_files
        configJson.css_file_names = css_file_names
        configJson.css_files = css_files
        configJson.uncompressed_css_files = uncompressed_css_files
        configJson.remote_javascript_files = remote_javascript_files
        configJson.local_javascript_files = local_javascript_files
        configJson.uncompressed_javascript_files = uncompressed_javascript_files
        configJson.html_files = html_files
        async.forEach configJson.css, (c, callback) ->
          cssPath = pathUtil.resolve appPath, c
          css.compileInPlace cssPath, false, callback
        , (err)->
          if err then callback err
          else
            options = {
              appPath
              templateData: configJson
              appFileName: appFileName
              appDebugFileName: appDebugFileName
              appUncompressedFileName: appUncompressedFileName
              appExternalFileName: appExternalFileName
            }
            buildDeployFiles(options, callback)

module.exports = ({path,templates}, callback)->
  try
    callback = callback || ()->
    appPath = path || process.cwd()
    configModule.getConfig appPath, (error, configJson)->
      if error then callback error
      else
        configJson = _.defaults configJson,
          templates: templates || pathUtil.join templateDirectory, 'deploy'
        async.series [
          (callback)-> module.exports.runScript configJson, appPath, 'prebuild', callback
          (callback)-> module.exports.runBuild configJson, appPath, callback
          (callback)-> module.exports.runScript configJson, appPath, 'postbuild', callback
        ]
        , (err)->
          callback(err)
  catch error
    callback error

#exports constants
_.defaults module.exports, {configFileName: configModule.configFileName, appFileName, deployFilePath, appDebugFileName, appUncompressedFileName, appExternalFileName, runScript, runBuild}
