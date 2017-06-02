let fetchGitHubRepo = require("rally-fetch-github-repo");
let _ = require('lodash');
let fs = require('fs');
let path = require('path');
let {getConfig,saveConfig} = require('./config');



module.exports = function(args, callback){
  callback = callback || function(){};
  args = _.defaults(args, {
    organization: 'No Organization',
    repo: 'No Repo',
    path: process.cwd()
  }
  );
  console.log(`Cloning ${args.organization}/${args.repo}`);
  let rakeFilePath = path.join( args.path, "Rakefile" );
  let deleteRake = function(){
    if (fs.existsSync(rakeFilePath)) {
      fs.unlink(rakeFilePath);
    }
    return callback.call(arguments);
  };

  let addParentRepoToConfig = ()=>

    getConfig(args.path, function(err,config){
      if (err) { return callback(err);
      } else {
        config.name = `Son of ${config.name}`;
        config.parents = config.parents||[];
        config.parents.push(`${args.organization}/${args.repo}`);
        return saveConfig({path:args.path,config},deleteRake);
      }
    })
  ;

  return fetchGitHubRepo.download({
    organization: args.organization,
    repo: args.repo,
    path: args.path
  },
    addParentRepoToConfig);
};
