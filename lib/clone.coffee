fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')


error = (error) ->
  console.error(error)

success = (success)->
  console.log("success")

module.exports = (args)->
  @args = _.defaults args,
    error: error
    success: ()->
    organization: 'No Organization'
    repo: 'No Repo'
  fetchGitHubRepo.download
    organization: @args.organization
    repo: @args.repo
    success: @args.success
    error: @args.error
    path: process.cwd()
