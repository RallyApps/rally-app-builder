assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'

tempTestDirectory = 'test/buildTemp'
fixturesDirectory = path.join(__dirname, 'fixtures')
sdk1FixturesDirectory = path.join(fixturesDirectory, 'sdk1')
sdk2FixturesDirectory = path.join(fixturesDirectory, 'sdk2')

sdk1TestDirectory = path.join(tempTestDirectory, 'sdk1')
sdk2TestDirectory = path.join(tempTestDirectory, 'sdk2')
existsSync = fs.existsSync || path.existsSync


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
    config = path: sdk1TestDirectory
    rallyAppBuilder.build config, done


  it('builds sdk2 Apps', (done)->
    config = path: sdk2TestDirectory
    assertSuccessfulBuild = (error)->
      if (error) then done(error)
      else
        deployFileExists = existsSync path.join(sdk2TestDirectory, rallyAppBuilder.build.deployFilePath, rallyAppBuilder.build.appFileName)
        assert(deployFileExists)
        debugFileExists = existsSync path.join(sdk2TestDirectory, rallyAppBuilder.build.appDebugFileName)
        assert(debugFileExists)
        done()
    rallyAppBuilder.build config, assertSuccessfulBuild
  )

  it('build operation is safely repeatable', (done)->
    config = path: sdk2TestDirectory
    assertSuccessfulBuild = (error)->
      if (error) then done(error)
      else
        deployFileExists = existsSync path.join(sdk2TestDirectory, rallyAppBuilder.build.deployFilePath, rallyAppBuilder.build.appFileName)
        assert(deployFileExists)
        debugFileExists = existsSync path.join(sdk2TestDirectory, rallyAppBuilder.build.appDebugFileName)
        assert(debugFileExists)
        done()
    rallyAppBuilder.build config, (error)->
      if error then done(error)
      else
        rallyAppBuilder.build config, assertSuccessfulBuild

  )
)