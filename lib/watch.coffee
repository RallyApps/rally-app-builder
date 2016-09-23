chokidar = require('chokidar')
build = require './build'
watcher = null
test = require './test'

onChange = (args) ->
  console.log('Rebuilding...\n');
  path = process.cwd()
  {templates, ci} = args
  watcher.close()
  build {templates, path}, (err) ->
    test({}) if !err && ci
    watch {templates, ci}

watch = (args) ->
  {templates, ci} = args
  console.log('\nWatching for changes...')
  watcher = chokidar.watch process.cwd(), { ignored: '**/*.html', usePolling: true, interval: 500 }
  watcher.on 'change', (path) ->
    console.log('\nChange detected:', path);
    onChange {templates, ci}

module.exports = watch
