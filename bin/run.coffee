fs = require('fs')
path = require ('path')
cmdr = require('commander')
RallyAppBuilder = require("../lib/main")

packageLocation = path.normalize(__dirname + "/../package.json")
version = JSON.parse(fs.readFileSync(packageLocation)).version
errorHandler = (error) -> if error then console.error(error)
cmdr
  .version(version)

cmdr
  .command('init [name] [sdk_version] [server]')
  .description("Creates a new Rally App project")
  .action (name, sdk_version, server)->
    RallyAppBuilder.init {name, sdk_version, server}, errorHandler

cmdr
  .command('build')
  .description("Builds the current App")
  .action ()->
    RallyAppBuilder.build {}, errorHandler

cmdr
  .command('clone [organization] [repo]')
  .description("Creates a new Rally App project from an existing GitHub project. ")
  .action (organization, repo)->
    if !organization
      console.error("Please specify an organization when using the clone command.")
      return
    if !repo
      console.error("Please specify a repo when using the clone command.")
      return

    RallyAppBuilder.clone {organization,repo}

cmdr.parse process.argv