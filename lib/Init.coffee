_ = require 'underscore'
fs = require 'fs'
Mustache = require 'mustache'
error = (error) ->
  console.error(error)

success = (success)->
  console.log("success")

files =
  "app.css": "app.css"
  "App.js": "App.js"
  "config.json": "config.json"
  "gitignore": ".gitignore"
  "LICENSE": "LICENSE"
  "README.md": "README.md"


module.exports = (args)->
  view = _.defaults args,
    name: 'Random App Name' + Math.floor(Math.random() * 100000)
    sdk_version: '2.0p5',
    server: 'rally1.rallydev.com'

  _.each(files,
  (value, key)->
    templateFile = "templates/#{key}"
    destinationFile = "test/#{value}"
    file = fs.readFileSync(templateFile, "utf-8")
    parsed = Mustache.render(file, view)
    fs.writeFile(destinationFile,parsed)
  )


