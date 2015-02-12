assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'
sinon = require 'sinon'
shell = require 'shelljs'

tempTestDirectory = 'test/buildTemp'
fixturesDirectory = path.join(__dirname, 'fixtures')

sdk2TestDirectory = path.join(tempTestDirectory, 'sdk2')
sdk2CustomSdkVersionDirectory = path.join(tempTestDirectory, 'sdk2CustomSdkVersion')
sdk2WithExternalJavaScript = path.join(tempTestDirectory, 'sdk2WithExternalJavaScript')
sdk2WithLessDirectory = path.join(tempTestDirectory, 'sdk2less')
sdk2WithExternalStylesDirectory = path.join(tempTestDirectory, 'sdk2WithExternalStyles')

describe 'Build an App', ()->
  before (done)->
    try
      copy = ()-> wrench.copyDirRecursive(fixturesDirectory, tempTestDirectory, done)
      fs.mkdir(tempTestDirectory, copy)
    catch e
  after (done)->
      done()

  it 'errors if no config', (done)->
    config = path: '.'
    testResponse = (error)->
      if(error)
        done()
      else
        done(new Error("Error not thrown without config specified"))
    rallyAppBuilder.build config, testResponse

  describe 'with AppSDK 2.0', () ->
    describe 'basic functionality', () ->
      createBuildAssert = (baseDirectory) ->
        appFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appFileName)
        appUncompressedFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appUncompressedFileName)
        appExternalFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appExternalFileName)
        appDebugFileName = path.join(baseDirectory, rallyAppBuilder.build.appDebugFileName)
        appFile = ""
        it "should have a #{rallyAppBuilder.build.appFileName}", ()->
          assert(fs.existsSync appFileName)
        it "should have a #{rallyAppBuilder.build.appUncompressedFileName}", ()->
          assert(fs.existsSync appUncompressedFileName)
        it "should have a #{rallyAppBuilder.build.appDebugFileName}", ()->
          assert(fs.existsSync appDebugFileName)
        it "should have a #{rallyAppBuilder.build.appExternalFileName}", ()->
          assert(fs.existsSync appExternalFileName)

        describe "in the #{rallyAppBuilder.build.appFileName}", ()->
          appFile = ""
          before ()->
            appFile = fs.readFileSync(appFileName, "utf-8")

          it "should contain the string from the  Custom App File", ()->
            assert(appFile.match /Custom App File/)

          it "should contain the string from the CSS file", ()->
            assert(appFile.match /[.]app[{]/)

          it "should contain the string from the CustomCard file", ()->
            assert(appFile.match /customcard/)

          it "should contain the string from the parent collection", ()->
            assert(appFile.match /ferentchak.*ninjas/)

          it "should contain the processed coffeescript file", ()->
            assert(appFile.match /CoffeeCard/)

          it "should have the fully qualified sdk in the debug file", ()->
            file = fs.readFileSync appDebugFileName, "utf-8"
            assert(file.match /https:\/\/rally1\.rallydev\.com/)

          it "should have the fully qualified sdk in the external file", ()->
            file = fs.readFileSync appExternalFileName, "utf-8"
            assert(file.match /https:\/\/rally1\.rallydev\.com/)

        describe "in the #{rallyAppBuilder.build.appUncompressedFileName}", ()->
          appFile = ""
          before ()->
            appFile = fs.readFileSync(appUncompressedFileName, "utf-8")
            console.log appUncompressedFileName

          it "should still have the comment string since it is unminified", ()->
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

      describe 'with less files', ()->
        before (done)->
          config = path: sdk2WithLessDirectory
          rallyAppBuilder.build config, done

        createBuildAssert sdk2WithLessDirectory

        describe 'the built app file', ->
          appFileContents = ''
          before () ->
            appFileName = path.join sdk2WithLessDirectory, "deploy", rallyAppBuilder.build.appFileName
            appFileContents = fs.readFileSync appFileName, "utf-8"

          it 'should contain app.css styles', ->
            assert appFileContents.indexOf('.app{') != -1

          it 'should contain app.less styles', ->
            assert appFileContents.indexOf('.app-less-style{') != -1
            assert appFileContents.indexOf('.x-foo{') != -1

        describe 'the built uncompressed app file', ->
          appFileContents = ''
          before () ->
            appFileName = path.join sdk2WithLessDirectory, "deploy", rallyAppBuilder.build.appUncompressedFileName
            appFileContents = fs.readFileSync appFileName, "utf-8"

          it 'should contain app.css styles', ->
            assert appFileContents.indexOf('.app {') != -1

          it 'should contain app.less styles', ->
            assert appFileContents.indexOf('.app-less-style {') != -1
            assert appFileContents.indexOf('.x-foo {') != -1

        describe 'the app debug file', ->
          appFileContents = ''
          before () ->
            appFileName = path.join sdk2WithLessDirectory, rallyAppBuilder.build.appDebugFileName
            appFileContents = fs.readFileSync appFileName, "utf-8"

          it 'should contain app.css', ->
            assert appFileContents.indexOf('<link rel="stylesheet" type="text/css" href="app.css"/>') != -1

          it 'should contain app.less.css', ->
            assert appFileContents.indexOf('<link rel="stylesheet" type="text/css" href="app.less.css"/>') != -1

    describe 'with new SDK specified', ()->
      appDebugFileName = ""
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
      appDebugFileContents = ""
      appFileContents = ""
      before (done)->
        config = path: sdk2WithExternalJavaScript
        rallyAppBuilder.build config, (error)->
          appDebugFileName = path.join(sdk2WithExternalJavaScript, rallyAppBuilder.build.appDebugFileName)
          appDebugFileContents = file = fs.readFileSync appDebugFileName, "utf-8"
          appFileName = path.join(sdk2WithExternalJavaScript,"deploy", rallyAppBuilder.build.appFileName)
          appFileContents = file = fs.readFileSync appFileName, "utf-8"
          done(error)

      describe "debug file", ()->

        it "should have a link to underscore", ()->
          assert(appDebugFileContents.indexOf("cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js") >= 0)

        it "should have a link to secret js using https", ()->
          assert(appDebugFileContents.indexOf("https://www.secure.com/secret.js") >= 0)

        it "should have a link to stuff js using http",  ()->
          assert(appDebugFileContents.indexOf("http://www.regular.com/stuff.js") >= 0)

    describe 'with external styles specified', ()->
      appDebugFileContents = ""
      appFileContents = ""
      before (done)->
        config = path: sdk2WithExternalStylesDirectory
        rallyAppBuilder.build config, (error)->
          appDebugFileName = path.join(sdk2WithExternalStylesDirectory, rallyAppBuilder.build.appDebugFileName)
          appDebugFileContents = file = fs.readFileSync appDebugFileName, "utf-8"
          appFileName = path.join(sdk2WithExternalStylesDirectory,"deploy", rallyAppBuilder.build.appFileName)
          appFileContents = file = fs.readFileSync appFileName, "utf-8"
          done(error)

      describe "debug file", ()->

        it "should have a link to underscore", ()->
          assert(appDebugFileContents.indexOf("cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore.css") >= 0)

        it "should have a link to secret js using https", ()->
          assert(appDebugFileContents.indexOf("https://www.secure.com/secret.css") >= 0)

        it "should have a link to stuff js using http",  ()->
          assert(appDebugFileContents.indexOf("http://www.regular.com/stuff.css") >= 0)

    describe 'with build scripts', ->
      
      beforeEach ->
        @config = require('../lib/config')

        @sandbox = sinon.sandbox.create()
        @sandbox.stub(rallyAppBuilder.build, 'runBuild')
        @sandbox.stub(rallyAppBuilder.build, 'runScript')
        @sandbox.stub(@config, 'getConfig')

      afterEach ->
        @sandbox.restore()

      it 'should invoke the prebuild step before building the app', (done)->
        @config.getConfig.yields(null, {})
        rallyAppBuilder.build.runBuild.yields(null, {})
        rallyAppBuilder.build.runScript.yields(null, {})
        rallyAppBuilder.build {}, (err)->
          assert(not err?)
          preBuild = rallyAppBuilder.build.runScript.withArgs(sinon.match.any, sinon.match.any, 'prebuild', sinon.match.any)
          assert(preBuild.calledBefore(rallyAppBuilder.build.runBuild))
          done()

      it 'should invoke the postbuild step after building the app', (done)->
        @config.getConfig.yields(null, {})
        rallyAppBuilder.build.runBuild.yields(null, {})
        rallyAppBuilder.build.runScript.yields(null, {})
        rallyAppBuilder.build {}, (err)->
          assert(not err?)
          postBuild = rallyAppBuilder.build.runScript.withArgs(sinon.match.any, sinon.match.any, 'postbuild', sinon.match.any)
          assert(rallyAppBuilder.build.runBuild.calledBefore(postBuild))
          done()

  describe 'running build scripts', ->
    beforeEach ->
      @sandbox = sinon.sandbox.create()
      @sandbox.stub(shell, 'pushd')
      @sandbox.stub(shell, 'popd')
      @sandbox.stub(shell, 'exec').yields()

    afterEach ->
      @sandbox.restore()
    
    it 'should push and pop the app path directory', (done)->
      rallyAppBuilder.build.runScript {scripts: {prebuild: 'cmd'}}, 'appPath', 'prebuild', (err)->
        assert(shell.pushd.calledWith('appPath'))
        assert(shell.pushd.calledBefore(shell.exec))
        assert(shell.popd.called)
        assert(shell.exec.calledBefore(shell.popd))
        done()
    
    it 'should exec the script step', (done)->
      rallyAppBuilder.build.runScript {scripts: {prebuild: 'cmd'}}, 'appPath', 'prebuild', (err)->
        assert(shell.exec.calledWith('cmd'))       
        done()

    it 'should error if attempting and undefined step', (done)->
      rallyAppBuilder.build.runScript {scripts: {prebuild: 'cmd'}}, 'appPath', 'foo', (err)->
        assert(err?)
        done()

    it 'should callback without error if the step is undefined in configuration', (done)->
      rallyAppBuilder.build.runScript {}, 'appPath', 'prebuild', (err)->
        assert(not err?)
        assert(not shell.exec.called)
        done()

