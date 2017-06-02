assert = require 'assert'
config = require '../lib/config'
path = require 'path'

describe 'Config', ()->
  describe('Updates Config', ()->
    testConfig = {
      "name": "CardboardCustomCard",
      "className": "CustomApp",
      "sdk": "2.0p5",
      "javascript": [
        "CustomCard.js",
        "App.js",
        "TestCoffee.coffee"
      ],
      "css": [
        "app.css"
      ],
      "parents": [
        "ferentchak/teamboard",
        "rallyapps/ninjas"
      ]
    }

    updatedConfig = config._updateConfig(testConfig)
    it "should add a server to the config file if one is not present",
    ()->
      assert(updatedConfig.server == "https://rally1.rallydev.com")
  )

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
