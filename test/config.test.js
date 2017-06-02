let assert = require('assert');
let config = require('../lib/config');
let path = require('path');

describe('Config', function(){
  describe('Updates Config', function(){
    let testConfig = {
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
    };

    let updatedConfig = config._updateConfig(testConfig);
    return it("should add a server to the config file if one is not present",
    ()=> assert(updatedConfig.server === "https://rally1.rallydev.com"));
  });

  return describe('#getAppSourceRoot', function() {

    it('handles basic case', function(done) {
      let sdk2TestDirectory = path.join(__dirname, 'fixtures', 'sdk2');
      return config.getAppSourceRoot(sdk2TestDirectory, function(err, srcRoot) {
        assert(srcRoot === sdk2TestDirectory);
        return done();
      });
    });

    return it('handles complicated case', function(done) {
      let sd2WithParentFiles = path.join(__dirname, 'fixtures', 'sdk2WithParentPaths', 'b', 'c');
      return config.getAppSourceRoot(sd2WithParentFiles, function(err, srcRoot) {
        assert(srcRoot === path.resolve(path.join(__dirname, 'fixtures', 'sdk2WithParentPaths')));
        return done();
      });
    });
  });
});
