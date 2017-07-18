let assert = require('assert');
let rallyAppBuilder = require('../index');
let fs = require('fs');
let fsextra = require('fs-extra');
describe('Init new App', function(){
  let baseDir = 'test/initTemp';

  before(function(){
    try {
      return fs.mkdirSync(baseDir);
    } catch (e) {}
  });
  after(function(){
    try {
      return fsextra.removeSync(baseDir);
    } catch (e) {}
  });

  return it('tests files created', function(done){
    let checkFilesFetched = function(){
      let files = fs.readdirSync(baseDir);
      let error = new Error("README.md not found");
      for (let file of Array.from(files)) {
        if (file.indexOf("README.md") > -1) {
          error = null;
        }
      }
      if (error) {
        return done(error);
      } else {
        return done();
      }
    };

    return rallyAppBuilder.init({
      name: 'App',
      path: baseDir
    },
      checkFilesFetched
    );
  });
});
