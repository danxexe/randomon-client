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
                        var env = function(req, res, next) {
                            if (req.url !== '/js/env.js') return next();

                            var GAME_SERVER_URL = process.env.GAME_SERVER_URL ? "'"+process.env.GAME_SERVER_URL+"'" : 'null';
                            var js = " \
                                window.env = { \
                                    'GAME_SERVER_URL': "+GAME_SERVER_URL+" \
                                }; \
                            ";
                            res.setHeader('Content-Type', 'application/javascript');
                            res.end(js);
                        };

                        var coffee = st.coffee({
                            root: __dirname + '/js',
                            path: '/js',
                            // cache: true,
                            // maxage: 3600,
                            // options: {
                            //     minify: true
                            // }
                        });

                        var opal = st({
                            root: __dirname,
                            match: /(.+)\.js/,
                            normalize: '$1.rb',
                            transform: function (path, text, send) {
                                var opal = require('./opal-node.js');
                                send(Opal.compile(text), {'Content-Type': 'application/javascript'});
                            }
                        });

                        middlewares.unshift(env);
                        middlewares.unshift(coffee);
                        middlewares.unshift(opal);
                        return middlewares;
                    }
                }
            }
        }

    });

    grunt.registerTask('heroku:production', []);

    grunt.registerTask('default', ['connect']);

};
