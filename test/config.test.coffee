assert = require 'assert'
config = require '../lib/config'

describe('Config', ()->
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

)