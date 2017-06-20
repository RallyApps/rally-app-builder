assert = require 'assert'
config = require '../lib/config'
path = require 'path'

describe 'Config', ()->

  describe '#getAppSourceRoot', () ->

    it 'handles basic case', (done) ->
      sdk2TestDirectory = path.join(__dirname, 'fixtures', 'sdk2')
      config.getAppSourceRoot sdk2TestDirectory, (err, srcRoot) ->
        assert srcRoot == sdk2TestDirectory
        done()

    it 'handles complicated case', (done) ->
      sd2WithParentFiles = path.join(__dirname, 'fixtures', 'sdk2WithParentPaths', 'b', 'c')
      config.getAppSourceRoot sd2WithParentFiles, (err, srcRoot) ->
        assert srcRoot == path.resolve path.join __dirname, 'fixtures', 'sdk2WithParentPaths'
        done()
