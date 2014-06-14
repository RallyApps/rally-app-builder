_ = require 'lodash'
fs = require 'fs'
pathUtil = require 'path'
async = require 'async'
mustache = require 'mustache'
getScript = require './get-script'
css = require './css'
appFileName = "App.html"
appUncompressedFileName = "App-uncompressed.html"
appDebugFileName = "App-debug.html"
deployFilePath = "deploy"
templateDirectory = pathUtil.resolve(__dirname, '../../templates/')

{getConfig,configFileName} = require('../config')

createDeployFile = ({appPath, templateBase, templateData, templateFileName, directory}, callback)->
  console.log "Creating #{templateFileName}"
  appTemplate = fs.readFileSync(pathUtil.join(templateBase, templateFileName), "utf-8")
  fullDeployFilePath = pathUtil.resolve(appPath, directory)
  filePath = pathUtil.join fullDeployFilePath, templateFileName
  if(!fs.existsSync(fullDeployFilePath))
    fs.mkdirSync fullDeployFilePath
  compiledApp = mustache.render(appTemplate, templateData)
  fs.writeFile(filePath, compiledApp, callback)

buildDeployFiles = ({appPath, templateData, templateBase, appFileName, appDebugFileName, appUncompressedFileName }, callback)->
  async.forEach(
    [
      {templateFileName: appDebugFileName, directory: '.'},
      {templateFileName: appFileName, directory: deployFilePath}
      {templateFileName: appUncompressedFileName, directory: deployFilePath,compress:false}
    ]
    (options, cb)->
      options = _.extend {
        appPath
        templateData
        templateBase
      }, options
      createDeployFile options, cb
    callback
  )

module.exports = ({path}, callback)->
  try
    callback = callback || ()->
    appPath = path || process.cwd()
    getConfig appPath, (error, configJson)->
      if error then callback error
      else
      getScript.getFiles {configJson, appPath,compress:false},
        (err, {javascript_files, css_files,remote_javascript_files,local_javascript_files,uncompressed_javascript_files,uncompressed_css_files, css_file_names, html_files})->
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
                templateBase = pathUtil.join templateDirectory, 
                  switch configJson.framework
                    when "angular" then "ng"
                    when "ext" then "ext"
                    else "ext"

                options = {
                  appPath
                  templateData: configJson
                  appFileName: appFileName
                  appDebugFileName: appDebugFileName
                  appUncompressedFileName: appUncompressedFileName
                  templateBase
                }
                buildDeployFiles(options, callback)
  catch error
    callback error

#exports constants
_.defaults module.exports, {configFileName, appFileName, deployFilePath, appDebugFileName,appUncompressedFileName}
