let _ = require('lodash');
let fs = require('fs');
let pathUtils = require('path');

let configFileName = 'config.json';

let convertToJson = function(callback) {
  return function (error, file) {
    if (!error) {
        let config = JSON.parse(file);
        callback(null, config);
    } else {
        callback(error);
    }
  }
};

let getConfig = function (path, callback) {
    let configPath = pathUtils.join(path, configFileName);
    if (!fs.existsSync(configPath)) {
        console.log('A config.json not found using current directory');
        callback(null, process.cwd());
    } else {
        fs.readFile(configPath, 'utf-8', convertToJson(callback));
    }
};

let getPackageJson = function (path, callback) {
  let packageJsonPath = pathUtils.join(path, "package.json");
  if (!fs.existsSync(packageJsonPath)) {
      console.log('A package.json not found using current directory');
      callback(null, { version: ''});
  } else {
      fs.readFile(packageJsonPath, 'utf-8', convertToJson(callback));
  }
};


let getAppSourceRoot = (path, callback) =>
    getConfig(path, (err, config) => {
        let root = pathUtils.resolve(path);
        let localFiles = _.filter(config.javascript, jsFile => !jsFile.match(/^.*\/\//));
        let dirNames = localFiles.map(appFilePath => pathUtils.dirname(pathUtils.resolve(pathUtils.join(root, appFilePath))));
        while (!_.every(dirNames, dir => dir.indexOf(root) === 0)) {
            root = pathUtils.resolve(root, '..');
        }
        callback(null, root);
    });



module.exports = { getConfig, getAppSourceRoot, getPackageJson };
_.defaults(module.exports, { configFileName });
