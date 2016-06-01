chokidar = require('chokidar')
build = require './build'
watcher = null

onChange = (args) ->
  console.log('Rebuilding...\n');
  path = process.cwd()
  {templates} = args
  watcher.close()
  build {templates, path}, (err) ->
    console.error err if err
    watch {templates}

watch = (args) ->
  {templates} = args
  console.log('\nWatching for changes...')
  watcher = chokidar.watch process.cwd(), { ignored: '**/*.html', usePolling: true, interval: 500 }
  watcher.on 'change', (path) ->
    console.log('\nChange detected:', path);
    onChange {templates}

module.exports = watch
