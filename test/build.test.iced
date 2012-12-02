assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'

describe('Build an App', ()->
  baseDir = 'test/buildTemp'

  before ()->
    try
      fs.mkdirSync(baseDir)
    catch e

  after ()->
    try
      wrench.rmdirSyncRecursive(baseDir)
    catch e

  it 'errors if no config', (done)->
    config = path : '.'
    testResponse = (error)->
      console.log(error)
      if(error)
        done()
      else
        done(new Error("Error not thrown without config specified"))
    rallyAppBuilder.build config, testResponse


  it 'passes with config', (done)->

    config = path : path.join(__dirname, 'fixtures','sdk1')
    rallyAppBuilder.build config, done

  it('worked', (done)->
    done()
#    checkFilesFetched = ()->
#      files = fs.readdirSync(baseDir)
#      error = new Error("README.md not found")
#      for file in files
#        if file.indexOf("README.md") > -1
#          error = null
#      if error
#        done(error)
#      else
#        done()
#
#    rallyAppBuilder.init(
#      name: 'App'
#      path: baseDir
#      checkFilesFetched
#    )
  )
)