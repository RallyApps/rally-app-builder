_ = require 'lodash'
fs = require 'fs'
path = require 'path'
mustache = require 'mustache'

files =
  "app.css": "app.css"
  "App.js": "App.js"
  "config.json": "config.json"
  "gitignore": ".gitignore"
  ".travis.yml": ".travis.yml"
  "LICENSE": "LICENSE"
  "README.md": "README.md"
  "Gruntfile.js":"Gruntfile.js"
  "package.json":"package.json"
  "specs.tmpl":"test/specs.tmpl"
  "AppSpec.js":"test/AppSpec.js"

directories = ["test"]


module.exports = (args, callback)->
  callback = callback || ()->
  try
    args = _.defaults args,
      name: 'Random App Name' + Math.floor(Math.random() * 100000)
      sdk_version: '2.0rc2',
      server: 'https://rally1.rallydev.com'
      path: '.'
    filePath = args.path
    view = args
    templatePath = path.resolve(__dirname, '../templates/')

    _.each(directories,
    (value)->
      if !fs.existsSync "#{filePath}/#{value}"
        fs.mkdirSync "#{filePath}/#{value}"
    )

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



