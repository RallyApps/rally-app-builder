fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')

module.exports = (args, callback)->
  callback = callback || ()->

  args = _.defaults args,
    organization: 'No Organization'
    repo: 'No Repo'
    path: process.cwd()
  fetchGitHubRepo.download
    organization: args.organization
    repo: args.repo
    path: args.path
    callback
