let chokidar = require('chokidar');
let build = require('./build');
let test = require('./test');
let config = require('./config');

let watcher = null;

function watch(args) {
    let { templates, ci } = args;
    console.log('\nWatching for changes...');
    let appPath = args.path || process.cwd();
    return config.getAppSourceRoot(appPath, (error, srcRoot) => {
        watcher = chokidar.watch(srcRoot, { ignored: '**/*.html', usePolling: true, interval: 500 });
        return watcher.on('change', (path) => {
            console.log('\nChange detected:', path);
            return onChange({ templates, ci });
        });
    });
}

let onChange = function onChange(args) {
    console.log('Rebuilding...\n');
    let path = process.cwd();
    let { templates, ci } = args;
    watcher.close();
    return build({ templates, path }, (err) => {
        if (!err && ci) { test({}); }
        return watch({ templates, ci });
    });
};


module.exports = watch;
