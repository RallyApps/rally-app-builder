assert = require 'assert'
css = require '../lib/build/css'

describe 'CSS', ->

  describe '#isLessFile', ->

    it 'should return true for a less file', ->
      assert css.isLessFile 'app.less'

    it 'should return false for a css file', ->
      assert !css.isLessFile 'app.css'

  describe '#getGeneratedFileName', ->

    it 'should return the same name for a css file', ->
      assert 'app.css' == css.getGeneratedFileName 'app.css'

    it 'should return the corect name for a less file', ->
      assert 'app.less.css' == css.getGeneratedFileName 'app.less.css'

  describe '#compile', ->

    it 'should replace the global prefix var', (done) ->
      style = '.@{prefix}foo{padding:5px;}'
      css.compile style, false, (err, result) ->
        assert result.indexOf('.x-') == 0
        done()

    it 'should call the error callback', (done) ->
      css.compile 'blerg!', false, (err, result) ->
        assert err != null
        done()

    it 'should compress', (done) ->
      style = '.foo{\npadding:5px;\n}'
      css.compile style, true, (err, result) ->
        assert '.foo{padding:5px}' == result
        done()

    it 'should not compress', (done) ->
      style = '.foo{\npadding:5px;\n}'
      css.compile style, false, (err, result) ->
        assert result.indexOf('\n') != -1
        done()

  describe '#compileInPlace', ->
    fs = require 'fs'
    path = require 'path'
    wrench = require 'wrench'
    tempTestDirectory = 'test/buildTemp'
    beforeEach ->
      wrench.rmdirSyncRecursive tempTestDirectory
      fs.mkdirSync tempTestDirectory

    it 'should leave a css file alone', (done) ->
      style = '.foo{\npadding:5px;\n}'
      file = path.join tempTestDirectory, 'foo.css'
      fs.writeFile file, style, (err) ->
        css.compileInPlace file, false, (err, content) ->
          assert content == file
          done()

    it 'should compile the less file in place', (done) ->
      style = '.foo{\npadding:5px;\n}'
      file = path.join tempTestDirectory, 'foo.less'
      fs.writeFile file, style, (err) ->
        css.compileInPlace file, false, (err, content) ->
          writtenFile = css.getGeneratedFileName file
          assert content == writtenFile
          assert fs.existsSync writtenFile
          done()

