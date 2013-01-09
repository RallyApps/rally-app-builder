assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'
existsSync = fs.existsSync || path.existsSync

describe('Clone existing App', ()->
  baseDir = 'test/cloneTemp'

  before ()->
    try
      fs.mkdirSync(baseDir)
    catch e

  after ()->
    try
      wrench.rmdirSyncRecursive(baseDir)
    catch e

  it('should create files successfully', (done)->
    testFile = "README.md"
    checkFilesFetched = (error)->
      if error
        done(error)
        return
      if existsSync(path.join(baseDir,testFile ))
        done()
      else
        error = new Error("#{testFile} not found")
        done(error)

    rallyAppBuilder.clone(
      repo: 'rally-app-builder'
      organization:'ferentchak'
      path: baseDir
      checkFilesFetched
    )
  )
#
  it('should delete the RakeFile', (done)->
    testFile = "Rakefile"
    checkFilesFetched = (error)->
      if error
        done(error)
        return
      if !existsSync(path.join(baseDir,testFile ))
        done()
      else
        error = new Error("#{testFile} should not be found")
        done(error)

    rallyAppBuilder.clone(
      repo: 'TeamBoard'
      organization:'ferentchak'
      path: baseDir
      checkFilesFetched
    )
  )
)