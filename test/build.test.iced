assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'


tempTestDirectory = 'test/buildTemp'
fixturesDirectory = path.join(__dirname, 'fixtures')
sdk1Directory = path.join(fixturesDirectory, 'sdk1')
sdk2Directory = path.join(fixturesDirectory, 'sdk2')


describe('Build an App', ()->
  beforeEach (done)->
    try
      copy = ()-> wrench.copyDirRecursive( fixturesDirectory,tempTestDirectory,done)
      fs.mkdir(tempTestDirectory,copy)
    catch e

  afterEach (done)->
    try
      wrench.rmdirRecursive(tempTestDirectory,done)
    catch e

  it 'errors if no config', (done)->
    config = path : '.'
    testResponse = (error)->
      if(error)
        done()
      else
        done(new Error("Error not thrown without config specified"))
    rallyAppBuilder.build config, testResponse


  it 'passes with config', (done)->

    config = path : sdk1Directory
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