less = require 'less'
fs = require 'fs'
_ = require 'lodash'
LESS_FILE_REGEX = /[.]less$/
VARS =
  prefix: 'x-'

isLessFile = (cssName)->
  cssName.match LESS_FILE_REGEX

getGeneratedFileName =  (cssFile) ->
  cssFile.replace LESS_FILE_REGEX, '.less.css'

compile = (cssCode, compress, callback) ->
  parser = new less.Parser()
  _.each VARS, (value, key) ->
    cssCode += "\n@#{key}: #{value};"
  parser.parse cssCode, (err, tree) ->
    if err
      callback err
    else
      callback null, tree.toCSS
        compress: compress
        #todo: figure out how to not strip out comments

compileInPlace = (file, compress, callback) ->
  if isLessFile file
    fs.readFile file, 'utf-8', (err, contents) ->
      if err then callback err
      else
        compile contents, compress, (e, css) ->
          fileName = getGeneratedFileName file
          fs.writeFile fileName, css, (badThing) ->
            callback badThing, fileName
  else
    callback null, file

module.exports =
  isLessFile: isLessFile
  getGeneratedFileName: getGeneratedFileName
  compile: compile
  compileInPlace: compileInPlace


