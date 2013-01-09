fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')
fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync

module.exports = (args, callback)->
  callback = callback || ()->
  args = _.defaults args,
    organization: 'No Organization'
    repo: 'No Repo'
    path: process.cwd()

  rakeFilePath = path.join( args.path, "Rakefile" )
  deleteRake = ()->
    if existsSync(rakeFilePath)
      fs.unlink(rakeFilePath)
    callback.call(arguments)

  fetchGitHubRepo.download
    organization: args.organization
    repo: args.repo
    path: args.path
    deleteRake
