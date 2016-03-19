fs = require('fs')
path = require('path')
yargs = require('yargs');
RallyAppBuilder = require("../lib/")

errorHandler = (error) ->
  if error
    console.error error.message
  else
    console.log 'Success'

build = (args) ->
  templates = args.templates
  console.log 'Compiling the App.'
  RallyAppBuilder.build {templates}, errorHandler

init = (args) ->
  {name, version, server, templates} = args
  name = args._[1] || name
  sdk_version = args._[2] || version
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
  templates = args.templates
  RallyAppBuilder.watch {templates}

run = (args) ->
  {port} = args
  port = args._[1] || port
  RallyAppBuilder.run {port}

yargs
  .command(
    'init',
    'Creates a new Rally App project template.',
    name: {alias: 'n'}
    version: {alias: 'v'}
    server: {alias: 's'}
    templates: {alias: 't'}
    , init
  )
  .command(
    'build',
    'Builds the current App.',
    templates: {alias: 't'}
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
    templates: {alias: 't'}
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
