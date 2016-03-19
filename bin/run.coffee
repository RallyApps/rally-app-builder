fs = require('fs')
path = require('path')
yargs = require('yargs');
RallyAppBuilder = require("../lib/")

builder = (error) ->
  if error
    errorHandler error
  else
    RallyAppBuilder.build {}, errorHandler

errorHandler = (error) ->
  if error
    console.error error.message
  else
    console.log 'Success'

init = (args) ->
  {name, version, server} = args
  name = args._[1] || name
  sdk_version = args._[2] || version
  server = args._[3] || server
  console.log "Creating a new App named #{name}."
  RallyAppBuilder.init({name, sdk_version, server}, builder)

build = (args) ->
  console.log 'Compiling the App.'
  RallyAppBuilder.build {}, errorHandler

clone = (args) ->
  {org, repo} = args
  org = args._[1] || name
  repo = args._[2] || name
  if !organization
    console.error 'Please specify an organization when using the clone command.'
    return
  if !repo
    console.error 'Please specify a repo when using the clone command.'
    return
  console.log "Cloning #{repo} repo from #{organization} account"
  RallyAppBuilder.clone {organization,repo}, builder

watch = (args) ->
  RallyAppBuilder.watch()

run = (args) ->
  {port} = args
  port = args._[1] || port
  RallyAppBuilder.run {port}

yargs
  .command(
    'init',
    'Creates a new Rally App project template.',
    name: {alias: 'n', default: 'MyApp'}
    version: {alias: 'v', default: '2.0'}
    server: {alias: 's', default: 'https://rally1.rallydev.com'}
    , init
  )
  .command(
    'build',
    'Builds the current App.',
    {}
    , build
  )
  .command(
    'clone',
    'Creates a new Rally App project locally from an existing GitHub project.',
    org: {alias: 'o'}
    repo: {alias: 'r'}
    , clone
  )
  .command(
    'watch',
    'Watch the current app files for changes and automatically rebuild it.',
    {}
    , watch
  )
  .command(
    'run',
    'Start a local server and launch the current app in the default browser.',
    port: {alias: 'p', default: 1337}
    , run
  )
  .help()
  .argv
