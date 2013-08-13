assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'


tempTestDirectory = 'test/buildTemp'
fixturesDirectory = path.join(__dirname, 'fixtures')

sdk2TestDirectory = path.join(tempTestDirectory, 'sdk2')
sdk2CustomSdkVersionDirectory = path.join(tempTestDirectory, 'sdk2CustomSdkVersion')
sdk2WithExternalJavaScript = path.join(tempTestDirectory, 'sdk2WithExternalJavaScript')

describe('Build an App', ()->
  before (done)->
    try
      copy = ()-> wrench.copyDirRecursive(fixturesDirectory, tempTestDirectory, done)
      fs.mkdir(tempTestDirectory, copy)
    catch e

  after (done)->
#    if(fs.existsSync(tempTestDirectory))
#      wrench.rmdirRecursive(tempTestDirectory, done)
#    else
      done()


  it 'errors if no config', (done)->
    config = path: '.'
    testResponse = (error)->
      if(error)
        done()
      else
        done(new Error("Error not thrown without config specified"))
    rallyAppBuilder.build config, testResponse

  describe 'with AppSDK 2.0', ()->
    describe 'basic functionality', ()->
      createBuildAssert = (baseDirectory)->
        appFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appFileName)
        appUncompressedFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appUncompressedFileName)
        appDebugFileName = path.join(baseDirectory, rallyAppBuilder.build.appDebugFileName)
        appFile = ""
        it "should have a #{rallyAppBuilder.build.appFileName}", ()->
          assert(fs.existsSync appFileName)
        it "should have a #{rallyAppBuilder.build.appUncompressedFileName}", ()->
          assert(fs.existsSync appUncompressedFileName)
        it "should have a #{rallyAppBuilder.build.appDebugFileName}", ()->
          assert(fs.existsSync appDebugFileName)

        describe "in the #{rallyAppBuilder.build.appFileName}", ()->
          appFile = ""
          before ()->
            appFile = fs.readFileSync(appFileName, "utf-8")
          it "should contain the string from the  Custom App File",
          ()->
            assert(appFile.match /Custom App File/)
          it "should contain the string from the CSS file",
          ()->
            assert(appFile.match /Add app styles here/)
          it "should contain the string from the CustomCard file",
          ()->
            assert(appFile.match /customcard/)

          it "should contain the string from the parent collection",
          ()->
            assert(appFile.match /ferentchak.*ninjas/)
          it "should contain the processed coffeescript file",
          ()->
            assert(appFile.match /CoffeeCard/)
          it "should have the correct sdk debug file name", ()->
            file = fs.readFileSync appDebugFileName, "utf-8"
            assert(file.match /https:\/\/rally1\.rallydev\.com/)

        describe "in the #{rallyAppBuilder.build.appUncompressedFileName}", ()->
          appFile = ""
          before ()->
            appFile = fs.readFileSync(appUncompressedFileName, "utf-8")
          it "should still have the comment string since it is unminified",
          ()->
            assert(appFile.match /Important Comment/)

      describe 'that has JavaScript files', ()->
        before (done)->
          config = path: sdk2TestDirectory
          rallyAppBuilder.build config, done
        createBuildAssert sdk2TestDirectory


      describe 'that has already been built', ()->
        before (done)->
          config = path: sdk2TestDirectory
          rallyAppBuilder.build config, done
        createBuildAssert sdk2TestDirectory


    describe 'with new SDK specified', ()->
      appDebugFileName=""
      before (done)->
        config = path: sdk2CustomSdkVersionDirectory
        rallyAppBuilder.build config, done
        appDebugFileName = path.join(sdk2CustomSdkVersionDirectory, rallyAppBuilder.build.appDebugFileName)
      it "should have a #{rallyAppBuilder.build.appDebugFileName}", ()->
        assert(fs.existsSync appDebugFileName)
      it "should have the correct sdk debug file name", ()->
        file = fs.readFileSync appDebugFileName, "utf-8"
        assert(file.match /https:\/\/testserver\.konami\.com/)

    describe 'with external JavaScript files specified', ()->
      appDebugFileContents=""
      appFileContents=""
      before (done)->
        config = path: sdk2WithExternalJavaScript
        rallyAppBuilder.build config, (error)->
          appDebugFileName = path.join(sdk2WithExternalJavaScript, rallyAppBuilder.build.appDebugFileName)
          appDebugFileContents = file = fs.readFileSync appDebugFileName, "utf-8"
          appFileName = path.join(sdk2WithExternalJavaScript,"deploy", rallyAppBuilder.build.appFileName)
          appFileContents = file = fs.readFileSync appFileName, "utf-8"
          done(error)

      describe "debug file", ()->
        it "should have a link to underscore",
        ()->
          assert(appDebugFileContents.indexOf("cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js") >= 0)
        it "should have a link to secret js using https",
        ()->
          assert(appDebugFileContents.indexOf("https://www.secure.com/secret.js") >= 0)
        it "should have a link to stuff js using http",
        ()->
          assert(appDebugFileContents.indexOf("http://www.regular.com/stuff.js") >= 0)

)