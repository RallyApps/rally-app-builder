let assert = require('assert');
let rallyAppBuilder = require('../index');
let fs = require('fs');
let path = require('path');
let fsextra = require('fs-extra');
if (process.env.TRAVIS) {
  console.log("Clone tests not ran during Travis build process due to timeouts.");
  return;
}

describe('Clone existing App', function(){
  let baseDir = 'test/cloneTemp';

  before(function(done){
    try {
      if(!fs.existsSync(baseDir)) {
        fs.mkdirSync(baseDir);
      }
      return rallyAppBuilder.clone({
        repo: 'PortfolioKanban',
        organization: 'RallyApps',
        path: baseDir
      },
        done
      );
    } catch (e) {
      return done(e);
    }
  });
  after(function(){
    try {
      return fsextra.removeSync(baseDir);
    } catch (e) {}
  });

  it('should delete the RakeFile', ()=> assert(!fs.existsSync(path.join(baseDir, "testFile"))));

  it('should have a config.json', done=> rallyAppBuilder.config.getConfig(baseDir,done));

  it('should have add a parent repo', function(done){
    let assertWrapper = function(error,config){
      assert.strictEqual(config.parents[0],'RallyApps/PortfolioKanban');
      return done(error);
    };
    return rallyAppBuilder.config.getConfig(baseDir,assertWrapper);
  });

  return it('should change the name', function(done){
    let assertWrapper = function(error,config){
      assert.strictEqual(config.name,'Son of Portfolio Kanban Board');
      return done(error);
    };
    return rallyAppBuilder.config.getConfig(baseDir,assertWrapper);
  });
});
