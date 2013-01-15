fs = require('fs')
path = require ('path')
cmdr = require('commander')
RallyAppBuilder = require("../lib/main")
packageLocation = path.normalize(__dirname + "/../package.json")
version = JSON.parse(fs.readFileSync(packageLocation)).version


builder = (error)->
  if(error)  then errorHandler(error)
  else
    RallyAppBuilder.build {}, errorHandler

errorHandler = (error) ->
  if error
    console.error(error)
  else
    console.log("Success")
cmdr
  .version(version)

cmdr
  .command('init [name] [sdk_version] [server=rally1.rallydev.com]')
  .description("Creates a new Rally App project template. ")
  .action (name, sdk_version, server)->
    RallyAppBuilder.init {name, sdk_version, server}, builder

cmdr
  .command('build')
  .description("Builds the current App.")
  .action ()->
    RallyAppBuilder.build {}, errorHandler

cmdr
  .command('clone [organization] [repo]')
  .description("Creates a new Rally App project locally from an existing GitHub project. ")
  .action (organization, repo)->
    if !organization
      console.error("Please specify an organization when using the clone command.")
      return
    if !repo
      console.error("Please specify a repo when using the clone command.")
      return
    RallyAppBuilder.clone {organization,repo}, builder

if process.argv.length == 2
  process.argv.push("build")

cmdr.parse process.argv