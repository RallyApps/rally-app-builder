let _ = require('lodash');
let fs = require('fs');
let path = require('path');
let mustache = require('mustache');

let files = {
  "app.css": "app.css",
  "App.js": "App.js",
  "config.json": "config.json",
  "gitignore": ".gitignore",
  ".travis.yml": ".travis.yml",
  "LICENSE": "LICENSE",
  "README.md": "README.md",
  "Gruntfile.js": "Gruntfile.js",
  "package.json": "package.json",
  "test/AppSpec.js": "test/AppSpec.js",
  ".jshintrc": ".jshintrc"
};

let directories = ["test"];

module.exports = function(args, callback){
  let error;
  callback = callback || function(){};
  try {
    args = _.defaults(args, {
      name: `Random App Name${Math.floor(Math.random() * 100000)}`,
      sdk_version: '2.1',
      server: 'https://rally1.rallydev.com',
      path: '.'
    }
    );
    let filePath = args.path;
    args.packageName = args.name.replace(/\s/g, '');
    let view = args;
    let templatePath = path.resolve(__dirname, '../templates/');

    _.each(directories,
    function(value){
      if (!fs.existsSync(`${filePath}/${value}`)) {
        return fs.mkdirSync(`${filePath}/${value}`);
      }
    });

    _.each(files,
    function(value, key){
      let templateFile = `${templatePath}/${key}`;
      let destinationFile = `${filePath}/${value}`;
      let file = fs.readFileSync(templateFile, "utf-8");
      let parsed = mustache.render(file, view);
      return fs.writeFileSync(destinationFile, parsed);
    });
  } catch (err) {
    error = err;
  }
  if (error) {
    return callback(error);
  } else {
    return callback();
  }
};
