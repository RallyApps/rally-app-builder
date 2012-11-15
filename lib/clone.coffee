fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')

module.exports = (args, callback)->
  callback = callback || ()->
  callbackWrapper = (error) ->
    if error
      console.error(error)
    else
      console.log("success")
    callback(error)

  args = _.defaults args,
    organization: 'No Organization'
    repo: 'No Repo'
  fetchGitHubRepo.download
    organization: args.organization
    repo: args.repo
    path: process.cwd()
    callbackWrapper
