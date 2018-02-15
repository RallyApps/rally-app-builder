let _ = require('lodash');
let fs = require('fs');
let pathUtil = require('path');
let async = require('async');
let mustache = require('mustache');
let getScript = require('./get-script');
let css = require('./css');
let shell = require('shelljs');

let appFileName = "App.html";
let appExternalFileName = "App-external.html";
let appUncompressedFileName = "App-uncompressed.html";
let appDebugFileName = "App-debug.html";
let deployFilePath = "deploy";
let templateDirectory = pathUtil.resolve(__dirname, '../../templates/');

let configModule = require('../config');

let runScript = function(configJson, appPath, step, callback){
  if (!['prebuild', 'postbuild'].includes(step)) { return callback(`Unknown script step ${step}`); }
  let script = __guard__(configJson != null ? configJson.scripts : undefined, x => x[step]);
  if (script != null) {
    console.log(`Running ${step} script: '${script}'`);
    shell.pushd(appPath);
    return shell.exec(script, function(err){
      shell.popd();
      return callback(err);
    });
  } else {
    return callback();
  }
};

let createDeployFile = function({appPath, templateData, templateFileName, directory}, callback){
  console.log(`Creating ${templateFileName}`);
  let templateBase = templateData.templates;
  let appTemplate = fs.readFileSync(pathUtil.join(templateBase, templateFileName), "utf-8");
  let fullDeployFilePath = pathUtil.resolve(appPath, directory);
  let filePath = pathUtil.join(fullDeployFilePath, templateFileName);
  if(!fs.existsSync(fullDeployFilePath)) {
    fs.mkdirSync(fullDeployFilePath);
  }
  let compiledApp = mustache.render(appTemplate, templateData);
  return fs.writeFile(filePath, compiledApp, callback);
};

let buildDeployFiles = function({appPath, templateData, appFileName, appExternalFileName, appDebugFileName, appUncompressedFileName }, callback){
  let templateBase = templateData.templates;
  return async.forEach(
    [
      {templateFileName: appDebugFileName, directory: '.'},
      {templateFileName: appFileName, directory: deployFilePath},
      {templateFileName: appExternalFileName, directory: deployFilePath},
      {templateFileName: appUncompressedFileName, directory: deployFilePath, compress:false}
    ],
    function(options, cb){
      options = _.extend({
        appPath,
        templateData
      }, options);
      return createDeployFile(options, cb);
    },
    callback
  );
};

let runBuild = (configJson, appPath, callback) => {
  configModule.getPackageJson(appPath, function(error, packageJson) {
    getScript.getFiles({configJson, appPath,compress:false},
      function(err, {javascript_files, css_files, remote_javascript_files, local_javascript_files, uncompressed_javascript_files, uncompressed_css_files, css_file_names, html_files, remote_css_files}){
        if (err) {
          return callback(err);
        } else { 
          configJson.javascript_files = javascript_files;
          configJson.css_file_names = css_file_names;
          configJson.css_files = css_files;
          configJson.uncompressed_css_files = uncompressed_css_files;
          configJson.remote_javascript_files = remote_javascript_files;
          configJson.local_javascript_files = local_javascript_files;
          configJson.uncompressed_javascript_files = uncompressed_javascript_files;
          configJson.html_files = html_files;
          configJson.remote_css_files = remote_css_files;
          configJson.version = packageJson.version;
          return async.forEach(configJson.css, function(c, callback) {
            let cssPath = pathUtil.resolve(appPath, c);
            return css.compileInPlace(cssPath, false, callback);
          }
          , function(err){
            if (err) { return callback(err);
            } else {
              let options = {
                appPath,
                templateData: configJson,
                appFileName,
                appDebugFileName,
                appUncompressedFileName,
                appExternalFileName
              };
              return buildDeployFiles(options, callback);
            }
          });
        }
    });
  });
}

module.exports = function({path,templates}, callback){
  try {
    callback = callback || function(){};
    let appPath = path || process.cwd();
    return configModule.getConfig(appPath, function(error, configJson){
      if (error) { return callback(error);
      } else {
        configJson = _.defaults(configJson,
          {templates: templates || pathUtil.join(templateDirectory, 'deploy')});
        return async.series([
          callback=> module.exports.runScript(configJson, appPath, 'prebuild', callback),
          callback=> module.exports.runBuild(configJson, appPath, callback),
          callback=> module.exports.runScript(configJson, appPath, 'postbuild', callback)
        ]
        , err=> callback(err));
      }
    });
  } catch (error1) {
    let error = error1;
    return callback(error);
  }
};

//exports constants
_.defaults(module.exports, {configFileName: configModule.configFileName, appFileName, deployFilePath, appDebugFileName, appUncompressedFileName, appExternalFileName, runScript, runBuild});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}