module.exports = function (grunt) {

    var st = require('connect-static-transform');

    grunt.loadNpmTasks('grunt-contrib-connect');

    grunt.initConfig({

        connect: {
            server: {
                options: {
                    keepalive: true,
                    hostname: '*',
                    port: process.env.PORT || 8000,
                    middleware: function(connect, options, middlewares) {
                        var coffee = st.coffee({
                            root: __dirname + '/js',
                            path: '/js',
                            // cache: true,
                            // maxage: 3600,
                            options: {
                                // minify: true
                            }
                        });

                        middlewares.unshift(coffee);
                        return middlewares;
                    }
                }
            }
        }

    });

    grunt.registerTask('heroku:production', []);

    grunt.registerTask('default', ['connect']);

};
