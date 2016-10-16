var module = module;
//this keeps the module file from doing anything inside the jasmine tests.
//We could avoid this by making all the source be in a specific directory, but that would break backwards compatibility.
if (module) {
    module.exports = function (grunt) {
        'use strict';

        var config, debug, environment, spec, port;
        grunt.loadNpmTasks('grunt-contrib-jasmine');
        grunt.loadNpmTasks('grunt-contrib-jshint');
        grunt.loadNpmTasks('grunt-contrib-connect');

        grunt.registerTask('test', ['jshint', 'jasmine']);
        grunt.registerTask('default', ['test']);
        grunt.registerTask('test:debug', ['jasmine:app:build', 'connect']);

        spec = grunt.option('spec') || '*';
        port = grunt.option('port') || 7357;
        debug = grunt.option('debug') || false;
        config = grunt.file.readJSON('config.json');

        return grunt.initConfig({

            pkg: grunt.file.readJSON('package.json'),

            jasmine: {
                app: {
                    src: config.javascript,
                    options: {
                        styles: config.css,
                        vendor:[
                          'node_modules/rally-sdk2-test-utils/src/sdk/' + config.sdk + '/sdk-debug.js',
                          'node_modules/rally-sdk2-test-utils/dist/sdk2-test-utils.js'
                        ],
                        template: 'node_modules/rally-sdk2-test-utils/lib/specs.tmpl',
                        specs: "test/**/" + spec + "Spec.js",
                        keepRunner: true
                    }
                }
            },

            jshint: {
                all: ['test/**/*.js']
            },

            connect: {
                server: {
                    options: {
                        port: port,
                        open: {
                            target: 'http://localhost:' + port + '/_SpecRunner.html'
                        },
                        keepalive: true
                    }
                }
            }
        });
    };
}
