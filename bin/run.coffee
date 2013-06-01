fs = require('fs')
path = require ('path')
cmdr = require('commander')
RallyAppBuilder = require("../lib/main")
packageLocation = path.normalize(__dirname + "/../package.json")
version = JSON.parse(fs.readFileSync(packageLocation)).version

errorHandler = (error) ->
  if error
    console.error(error)
  else
    console.log("Success")
cmdr
  .version(version)

cmdr
  .command('init [name] [sdk_version] [server=https://rally1.rallydev.com]')
  .description("Creates a new Rally App project template. ")
  .action (name, sdk_version, server)->
    console.log("Creating a new App named #{name}")
    RallyAppBuilder.init {name, sdk_version, server}, errorHandler

cmdr
  .command('clone [organization] [repo]')
  .description("Creates a new Rally App project locally from an existing GitHub project. ")
  .action (organization, repo)->
    console.log("Cloning #{repo} repo from #{organization} account")
    if !organization
      console.error("Please specify an organization when using the clone command.")
      return
    if !repo
      console.error("Please specify a repo when using the clone command.")
      return
    RallyAppBuilder.clone {organization,repo}, errorHandler

cmdr.parse process.argv