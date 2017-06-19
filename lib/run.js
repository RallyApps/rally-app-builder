const open = require('open');
const express = require('express');
const _ = require('lodash');
const app = express();
const path = require('path');
const serveStatic = require('serve-static');
const configModule = require('./config');

module.exports = function (args) {
  let appPath = args.path || process.cwd();
  return configModule.getAppSourceRoot(appPath, function (error, srcRoot) {
    let pathToApp = path.relative(srcRoot, appPath);
    if (pathToApp) { pathToApp = `/${pathToApp}`; }
    app.use(express.static(srcRoot));
    app.listen(args.port, (err) => {
      if(!err) return;
      console.error("Error in server start");
      console.error(err);
    });
    let url = `http://localhost:${args.port}${pathToApp}/App-debug.html`;
    console.log(`Launching ${url} from ${srcRoot}`);
    return open(url);
  });
};
