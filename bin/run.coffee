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
  {templates} = args
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
  {templates} = args
  RallyAppBuilder.watch {templates}

run = (args) ->
  {port} = args
  port = args._[1] || port
  RallyAppBuilder.run {port}

yargs
  .command(
    'init',
    'Creates a new Rally App project template.',
    name: {alias: 'n', describe: 'The name of the app'}
    version: {alias: 'v', describe: 'The SDK version to target', default: '2.0'}
    server: {alias: 's', describe: 'The server to target'}
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
    , watch
  )
  .command(
    'run',
    'Start a local server and launch the current app in the default browser.',
    port: {alias: 'p', default: 1337, describe: 'The port on which to start the local http server'}
    , run
  )
  .help()
  .argv
