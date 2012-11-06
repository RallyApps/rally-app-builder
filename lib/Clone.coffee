fetchGitHubRepo = require("fetch-github-repo")
_ = require('underscore')
module.exports = (args)->
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
console.log "yar"