assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'

tempTestDirectory = 'test/buildTemp'
fixturesDirectory = path.join(__dirname, 'fixtures')
sdk1Directory = path.join(fixturesDirectory, 'sdk1')
sdk2Directory = path.join(fixturesDirectory, 'sdk2')
existsSync = fs.existsSync || path.existsSync

assertDeployDirectoryHasAppFile = (sdkDirectory)->


describe('Build an App', ()->

  beforeEach (done)->
    try
      copy = ()-> wrench.copyDirRecursive(fixturesDirectory, tempTestDirectory, done)
      fs.mkdir(tempTestDirectory, copy)
    catch e

  afterEach (done)->
    if(existsSync(tempTestDirectory))
      wrench.rmdirRecursive(tempTestDirectory, done)
    else
      done()


  it 'errors if no config', (done)->
    config = path: '.'
    testResponse = (error)->
      if(error)
        done()
      else
        done(new Error("Error not thrown without config specified"))
    rallyAppBuilder.build config, testResponse


  it 'passes with config', (done)->
    config = path: sdk1Directory
    rallyAppBuilder.build config, done

  it('builds sdk2 Apps', (done)->
    config = path: sdk2Directory
    rallyAppBuilder.build config, done
  )


#  it('build operation is safely repeatable', (done)->
#    done()
#  )
)