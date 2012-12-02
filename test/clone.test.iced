#assert = require 'assert'
#rallyAppBuilder = require '../index'
#fs = require 'fs'
#wrench = require 'wrench'
#describe('Clone existing App', ()->
#  baseDir = 'test/cloneTemp'
#
#  before ()->
#    try
#      fs.mkdirSync(baseDir)
#    catch e
#
#  after ()->
#    try
#      wrench.rmdirSyncRecursive(baseDir)
#    catch e
#
#  it('created files successfully', (done)->
#    checkFilesFetched = (error)->
#      if error
#        done(error)
#        return
#      files = fs.readdirSync(baseDir)
#      error = new Error("README.md not found")
#      for file in files
#        if file.indexOf("README.md") > -1
#          error = null
#      done(error)
#
#    rallyAppBuilder.clone(
#      repo: 'rally-app-builder'
#      organization:'ferentchak'
#      path: baseDir
#      checkFilesFetched
#    )
#  )
#)