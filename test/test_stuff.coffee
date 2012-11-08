assert = require 'assert'
fs = require 'fs'

describe('Fetch Github Repo', ()->

  baseDir = 'test/temp'

  before ()->
    try
      fs.mkdirSync(baseDir)
    catch e

  it('tests stuff', (done)->
    done()
  )
)