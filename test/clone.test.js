assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
fsextra = require 'fs-extra'
if process.env.TRAVIS
  console.log "Clone tests not ran during Travis build process due to timeouts."
  return

describe('Clone existing App', ()->
  baseDir = 'test/cloneTemp'

  before (done)->
    try
      if(!fs.existsSync(baseDir))
        fs.mkdirSync(baseDir)
      rallyAppBuilder.clone(
        repo: 'PortfolioKanban'
        organization: 'RallyApps'
        path: baseDir
        done
      )
    catch e
      done(e)
  after ()->
    try
      fsextra.removeSync(baseDir)
    catch e

  it('should delete the RakeFile', ()->
    assert(!fs.existsSync(path.join(baseDir, "testFile")))
  )

  it('should have a config.json', (done)->
    rallyAppBuilder.config.getConfig(baseDir,done)
  )

  it('should have add a parent repo', (done)->
    assertWrapper = (error,config)->
      assert.strictEqual(config.parents[0],'RallyApps/PortfolioKanban')
      done(error)
    rallyAppBuilder.config.getConfig(baseDir,assertWrapper)
  )

  it('should change the name', (done)->
    assertWrapper = (error,config)->
      assert.strictEqual(config.name,'Son of Portfolio Kanban Board')
      done(error)
    rallyAppBuilder.config.getConfig(baseDir,assertWrapper)
  )
)
