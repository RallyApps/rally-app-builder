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

  describe('with AppSDK 2.0',()->
    createBuildAssert = (done)->
      (error)->
        if (error) then done(error)
        else
          appFileName = path.join(sdk2TestDirectory,"deploy", rallyAppBuilder.build.appFileName)
          appDebugFileName = path.join(sdk2TestDirectory, rallyAppBuilder.build.appDebugFileName)
          deployFileExists = existsSync appFileName
          assert(deployFileExists)
          debugFileExists = existsSync appDebugFileName
          assert(debugFileExists)
          appFile = fs.readFileSync(appFileName, "utf-8")
          assert(appFile.match /Custom App File/)
          assert(appFile.match /Add app styles here/)
          assert(appFile.match /customcard/)
          done()

    it('should build an App', (done)->
      config = path: sdk2TestDirectory
      rallyAppBuilder.build config, createBuildAssert(done)
    )

    it('should be able to build and App after an App has been built', (done)->
      config = path: sdk2TestDirectory
      rallyAppBuilder.build config, (error)->
        if error then done(error)
        else
          rallyAppBuilder.build config, createBuildAssert(done)

    )
  )

)