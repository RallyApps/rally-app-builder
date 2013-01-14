assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'


describe('Usage', ()->
  #  before ()->
  config = """
           [core]
           repositoryformatversion = 0
           filemode = true
           bare = false
           logallrefupdates = true
           [remote "origin"]
           fetch = +refs/heads/*:refs/remotes/origin/*
           url = https://github.com/ferentchak/rally-app-builder.git
           [branch "master"]
           remote = origin
           merge = refs/heads/master
           """
  #  after ()->
  describe('parseConfigFile',()->
    url = rallyAppBuilder.usage.parseConfigFile(config)
    assert.strictEqual(url,"https://github.com/ferentchak/rally-app-builder.git")
  )
  describe('gatherGitInfo', ()->
    it('should get the current git repos name', (done)->
      process = (err,url)->
        assert.strictEqual(url,"https://github.com/ferentchak/rally-app-builder.git")
        done()

      rallyAppBuilder.usage.gatherGitInfo(path: "../",process)
    )
  )

)