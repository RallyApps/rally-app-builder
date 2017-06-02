let child_process = require('child_process');

let test = function(args) {
  let {debug, spec} = args;
  console.log('\nRunning tests...');
  let command = debug ? 'test:debug' : 'test';
  if (spec) { command += ` -- --spec=${spec}`; }
  return child_process.execSync(`npm run ${command}`, {stdio: 'inherit'});
};

module.exports = test;
