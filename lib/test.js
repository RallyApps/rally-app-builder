let childProcess = require('child_process');

function test(args) {
    let { debug, spec } = args;
    console.log('\nRunning tests...');
    let command = debug ? 'test:debug' : 'test';
    if (spec) { command += ` -- --spec=${spec}`; }
    return childProcess.execSync(`npm run ${command}`, { stdio: 'inherit' });
}

module.exports = test;
