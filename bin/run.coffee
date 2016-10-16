fs = require('fs')
path = require('path')
yargs = require('yargs');
RallyAppBuilder = require("../lib/")

errorHandler = (error) ->
  if error
    console.error '\r\nBuild aborted due to error.'
  else
    console.log 'Success'

build = (args) ->
  {templates} = args
  console.log 'Compiling the App.'
  RallyAppBuilder.build {templates}, errorHandler

init = (args) ->
  {name, sdk, server, templates} = args
  name = args._[1] || name
  sdk_version = args._[2] || sdk
  server = args._[3] || server
  console.log 'Creating a new App.'
  RallyAppBuilder.init(
    {name, sdk_version, server, templates},
    (error) ->
      if error
        errorHandler error
      else
        build {templates}
  )

clone = (args) ->
  {org, repo, templates} = args
  organization = args._[1] || org
  repo = args._[2] || repo
  if !organization
    console.error 'Please specify an organization when using the clone command.'
    return
  if !repo
    console.error 'Please specify a repo when using the clone command.'
    return
  console.log "Cloning #{repo} repo from #{organization} account"
  RallyAppBuilder.clone(
    {organization, repo},
    (error) ->
      if error
        errorHandler error
      else
        build {templates}
  )

watch = (args) ->
  {templates, ci} = args
  RallyAppBuilder.watch {templates, ci}

run = (args) ->
  {port} = args
  port = args._[1] || port
  RallyAppBuilder.run {port}

test = (args) ->
  {debug, spec} = args
  RallyAppBuilder.test {debug, spec}

yargs
  .command(
    'init',
    'Creates a new Rally App project template.',
    name: {alias: 'n', describe: 'The name of the app'}
    sdk: {alias: 's', describe: 'The SDK version to target', default: '2.1'}
    server: {alias: 'r', describe: 'The server to target'}
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}
    , init
  )
  .command(
    'build',
    'Builds the current App.',
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}
    , build
  )
  .command(
    'clone',
    'Creates a new Rally App project locally from an existing GitHub project.',
    org: {alias: 'o', describe: 'The GitHub organization'}
    repo: {alias: 'r', describe: 'The GitHub repo name'}
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}
    , clone
  )
  .command(
    'watch',
    'Watch the current app files for changes and automatically rebuild it.',
    templates: {alias: 't', describe: 'The path containing custom html output templates (advanced)'}
    ci: { alias: 'c', describe: 'Also run the tests on each change after rebuilding the app'}
    , watch
  )
  .command(
    'run',
    'Start a local server and launch the current app in the default browser.',
    port: {alias: 'p', default: 1337, describe: 'The port on which to start the local http server'}
    , run
  )
  .command(
    'test',
    'Run the tests for the current app.',
    debug: {alias: 'd', describe: 'If specified tests will be run in the default browser rather than headlessly.'}
    spec: {alias: 's', describe: 'Specific test file name or glob pattern to run.  If not specified all tests will be run.'}
    , test
  )
  .help().alias('h', 'help')
  .version().alias('v', 'version')
  .argv
