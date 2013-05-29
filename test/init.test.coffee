rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'

describe 'Init new App', ->
  baseDir = 'test/initTemp'

  before ->
    try
      fs.mkdirSync(baseDir)
    catch e

  after ->
    try
      wrench.rmdirSyncRecursive(baseDir)
    catch e

  it 'tests files created', (done) ->

    checkFilesFetched = ->
      files = fs.readdirSync(baseDir)
      error = new Error("README.md not found")

      for file in files
        if file.indexOf("README.md") > -1
          error = null

      done(error) if error
      
      done()

    rallyAppBuilder.init
      name: 'App'
      path: baseDir
      checkFilesFetched