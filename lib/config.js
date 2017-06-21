let _ = require('lodash');
let fs = require('fs');
let pathUtils = require('path');

let configFileName = 'config.json';

let getConfig = function (path, callback) {
    let convertToJson = function (error, file) {
        if (!error) {
            let config = JSON.parse(file);
            callback(null, config);
        } else {
            callback(error);
        }
    };

    let configPath = pathUtils.join(path, configFileName);
    if (!fs.existsSync(configPath)) {
        console.log('A config.json not found using current directory');
        callback(null, process.cwd());
    } else {
        fs.readFile(configPath, 'utf-8', convertToJson);
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

module.exports = { getConfig, getAppSourceRoot };
_.defaults(module.exports, { configFileName });
