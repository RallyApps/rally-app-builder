Deploy = require("../lib/deploy").Deploy

module.exports = (grunt) ->
  grunt.registerMultiTask "rallydeploy", "Task for deploying built Apps to Rally", () ->
    #exists = grunt.file.exists(@options().configFile))
    deployData = {}

    unless parseInt(@options().projectOid + "", 10) > 0
      grunt.fail.fatal("Please update 'projectOid' to any valid Project Object ID") 

    if grunt.file.exists(@options().credentialsFile)
      credentialsData = grunt.file.readJSON(@options().credentialsFile)
    else
      grunt.fail.fatal("Cannot find credentials file")

    deployData = grunt.file.readJSON(@options().deployFile) if grunt.file.exists(@options().deployFile)

    deployer = new Deploy(credentialsData.username, credentialsData.password, @options().server)

    updateApp = deployData.appId?

    appContents = grunt.file.read('deploy/App.html')

    done = @async()

    if not updateApp
      #console.log("Creating new page")
      deployer.createNewPage @options().projectOid, @options().pageName, appContents, @options().tab, (err, pageId, appId) =>
        #console.log(pageId, appId)
        grunt.file.write(@options().deployFile, JSON.stringify({pageId: pageId + "", appId: appId + ""}, null, '\t'))
        done(err is null)
    else
      deployer.updatePage deployData.pageId, deployData.appId, @options().projectOid, @options().pageName, @options().tab, appContents, (err) ->
        #console.log(err)
        done(err is null)
