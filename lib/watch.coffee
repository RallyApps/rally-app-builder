fs = require('fs')
build = require './build'

onChange = () ->
  console.log "\nRebuilding...\n"
  fs.unwatchFile process.cwd()
  build process.cwd(), watch

watch = ()->
  console.log('\nWatching for changes...')
  fs.watchFile process.cwd(), {interval: 500}, onChange

module.exports = watch
