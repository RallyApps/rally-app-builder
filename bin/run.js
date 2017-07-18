let fs = require('fs');
let path = require('path');
let yargs = require('yargs');
let RallyAppBuilder = require("../lib/");

let errorHandler = function(error) {
  if (error) {
    console.error(`\r\n${error[0] || error}`);
    return console.error('\r\nBuild aborted due to error.');
  } else {
    return console.log('Success');
  }
};

let build = function(args) {
  let {templates} = args;
  console.log('Compiling the App.');
  return RallyAppBuilder.build({templates}, errorHandler);
};

let init = function(args) {
  let {name, sdk, server, templates} = args;
  name = args._[1] || name;
  let sdk_version = args._[2] || sdk;
  server = args._[3] || server;
  console.log('Creating a new App.');
  return RallyAppBuilder.init(
    {name, sdk_version, server, templates},
    function(error) {
      if (error) {
        return errorHandler(error);
      } else {
        return build({templates});
      }
  });
};


let watch = function(args) {
  let {templates, ci} = args;
  return RallyAppBuilder.watch({templates, ci});
};

let run = function(args) {
  let {port} = args;
  port = args._[1] || port;
  return RallyAppBuilder.run({port});
};

let test = function(args) {
  let {debug, spec} = args;
  return RallyAppBuilder.test({debug, spec});
};

yargs
  .command(
    'init',
    'Creates a new Rally App project template.', {
    name: {alias: 'n', describe: 'The name of the app'},
    sdk: {alias: 's', describe: 'The SDK version to target', default: '2.1'},
    server: {alias: 'r', describe: 'The server to target'},
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}
  }
    , init
  )
  .command(
    'build',
    'Builds the current App.',
    {templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}}
    , build
  )
  .command(
    'watch',
    'Watch the current app files for changes and automatically rebuild it.', {
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'},
    ci: { alias: 'c', describe: 'Also run the tests on each change after rebuilding the app'}
  }
    , watch
  )
  .command(
    'run',
    'Start a local server and launch the current app in the default browser.',
    {port: {alias: 'p', default: 1337, describe: 'The port on which to start the local http server'}}
    , run
  )
  .command(
    'test',
    'Run the tests for the current app.', {
    debug: {alias: 'd', describe: 'If specified tests will be run in the default browser rather than headlessly.'},
    spec: {alias: 's', describe: 'Specific test file name or glob pattern to run.  If not specified all tests will be run.'}
  }
    , test
  )
  .help().alias('h', 'help')
  .version().alias('v', 'version')
  .argv;
