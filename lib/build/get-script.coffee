_ = require 'lodash'
fs = require 'fs'
path = require 'path'
async = require 'async'
coffeeScript = require 'coffee-script'
uglify = require 'uglify-js'
{JSHINT} = require 'jshint'
less = require 'less'
css = require './css'

isScriptLocal = (scriptName)->
  return !scriptName.match /^.*\/\//
isScriptRemote = (scriptName)->
  return !isScriptLocal(scriptName)

module.exports =

  getFiles: ({configJson, appPath}, callback)->
    localFiles =  _.filter(configJson.javascript, isScriptLocal)
    localCssFiles =  _.filter(configJson.css, isScriptLocal)
    async.parallel
      javascript_files: (jsCallback)=>
        @getJavaScripts {appPath, scripts: localFiles, compress:true}, jsCallback
      uncompressed_javascript_files: (jsCallback)=>
        @getJavaScripts {appPath, scripts: localFiles, compress:false}, jsCallback
      css_file_names: (cssCallback)=>
        cssCallback null, _.map localCssFiles, css.getGeneratedFileName
      css_files: (cssCallback)=>
        @getStylesheets {appPath, scripts: localCssFiles, compress: true}, cssCallback
      uncompressed_css_files: (cssCallback)=>
        @getStylesheets {appPath, scripts: localCssFiles, compress: false}, cssCallback
      remote_css_files: (remoteCssFilesCallback) =>
        remoteCssFilesCallback null, _.filter(configJson.css, isScriptRemote)
      remote_javascript_files: (remoteJsFilesCallback)=>
        remoteJsFilesCallback null, _.filter(configJson.javascript, isScriptRemote)
      local_javascript_files: (localJsFilesCallback)=>
        localJsFilesCallback null, localFiles
      html_files: (htmlFilesCallback)=>
        @getScripts {appPath, scripts: configJson.html}, htmlFilesCallback
      callback

  getJavaScripts: ({appPath, scripts,compress}, callback)->
    @getScripts {appPath, scripts}, (err, results) =>
      if err then callback(err)
      else
        for key,code of results
          fileName = scripts[key]
          @hintJavaScriptFile(code, fileName)
          results[key] = if compress then @compressJavaScript(code) else code
        callback(null, results)

  getStylesheets: ({appPath, scripts, compress}, callback)->
    @getScripts {appPath, scripts}, (err, results) =>
      if err then callback(err)
      else
        async.map results, (cssCode, cb) ->
          css.compile cssCode, compress, cb
        , callback

  getScripts: ({appPath, scripts, compress}, callback)->
    fullPathScripts = []
    for script in scripts || []
      fullPathScripts.push(path.resolve(appPath, script))
    async.map(fullPathScripts, @readFile, callback)

  compressJavaScript: (code)->
    ast = uglify.parse(code)
    ast.figure_out_scope()
    compressor = uglify.Compressor(
      unused: false
    )
    ast = ast.transform(compressor)
    return ast.print_to_string()

  readFile: (file, callback)=>
    wrapper = (error, fileContents)->
      if error
        error = new Error "#{file} could not be loaded. Is the path correct?"
      if file.match /.coffee$/
        fileContents = coffeeScript.compile(fileContents)
      callback(error, fileContents)
    fs.readFile(file, "utf-8", wrapper)

  hintJavaScriptFile: (code, fileName)->
    if(!JSHINT(code, undef: false))
      for error in JSHINT.errors
        console.log "Error in #{fileName} on line #{error.line}: #{error.reason}" unless !error
