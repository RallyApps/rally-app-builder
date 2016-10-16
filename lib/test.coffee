child_process = require 'child_process'

test = (args) ->
  {debug, spec} = args
  console.log '\nRunning tests...'
  command = if debug then 'test:debug' else 'test'
  command += " -- --spec=#{spec}" if spec
  child_process.execSync "npm run #{command}", stdio: 'inherit'

module.exports = test
