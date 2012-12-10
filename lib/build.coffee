_ = require('underscore')
fs = require 'fs'
path = require 'path'
async = require 'async'
mustache = require 'mustache'
configFileName = "config.json"
appFileName = "App.html"
deployFilePath = "deploy"
templatePath = path.resolve(__dirname, '../templates/')
sameExistsSync = fs.existsSync || path.existsSync
javaScriptTemplate = """
                 """

getConfig = (appPath, callback) ->
  convertToJson = (error, file)->
    if !error
      callback(null, JSON.parse(file))
    else
      callback(error)

  configPath = path.join(appPath, configFileName)
  if(!sameExistsSync(configPath))
    throw new Error("#{configFileName} not found at path #{configPath}")
  fs.readFile(configPath, "utf-8", convertToJson)


getScripts = ({appPath, scripts}, callback)->
  fullPathScripts = []
  for script in scripts || []
    fullPathScripts.push(path.resolve(appPath, script))
  readFile = (file, callback)->
    fs.readFile(file, "utf-8", callback)
  async.map(fullPathScripts, readFile, (err, results) ->
    if err then callback(err)
    else callback(null,results)
  )


createDeployFile = (appPath, data, callback)->
  appTemplate = fs.readFileSync(path.resolve(__dirname, '../templates/App.html'),"utf-8")
  fullDeployFilePath = path.join(appPath, deployFilePath)
  filePath = path.join(fullDeployFilePath, appFileName)
  if(!sameExistsSync(fullDeployFilePath))
    fs.mkdirSync(fullDeployFilePath)
  compiledApp = mustache.render(appTemplate, data)
  fs.writeFile(filePath, compiledApp, callback)

module.exports = ({path}, callback)->
  try
    callback = callback || ()->

    appPath = path || process.cwd()
    getConfig(appPath, (error, configJson)->
      if error then callback error
      else
        async.parallel(

          javascript_files: (jsCallback)->
            scripts = configJson.javascript
            getScripts {appPath, scripts }, jsCallback
          css_files: (cssCallback)->
            scripts = configJson.css
            getScripts {appPath, scripts }, cssCallback
        (err, files)->
          data = _.defaults(configJson,files)
          createDeployFile(appPath, data, callback)
        )

    )

  catch error
    callback error


#exports costants
_.defaults module.exports, {configFileName, appFileName, deployFilePath}