fs = require('fs')
build = require './build'

onChange = (args) ->
  console.log "\nRebuilding...\n"
  path = process.cwd()
  {templates} = args
  fs.unwatchFile process.cwd()
  build {templates, path}, () -> watch {templates}

watch = (args) ->
  {templates} = args
  console.log('\nWatching for changes...')
  fs.watchFile process.cwd(), {interval: 500}, () -> onChange {templates}

module.exports = watch
