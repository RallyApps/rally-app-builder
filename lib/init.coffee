_ = require 'underscore'
fs = require 'fs'
path = require 'path'
mustache = require 'mustache'

templates =
  "config.json": "config.json"
  "package.json": "package.json"
  "README.md": "README.md"

files =
  "app.css": "styles/app.css"
  "App.js": "src/App.js"
  "AppSpec.js": "test/AppSpec.js"
  "gitignore": ".gitignore"
  "LICENSE": "LICENSE"
  "Gruntfile.js": "Gruntfile.js"
  "App-debug.html": "templates/App-debug.html"
  "App.html": "templates/App.html"
  "specs.tmpl": "templates/specs.tmpl"


module.exports = (args, callback)->
  callback = callback || ()->
  try
    args = _.defaults args,
      name: 'Random App Name' + Math.floor(Math.random() * 100000)
      sdk_version: '2.0rc1',
      server: 'https://rally1.rallydev.com'
      path: '.'
    filePath = args.path
    delete args.path
    view = args
    templatePath = path.resolve(__dirname, '../templates/')
    fs.mkdirSync("#{filePath}/styles")
    fs.mkdirSync("#{filePath}/src")
    fs.mkdirSync("#{filePath}/templates")
    fs.mkdirSync("#{filePath}/test")
    _.each(templates,
    (value, key) ->
      templateFile = "#{templatePath}/#{key}"
      destinationFile = "#{filePath}/#{value}"
      file = fs.readFileSync(templateFile, "utf-8")
      parsed = mustache.render(file, view)
      fs.writeFileSync(destinationFile, parsed)
    )
    _.each(files,
    (value, key)->
      templateFile = "#{templatePath}/#{key}"
      destinationFile = "#{filePath}/#{value}"
      file = fs.readFileSync(templateFile, "utf-8")
      fs.writeFileSync(destinationFile, file)
    )
  catch err
    error = err
  if error
    callback(error)
  else
    callback()



