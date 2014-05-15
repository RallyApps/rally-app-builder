open = require 'open'
express = require 'express'
_ = require 'lodash'
app = express()
path = require 'path'

module.exports = (args) ->
  args = _.defaults args,
    port: 1337
  app.use express.static process.cwd()
  app.listen args.port
  url = "http://localhost:#{args.port}/App-debug.html"
  console.log "Launching #{url}..."
  open(url)