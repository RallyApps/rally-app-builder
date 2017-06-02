let assert = require('assert');
let css = require('../lib/build/css');

describe('CSS', function() {

  describe('#isLessFile', function() {

    it('should return true for a less file', () => assert(css.isLessFile('app.less')));

    return it('should return false for a css file', () => assert(!css.isLessFile('app.css')));
  });

  describe('#getGeneratedFileName', function() {

    it('should return the same name for a css file', () => assert('app.css' === css.getGeneratedFileName('app.css')));

    return it('should return the corect name for a less file', () => assert('app.less.css' === css.getGeneratedFileName('app.less.css')));
  });

  describe('#compile', function() {

    it('should replace the global prefix var', function(done) {
      let style = '.@{prefix}foo{padding:5px;}';
      return css.compile(style, false, function(err, result) {
        assert(result.indexOf('.x-') === 0);
        return done();
      });
    });

    it('should call the error callback', done =>
      css.compile('blerg!', false, function(err, result) {
        assert(err !== null);
        return done();
      })
    );

    it('should compress', function(done) {
      let style = '.foo{\npadding:5px;\n}';
      return css.compile(style, true, function(err, result) {
        assert('.foo{padding:5px}' === result);
        return done();
      });
    });

    return it('should not compress', function(done) {
      let style = '.foo{\npadding:5px;\n}';
      return css.compile(style, false, function(err, result) {
        assert(result.indexOf('\n') !== -1);
        return done();
      });
    });
  });

  return describe('#compileInPlace', function() {
    let fs = require('fs');
    let path = require('path');
    let fsextra = require('fs-extra');
    let tempTestDirectory = 'test/buildTemp';
    beforeEach(function() {
      fsextra.removeSync(tempTestDirectory);
      return fs.mkdirSync(tempTestDirectory);
    });

    it('should leave a css file alone', function(done) {
      let style = '.foo{\npadding:5px;\n}';
      let file = path.join(tempTestDirectory, 'foo.css');
      return fs.writeFile(file, style, err =>
        css.compileInPlace(file, false, function(err, content) {
          assert(content === file);
          return done();
        })
      );
    });

    return it('should compile the less file in place', function(done) {
      let style = '.foo{\npadding:5px;\n}';
      let file = path.join(tempTestDirectory, 'foo.less');
      return fs.writeFile(file, style, err =>
        css.compileInPlace(file, false, function(err, content) {
          let writtenFile = css.getGeneratedFileName(file);
          assert(content === writtenFile);
          assert(fs.existsSync(writtenFile));
          return done();
        })
      );
    });
  });
});
