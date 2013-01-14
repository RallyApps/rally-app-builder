assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'

describe('Clone existing App', ()->
  baseDir = 'test/cloneTemp'

  before (done)->
    try
      fs.mkdirSync(baseDir)
      rallyAppBuilder.clone(
        repo: 'rally-app-builder'
        organization:'TeamBoard'
        path: baseDir
        done
      )
    catch e

  after ()->
    try
      wrench.rmdirSyncRecursive(baseDir)
    catch e

  it('should delete the RakeFile', ()->
    testFile = "Rakefile"
    assert(!fs.existsSync(path.join(baseDir,testFile )))
  )
)