_ = require('underscore')
fs = require 'fs'
path = require 'path'
async = require 'async'
coffeeScript = require 'coffee-script'
uglify = require 'uglify-js'
{JSHINT} = require 'jshint'

module.exports =
  getFiles : ({configJson, appPath}, callback)->
    async.parallel(
      javascript_files: (jsCallback)=>
        @getScripts {appPath, scripts: configJson.javascript, compress: true }, jsCallback
      css_files: (cssCallback)=>
        @getScripts {appPath, scripts: configJson.css }, cssCallback
      callback
    )
  getScripts : ({appPath, scripts, compress}, callback)->
    fullPathScripts = []
    for script in scripts || []
      fullPathScripts.push(path.resolve(appPath, script))

    async.map(fullPathScripts, @readFile, (err, results) =>

      if err then callback(err)
      else
        if compress
          for key,code of results
            fileName = scripts[key]
            results[key] = @processJavaScript(code,fileName)
        callback(null, results)
    )

  compressJavaScript:(code)->
    ast = uglify.parse(code)
    ast.figure_out_scope()
    compressor = uglify.Compressor(
      drop_debugger:true
      unused:false
    )
    ast = ast.transform(compressor)
    return ast.print_to_string()

  processJavaScript : (code,fileName)->
    @hintJavaScriptFile(code,fileName)
    return @compressJavaScript(code)

  readFile : (file, callback)=>
    wrapper = (error, fileContents)->
      if file.match /.coffee$/
        fileContents = coffeeScript.compile(fileContents)
      callback(error, fileContents)
    fs.readFile(file, "utf-8", wrapper)

  hintJavaScriptFile : (code,fileName)->
    if(!JSHINT(code, undef:false))
      for error in JSHINT.errors
        console.log  "Error in #{fileName} on line #{error.line}: #{error.reason}"
