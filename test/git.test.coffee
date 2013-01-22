assert = require 'assert'
rallyAppBuilder = require '../index'
fs = require 'fs'
path = require 'path'
wrench = require 'wrench'


describe('Git', ()->
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
  describe('parseConfigFile',()->
    url = rallyAppBuilder.git.parseConfigFile(config)
    assert.strictEqual(url,"//github.com/ferentchak/rally-app-builder.git")
  )

)