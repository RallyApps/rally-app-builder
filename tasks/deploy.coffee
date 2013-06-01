Deploy = require("../lib/deploy").Deploy

module.exports = (grunt) ->
  grunt.registerMultiTask "rallydeploy", "Task for deploying built Apps to Rally", () ->
    #exists = grunt.file.exists(@options().configFile))
    deployData = {}
    target = @target

    unless parseInt(@options().projectOid + "", 10) > 0
      grunt.fail.fatal("Please update 'projectOid' to any valid Project Object ID") 

    if grunt.file.exists(@options().credentialsFile)
      credentialsData = grunt.file.readJSON(@options().credentialsFile)
    else
      grunt.fail.fatal("Cannot find credentials file")

    if (grunt.file.exists(@options().deployFile))
      deployData = grunt.file.readJSON(@options().deployFile)


    deployer = new Deploy(credentialsData.username, credentialsData.password, @options().server)

    updateApp = deployData[target]?.appId?

    appContents = grunt.file.read('deploy/App.html')

    done = @async()

    if not updateApp
      #console.log("Creating new page")
      deployer.createNewPage @options().projectOid, @options().pageName, appContents, @options().tab, @options().shared, (err, pageId, appId) =>
        #console.log(pageId, appId)
        deployData[target] = 
          pageId: pageId + ""
          appId: appId + ""

        grunt.file.write(@options().deployFile, JSON.stringify(deployData, null, '\t'))
        unless err
          grunt.log.writeln("Page created at https://#{@options().server}/#/#{@options().projectOid}d/custom/#{pageId}")
        else
          grunt.log.errorlns(err)

        done(err is null)
    else
      deployer.updatePage deployData[target].pageId, deployData[target].appId, @options().projectOid, @options().pageName, @options().tab, appContents, (err) =>
        #console.log(err)
        unless err
          grunt.log.writeln("Page updated at https://#{@options().server}/#/#{@options().projectOid}d/custom/#{deployData[target].pageId}")
        else
          grunt.log.errorlns(err)

        done(err is null)
