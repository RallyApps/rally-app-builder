let assert = require('assert');
let rallyAppBuilder = require('../index');
let fs = require('fs');
let fsextra = require('fs-extra');
let path = require('path');
let sinon = require('sinon');
let shell = require('shelljs');

let tempTestDirectory = 'test/buildTemp';
let fixturesDirectory = path.join(__dirname, 'fixtures');

let sdk2TestDirectory = path.join(tempTestDirectory, 'sdk2');
let sdk2CustomSdkVersionDirectory = path.join(tempTestDirectory, 'sdk2CustomSdkVersion');
let sdk2WithExternalJavaScript = path.join(tempTestDirectory, 'sdk2WithExternalJavaScript');
let sdk2WithLessDirectory = path.join(tempTestDirectory, 'sdk2less');
let sdk2WithExternalStylesDirectory = path.join(tempTestDirectory, 'sdk2WithExternalStyles');

describe('Build an App', function () {
  before(function (done) {
    try {
      let copy = () => fsextra.copy(fixturesDirectory, tempTestDirectory, done);
      return fs.mkdir(tempTestDirectory, copy);
    } catch (e) { }
  });
  after(done => done());

  describe('with AppSDK 2.0', function () {
    describe('basic functionality', function () {
      let createBuildAssert = function (baseDirectory) {
        let appFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appFileName);
        let appUncompressedFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appUncompressedFileName);
        let appExternalFileName = path.join(baseDirectory, "deploy", rallyAppBuilder.build.appExternalFileName);
        let appDebugFileName = path.join(baseDirectory, rallyAppBuilder.build.appDebugFileName);
        let appFile = "";
        it(`should have a ${rallyAppBuilder.build.appFileName}`, () => assert(fs.existsSync(appFileName)));
        it(`should have a ${rallyAppBuilder.build.appUncompressedFileName}`, () => assert(fs.existsSync(appUncompressedFileName)));
        it(`should have a ${rallyAppBuilder.build.appDebugFileName}`, () => assert(fs.existsSync(appDebugFileName)));
        it(`should have a ${rallyAppBuilder.build.appExternalFileName}`, () => assert(fs.existsSync(appExternalFileName)));

        describe(`in the ${rallyAppBuilder.build.appFileName}`, function () {
          appFile = "";
          before(() => appFile = fs.readFileSync(appFileName, "utf-8"));

          it("should contain the string from the  Custom App File", () => assert(appFile.match(/Custom App File/)));

          it("should contain the string from the CSS file", () => assert(appFile.match(/[.]app[{]/)));

          it("should contain the string from the CustomCard file", () => assert(appFile.match(/customcard/)));

          it("should contain the string from the parent collection", () => assert(appFile.match(/ferentchak.*ninjas/)));

          it("should contain the processed coffeescript file", () => assert(appFile.match(/CoffeeCard/)));

          it("should have the fully qualified sdk in the debug file", function () {
            let file = fs.readFileSync(appDebugFileName, "utf-8");
            return assert(file.match(/https:\/\/rally1\.rallydev\.com/));
          });

          return it("should have the fully qualified sdk in the external file", function () {
            let file = fs.readFileSync(appExternalFileName, "utf-8");
            return assert(file.match(/https:\/\/rally1\.rallydev\.com/));
          });
        });

        return describe(`in the ${rallyAppBuilder.build.appUncompressedFileName}`, function () {
          appFile = "";
          before(function () {
            appFile = fs.readFileSync(appUncompressedFileName, "utf-8");
            return console.log(appUncompressedFileName);
          });

          return it("should still have the comment string since it is unminified", () => assert(appFile.match(/Important Comment/)));
        });
      };

      describe('that has JavaScript files', function () {
        before(function (done) {
          let config = { path: sdk2TestDirectory };
          return rallyAppBuilder.build(config, done);
        });
        return createBuildAssert(sdk2TestDirectory);
      });

      describe('that has already been built', function () {
        before(function (done) {
          let config = { path: sdk2TestDirectory };
          return rallyAppBuilder.build(config, done);
        });
        return createBuildAssert(sdk2TestDirectory);
      });

      return describe('with less files', function () {
        before(function (done) {
          let config = { path: sdk2WithLessDirectory };
          return rallyAppBuilder.build(config, done);
        });

        createBuildAssert(sdk2WithLessDirectory);

        describe('the built app file', function () {
          let appFileContents = '';
          before(function () {
            let appFileName = path.join(sdk2WithLessDirectory, "deploy", rallyAppBuilder.build.appFileName);
            return appFileContents = fs.readFileSync(appFileName, "utf-8");
          });

          it('should contain app.css styles', () => assert(appFileContents.indexOf('.app{') !== -1));

          return it('should contain app.less styles', function () {
            assert(appFileContents.indexOf('.app-less-style{') !== -1);
            return assert(appFileContents.indexOf('.x-foo{') !== -1);
          });
        });

        describe('the built uncompressed app file', function () {
          let appFileContents = '';
          before(function () {
            let appFileName = path.join(sdk2WithLessDirectory, "deploy", rallyAppBuilder.build.appUncompressedFileName);
            return appFileContents = fs.readFileSync(appFileName, "utf-8");
          });

          it('should contain app.css styles', () => assert(appFileContents.indexOf('.app {') !== -1));

          return it('should contain app.less styles', function () {
            assert(appFileContents.indexOf('.app-less-style {') !== -1);
            return assert(appFileContents.indexOf('.x-foo {') !== -1);
          });
        });

        return describe('the app debug file', function () {
          let appFileContents = '';
          before(function () {
            let appFileName = path.join(sdk2WithLessDirectory, rallyAppBuilder.build.appDebugFileName);
            return appFileContents = fs.readFileSync(appFileName, "utf-8");
          });

          it('should contain app.css', () => assert(appFileContents.indexOf('<link rel="stylesheet" type="text/css" href="app.css"/>') !== -1));

          return it('should contain app.less.css', () => assert(appFileContents.indexOf('<link rel="stylesheet" type="text/css" href="app.less.css"/>') !== -1));
        });
      });
    });

    describe('with new SDK specified', function () {
      let appDebugFileName = "";
      before(function (done) {
        let config = { path: sdk2CustomSdkVersionDirectory };
        rallyAppBuilder.build(config, done);
        return appDebugFileName = path.join(sdk2CustomSdkVersionDirectory, rallyAppBuilder.build.appDebugFileName);
      });

      it(`should have a ${rallyAppBuilder.build.appDebugFileName}`, () => assert(fs.existsSync(appDebugFileName)));

      return it("should have the correct sdk debug file name", function () {
        let file = fs.readFileSync(appDebugFileName, "utf-8");
        return assert(file.match(/https:\/\/testserver\.konami\.com/));
      });
    });

    describe('with external JavaScript files specified', function () {
      let appDebugFileContents = "";
      let appFileContents = "";
      before(function (done) {
        let config = { path: sdk2WithExternalJavaScript };
        return rallyAppBuilder.build(config, function (error) {
          let file;
          let appDebugFileName = path.join(sdk2WithExternalJavaScript, rallyAppBuilder.build.appDebugFileName);
          appDebugFileContents = (file = fs.readFileSync(appDebugFileName, "utf-8"));
          let appFileName = path.join(sdk2WithExternalJavaScript, "deploy", rallyAppBuilder.build.appFileName);
          appFileContents = (file = fs.readFileSync(appFileName, "utf-8"));
          return done(error);
        });
      });

      return describe("debug file", function () {

        it("should have a link to underscore", () => assert(appDebugFileContents.indexOf("cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js") >= 0));

        it("should have a link to secret js using https", () => assert(appDebugFileContents.indexOf("https://www.secure.com/secret.js") >= 0));

        return it("should have a link to stuff js using http", () => assert(appDebugFileContents.indexOf("http://www.regular.com/stuff.js") >= 0));
      });
    });

    describe('with external styles specified', function () {
      let appDebugFileContents = "";
      let appFileContents = "";
      before(function (done) {
        let config = { path: sdk2WithExternalStylesDirectory };
        return rallyAppBuilder.build(config, function (error) {
          let file;
          let appDebugFileName = path.join(sdk2WithExternalStylesDirectory, rallyAppBuilder.build.appDebugFileName);
          appDebugFileContents = (file = fs.readFileSync(appDebugFileName, "utf-8"));
          let appFileName = path.join(sdk2WithExternalStylesDirectory, "deploy", rallyAppBuilder.build.appFileName);
          appFileContents = (file = fs.readFileSync(appFileName, "utf-8"));
          return done(error);
        });
      });

      return describe("debug file", function () {

        it("should have a link to underscore", () => assert(appDebugFileContents.indexOf("cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore.css") >= 0));

        it("should have a link to secret js using https", () => assert(appDebugFileContents.indexOf("https://www.secure.com/secret.css") >= 0));

        return it("should have a link to stuff js using http", () => assert(appDebugFileContents.indexOf("http://www.regular.com/stuff.css") >= 0));
      });
    });

    return describe('with build scripts', function () {

      beforeEach(function () {
        this.config = require('../lib/config');

        this.sandbox = sinon.sandbox.create();
        this.sandbox.stub(rallyAppBuilder.build, 'runBuild');
        this.sandbox.stub(rallyAppBuilder.build, 'runScript');
        return this.sandbox.stub(this.config, 'getConfig');
      });

      afterEach(function () {
        return this.sandbox.restore();
      });

      it('should invoke the prebuild step before building the app', function (done) {
        this.config.getConfig.yields(null, {});
        rallyAppBuilder.build.runBuild.yields(null, {});
        rallyAppBuilder.build.runScript.yields(null, {});
        return rallyAppBuilder.build({}, function (err) {
          assert((err == null));
          let preBuild = rallyAppBuilder.build.runScript.withArgs(sinon.match.any, sinon.match.any, 'prebuild', sinon.match.any);
          assert(preBuild.calledBefore(rallyAppBuilder.build.runBuild));
          return done();
        });
      });

      return it('should invoke the postbuild step after building the app', function (done) {
        this.config.getConfig.yields(null, {});
        rallyAppBuilder.build.runBuild.yields(null, {});
        rallyAppBuilder.build.runScript.yields(null, {});
        return rallyAppBuilder.build({}, function (err) {
          assert((err == null));
          let postBuild = rallyAppBuilder.build.runScript.withArgs(sinon.match.any, sinon.match.any, 'postbuild', sinon.match.any);
          assert(rallyAppBuilder.build.runBuild.calledBefore(postBuild));
          return done();
        });
      });
    });
  });

  return describe('running build scripts', function () {
    beforeEach(function () {
      this.sandbox = sinon.sandbox.create();
      this.sandbox.stub(shell, 'pushd');
      this.sandbox.stub(shell, 'popd');
      return this.sandbox.stub(shell, 'exec').yields();
    });

    afterEach(function () {
      return this.sandbox.restore();
    });

    it('should push and pop the app path directory', done =>
      rallyAppBuilder.build.runScript({ scripts: { prebuild: 'cmd' } }, 'appPath', 'prebuild', function (err) {
        assert(shell.pushd.calledWith('appPath'));
        assert(shell.pushd.calledBefore(shell.exec));
        assert(shell.popd.called);
        assert(shell.exec.calledBefore(shell.popd));
        return done();
      })
    );

    it('should exec the script step', done =>
      rallyAppBuilder.build.runScript({ scripts: { prebuild: 'cmd' } }, 'appPath', 'prebuild', function (err) {
        assert(shell.exec.calledWith('cmd'));
        return done();
      })
    );

    it('should error if attempting and undefined step', done =>
      rallyAppBuilder.build.runScript({ scripts: { prebuild: 'cmd' } }, 'appPath', 'foo', function (err) {
        assert(err != null);
        return done();
      })
    );

    return it('should callback without error if the step is undefined in configuration', done =>
      rallyAppBuilder.build.runScript({}, 'appPath', 'prebuild', function (err) {
        assert((err == null));
        assert(!shell.exec.called);
        return done();
      })
    );
  });
});
