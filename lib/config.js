let _ = require('lodash');
let fs = require('fs');
let pathUtils = require('path');

let configFileName = "config.json";

let _updateConfig = function(config){
  config.server = config.server || "https://rally1.rallydev.com";
  return config;
};

let saveConfig = function({path, config}, callback=()=>0 ){
  let configPath = pathUtils.join(path, configFileName);
  return fs.writeFile(configPath, JSON.stringify(config, null, '    '), callback);
};

let getConfig = function(path, callback) {
  let convertToJson = function(error, file){
    if (!error) {
      let config = JSON.parse(file);
      _updateConfig(config);
      saveConfig({config, path});
      return callback(null, config);
    } else {
      return callback(error);
    }
  };

  let configPath = pathUtils.join(path, configFileName);
  if (!fs.existsSync(configPath)) {
    throw new Error(`${configFileName} not found at path ${path}`);
  } else {
    return fs.readFile(configPath, "utf-8", convertToJson);
  }
};

let getAppSourceRoot = (path, callback) =>
  getConfig(path, function(err, config) {
    let root = pathUtils.resolve(path);
    let localFiles = _.filter(config.javascript, jsFile => !jsFile.match(/^.*\/\//));
    let dirNames = localFiles.map(appFilePath => pathUtils.dirname(pathUtils.resolve(pathUtils.join(root, appFilePath))));
    let common = root;
    while(!_.every(dirNames, dir => dir.indexOf(common) === 0)) {
      common = pathUtils.resolve(common, '..');
    }
    return callback(null, common);
  })
;

module.exports = {_updateConfig,getConfig,saveConfig,getAppSourceRoot};
_.defaults(module.exports, {configFileName});
