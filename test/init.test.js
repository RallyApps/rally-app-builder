assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
fsextra = require 'fs-extra'
describe('Init new App', ()->
  baseDir = 'test/initTemp'

  before ()->
    try
      fs.mkdirSync(baseDir)
    catch e
  after ()->
    try
      fsextra.removeSync(baseDir)
    catch e

  it('tests files created', (done)->
    checkFilesFetched = ()->
      files = fs.readdirSync(baseDir)
      error = new Error("README.md not found")
      for file in files
        if file.indexOf("README.md") > -1
          error = null
      if error
        done(error)
      else
        done()

    rallyAppBuilder.init(
      name: 'App'
      path: baseDir
      checkFilesFetched
    )
  )
)
