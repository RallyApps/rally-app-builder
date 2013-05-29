_ = require 'underscore'
fs = require 'fs'
path = require 'path'
mustache = require 'mustache'

files =
  "app.css": "styles/app.css"
  "App.js": "src/App.js"
  "AppSpec.js": "test/AppSpec.js"
  "config.json": "config.json"
  "gitignore": ".gitignore"
  "LICENSE": "LICENSE"
  "README.md": "README.md"
  "Gruntfile.js": "Gruntfile.js"
  "App-debug.html": "templates/App-debug.html"
  "App.html": "templates/App.html"
  "specs.tmpl": "templates/specs.tmpl"


module.exports = (args, callback)->
  callback = callback || ()->
  try
    args = _.defaults args,
      name: 'Random App Name' + Math.floor(Math.random() * 100000)
      sdk_version: '2.0p5',
      server: 'https://rally1.rallydev.com'
      path: '.'
    filePath = args.path
    delete args.path
    view = args
    templatePath = path.resolve(__dirname, '../templates/')
    fs.mkdirSync('styles')
    fs.mkdirSync('src')
    fs.mkdirSync('templates')
    fs.mkdirSync('test')
    _.each(files,
    (value, key)->
      templateFile = "#{templatePath}/#{key}"
      destinationFile = "#{filePath}/#{value}"
      file = fs.readFileSync(templateFile, "utf-8")
      parsed = mustache.render(file, view)
      fs.writeFileSync(destinationFile, parsed)
    )
  catch err
    error = err
  if error
    callback(error)
  else
    callback()



