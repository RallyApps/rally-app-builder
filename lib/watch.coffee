chokidar = require('chokidar')
build = require './build'
watcher = null

onChange = (args) ->
  console.log "\nRebuilding...\n"
  path = process.cwd()
  {templates} = args
  watcher.close()
  build {templates, path}, () -> watch {templates}

watch = (args) ->
  {templates} = args
  console.log('\nWatching for changes...')
  watcher = chokidar.watch process.cwd(), { usePolling: true, interval: 500 }
  watcher.on 'change', () -> onChange {templates}

module.exports = watch
