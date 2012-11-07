fs = require('fs')

cmdr = require('commander')

RallyAppBuilder = require("../lib/Main.coffee")

version = JSON.parse(fs.readFileSync("package.json")).version

cmdr
  .version(version)


cmdr
  .command('init [name] [sdk_version] [server]')
  .description("Creates a new Rally App project")
  .action((name,sdk_version,server)->

    RallyAppBuilder.init(
      name:name
      sdk_version:sdk_version
      server:server
    )
  )
cmdr
  .command('clone [organization] [repo]')
  .description("Creates a new Rally App project from an existing GitHub project. ")
  .action((organization,repo)->

    if !organization
      console.error("Please specify an organization when using the clone command.")
      return
    if !repo
      console.error("Please specify a repo when using the clone command.")
      return

    RallyAppBuilder.clone(
      organization: organization
      repo: repo
    )
  )

#
#cmdr
#  .command('test [live]')
#  .description("Runs your tests and captures the responses from Rally locally to be served in later unit tests")
#  .action(()->)

cmdr.parse process.argv