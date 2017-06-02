open = require 'open'
express = require 'express'
_ = require 'lodash'
app = express()
path = require 'path'

configModule = require('./config')

module.exports = (args) ->
  appPath = args.path || process.cwd()
  configModule.getAppSourceRoot appPath, (error, srcRoot) ->
    pathToApp = path.relative srcRoot, appPath
    pathToApp = '/' + pathToApp if pathToApp
    args = _.defaults args,
      port: 1337
    app.use express.static srcRoot
    app.listen args.port
    url = "http://localhost:#{args.port}#{pathToApp}/App-debug.html"
    console.log "Launching #{url}..."
    open(url)
