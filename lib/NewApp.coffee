_ = require('underscore')
fs = require('fs')

error = (error) ->
  console.error(error)

success = (success)->
  console.log("success")

files =
  "app.css":"app.css"
  "App.js":"App.js"
  "config.json":"config.json"
  "gitignore":".gitignore"
  "LICENSE":"LICENSE"
  "README.md":"README.md"

module.exports = (args)->
  @args = _.defaults args,
    error: error
    success: success
    name: 'Random App Name' + Math.floor(Math.random() *100000)
    sdk_version: '2.0p5',
    server: 'rally1.rallydev.com'
  console.log args
  _.each( files,
  (value, key)-> console.log(value , key)
  )


