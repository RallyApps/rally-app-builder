let open = require('open');
let express = require('express');
let _ = require('lodash');
let app = express();
let path = require('path');

let configModule = require('./config');

module.exports = function(args) {
  let appPath = args.path || process.cwd();
  return configModule.getAppSourceRoot(appPath, function(error, srcRoot) {
    let pathToApp = path.relative(srcRoot, appPath);
    if (pathToApp) { pathToApp = `/${pathToApp}`; }
    args = _.defaults(args,
      {port: 1337});
    app.use(express.static(srcRoot));
    app.listen(args.port);
    let url = `http://localhost:${args.port}${pathToApp}/App-debug.html`;
    console.log(`Launching ${url}...`);
    return open(url);
  });
};
