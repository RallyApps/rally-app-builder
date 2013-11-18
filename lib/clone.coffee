fetchGitHubRepo = require("fetch-github-repo")
_ = require('lodash')
fs = require 'fs'
path = require 'path'
{getConfig,saveConfig} = require('./config')



module.exports = (args, callback)->
  callback = callback || ()->
  args = _.defaults args,
    organization: 'No Organization'
    repo: 'No Repo'
    path: process.cwd()
  console.log "Cloning #{args.organization}/#{args.repo}"
  rakeFilePath = path.join( args.path, "Rakefile" )
  deleteRake = ()->
    if fs.existsSync(rakeFilePath)
      fs.unlink(rakeFilePath)
    callback.call(arguments)

  addParentRepoToConfig = ()->

    getConfig args.path, (err,config)->
      if err then callback(err)
      else
        config.name = "Son of " +config.name
        config.parents = config.parents||[]
        config.parents.push("#{args.organization}/#{args.repo}")
        saveConfig({path:args.path,config},deleteRake)

  fetchGitHubRepo.download
    organization: args.organization
    repo: args.repo
    path: args.path
    addParentRepoToConfig
