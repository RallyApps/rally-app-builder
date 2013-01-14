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
        organization: 'ferentchak'
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
    assert(!fs.existsSync(path.join(baseDir, "testFile")))
  )

  it('should have a config.json', (done)->
    rallyAppBuilder.config.getConfig(baseDir,done)
  )

  it('should have add a parent repo', (done)->
    assertWrapper = (error,config)->
      assert.strictEqual(config.parents[0],'ferentchak/TeamBoard')
      done(error)
    rallyAppBuilder.config.getConfig(baseDir,assertWrapper)
  )

  it('should change the name', (done)->
    assertWrapper = (error,config)->
      assert.strictEqual(config.name,'Son of TeamBoard')
      done(error)
    rallyAppBuilder.config.getConfig(baseDir,assertWrapper)
  )
)