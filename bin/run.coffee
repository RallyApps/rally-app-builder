fs = require('fs')

cmdr = require('commander')

version = JSON.parse(fs.readFileSync("package.json")).version

cmdr
  .version(version)


cmdr
  .command('new [project]')
  .description("Creates a new Rally App project")
  .action(()->)
cmdr
  .command('clone [organization,repo]')
  .description("Creates a new Rally App project from an existing GitHub project. ")
  .action((input)->
    args = (input || "").split(",")

    if args.length != 2
      console.error("Please specify an organization and a repo when using the clone command.")
      return

    organization = args[0]
    repo = args[1]
    Clone = require("../lib/Clone")
    Clone(
      error:()-> console.error "error"
      success:()-> console.log "success"
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