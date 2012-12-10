fs = require('fs')
path = require ('path')
cmdr = require('commander')
RallyAppBuilder = require("../lib/main")

packageLocation = path.normalize(__dirname+"/../package.json")
version = JSON.parse(fs.readFileSync(packageLocation)).version

cmdr
  .version(version)

cmdr
  .command('init [name] [sdk_version] [server]')
  .description("Creates a new Rally App project")
  .action (name,sdk_version,server)->

    RallyAppBuilder.init
      name:name
      sdk_version:sdk_version
      server:server

cmdr
  .command('build')
  .description("Builds a the current App")
  .action ()->

    RallyAppBuilder.build {},console.log

cmdr
  .command('clone [organization] [repo]')
  .description("Creates a new Rally App project from an existing GitHub project. ")
  .action (organization,repo)->
    if !organization
      console.error("Please specify an organization when using the clone command.")
      return
    if !repo
      console.error("Please specify a repo when using the clone command.")
      return

    RallyAppBuilder.clone
      organization: organization
      repo: repo

cmdr.parse process.argv