fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')

Clone = (args)->
    @args = _.defaults args,
        error: ()->
        success:()->
        organization:'No Organization'
        repo:'No Repo'
    fetchGitHubRepo.download
        organization:@args.organization
        repo : @args.repo
        success:@args.error
        error:@args.success

module.exports = Clone
