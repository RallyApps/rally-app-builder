const open = require('open');
const express = require('express');
const path = require('path');
const configModule = require('./config');

const app = express();

module.exports = function run(args) {
    let appPath = args.path || process.cwd();
    return configModule.getAppSourceRoot(appPath, (error, srcRoot) => {
        let pathToApp = path.relative(srcRoot, appPath);
        if (pathToApp) { pathToApp = `/${pathToApp}`; }
        app.use(express.static(srcRoot));
        app.listen(args.port, (err) => {
            if (!err) return;
            console.error('Error in server start');
            console.error(err);
        });
        let url = `http://localhost:${args.port}${pathToApp}/App-debug.html`;
        console.log(`Launching ${url} from ${srcRoot}`);
        return open(url);
    });
};
