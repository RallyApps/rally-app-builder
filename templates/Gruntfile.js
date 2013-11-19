var module = module;
//this keeps the module file from doing anything inside the jasmine tests.
//We could avoid this by making all the source be in a specific directory, but that would break backwards compatibility.
if (module) {
    module.exports = function (grunt) {
        'use strict';

        var config, debug, environment, spec;
        grunt.loadNpmTasks('grunt-contrib-jasmine');

        grunt.registerTask('default', ['jasmine']);

        spec = grunt.option('spec') || '*';
        config = grunt.file.readJSON('config.json');
        return grunt.initConfig({

            pkg: grunt.file.readJSON('package.json'),

            jasmine: {
                dev: {
                    src: "./*.js",
                    options: {
                        vendor:["https://rally1.rallydev.com/apps/"+config.sdk+"/sdk-debug.js"],
                        template: 'test/specs.tmpl',
                        specs: "test/**/" + spec + "Spec.js",
                        helpers: []
                    }
                }
            },

            rallydeploy: {
                options: {
                    server: config.server,
                    projectOid: 0,
                    deployFile: "deploy.json",
                    credentialsFile: "credentials.json",
                    timeboxFilter: "none"
                },
                prod: {
                    options: {
                        tab: "myhome",
                        pageName: config.name,
                        shared: false
                    }
                }
            }
        });
    };

}