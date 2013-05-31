Deploy = require("../lib/deploy").Deploy

module.exports = (grunt) ->
  grunt.registerMultiTask "rallydeploy", "Task for deploying built Apps to Rally", () ->
    console.dir(@)
