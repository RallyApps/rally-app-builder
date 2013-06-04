
module.exports = function(grunt) {
  'use strict';

  var config, debug, environment, spec;
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-templater');
  grunt.loadNpmTasks('rally-app-builder');

  grunt.registerTask('default', ['clean', 'concat', 'template']);
  grunt.registerTask('test', ['default', 'jasmine']);
  grunt.registerTask('build', ['concat', 'template:build']);
  grunt.registerTask('deploy', ['build', 'rallydeploy:prod']);

  spec = grunt.option('spec') || '*';
  config = grunt.file.readJSON('config.json');

  return grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    clean: [ 'gen/**/*' ],

    concat: {
      src: {
        src: 'src/**/*.js',
        dest: 'gen/all.js'
      },
      styles: {
        src: 'styles/**/*.css',
        dest: 'gen/all.css'
      }
    },

    jasmine: {
      dev: {
        src: "src/*.js",
        options: {
          template: 'test/specs.tmpl',
          specs: "test/**/" + spec + "Spec.js",
          helpers: ['test/**/helpers/**/*.js']
        }
      }
    },

    watch: {
      src: {
        files: 'src/**/*.js',
        tasks: ['template:debug', 'jasmine', 'clean', 'concat', 'template:build']
      },
      config: {
        files: 'config.json',
        tasks: ['template']
      },
      template: {
        files: 'templates/**/*',
        tasks: ['template']
      }
    },

    template: {
      debug: {
        src: 'templates/App-debug.html',
        dest: 'App-debug.html',
        engine: 'handlebars',
        variables: config
      },
      jasmine_template: {
        src: 'templates/specs.tmpl',
        dest: 'test/specs.tmpl',
        engine: 'handlebars',
        variables: config
      },
      build: {
        src: 'templates/App.html',
        dest: 'deploy/App.html',
        engine: 'handlebars',
        variables: function() {
          config.javascript = grunt.file.read('gen/all.js');
          config.css = grunt.file.read('gen/all.css');
          return config;
        }
      }
    },

    rallydeploy: {
      options: {
        server: "rally1.rallydev.com",
        projectOid: 0,
        deployFile: "deploy.json",
        credentialsFile: "credentials.json"
      },
      prod: {
        options: {
          tab: "myhome",
          pageName: "App Name",
          shared: false
        }
      }
    }
  });
};
