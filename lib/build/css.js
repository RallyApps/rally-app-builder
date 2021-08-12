let less = require('less');
let fs = require('fs');
let _ = require('lodash');
let LESS_FILE_REGEX = /[.]less$/;
const VARS =
  {prefix: 'x-'};

let isLessFile = cssName=> cssName.match(LESS_FILE_REGEX);

let getGeneratedFileName =  cssFile => cssFile.replace(LESS_FILE_REGEX, '.less.css');

let compile = function(cssCode, compress, callback) {
  _.each(VARS, (value, key) => cssCode += `\n@${key}: ${value};`);
  return less.render(cssCode, { compress }, function(err, tree) {
    if (err) {
      return callback(err);
    } else {
      return callback(null, tree.css);
    }
  });
};
        //todo: figure out how to not strip out comments

let compileInPlace = function(file, compress, callback) {
  if (isLessFile(file)) {
    return fs.readFile(file, 'utf-8', function(err, contents) {
      if (err) { return callback(err);
      } else {
        return compile(contents, compress, function(e, css) {
          let fileName = getGeneratedFileName(file);
          return fs.writeFile(fileName, css, badThing => callback(badThing, fileName));
        });
      }
    });
  } else {
    return callback(null, file);
  }
};

module.exports = {
  isLessFile,
  getGeneratedFileName,
  compile,
  compileInPlace
};


