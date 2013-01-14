assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'

describe('Clone existing App', ()->
  baseDir = 'test/cloneTemp'

  before (done)->
    try
      if(!fs.existsSync(baseDir))
        fs.mkdirSync(baseDir)
      rallyAppBuilder.clone(
        repo: 'TeamBoard'
        organization:'ferentchak'
        path: baseDir
        done
      )
    catch e
      done(e)
  after ()->
    try
      wrench.rmdirSyncRecursive(baseDir)
    catch e

  it('should delete the RakeFile', ()->
    testFile = "Rakefile"
    assert(!fs.existsSync(path.join(baseDir,testFile )))
  )

  it('should have a config.json', ()->
    testFile = "config.json"
    assert(fs.existsSync(path.join(baseDir,testFile )))
  )
)