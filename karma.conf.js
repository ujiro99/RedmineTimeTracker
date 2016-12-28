module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha', 'chai'],

    // list of files / patterns to load in the browser
    files: [
      { pattern: 'node_modules/sinon/pkg/sinon-1.9.1.js', watched: false },
      { pattern: 'bower_components/jquery/dist/jquery.min.js', watched: false },
      { pattern: 'bower_components/sugar/release/sugar.min.js', watched: false },
      { pattern: 'bower_components/angular/angular.min.js', watched: false },
      { pattern: 'app/components/angular-translate/js/angular-translate.min.js', watched: false },
      { pattern: 'app/components/angular-translate-loader-static-files/js/angular-translate-loader-static-files.min.js', watched: false },
      { pattern: 'node_modules/angular-mocks/angular-mocks.js', watched: false },
      { pattern: 'app/scripts/lib/aes.js', watched: false },

      'test/app.coffee',
      'src/coffee/util.coffee',
      'src/coffee/log.coffee',
      'src/coffee/state.coffee',
      'test/config.coffee',
      'test/mockPlugin.js',
      'app/scripts/plugins/timerNotification.js',

      'src/coffee/**/*.coffee',

      // test files
      'test/*.coffee'
    ],

    // list of files to exclude
    exclude: [
      'src/coffee/app.coffee',
      'src/coffee/chromereload.coffee',
      'src/coffee/config.coffee',
      'src/coffee/eventPage.coffee',
    ],

    coffeePreprocessor: {
      options: {
        sourceMap: true
      }
    },

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'src/coffee/**/*.coffee': ['coverage'],
      'test/**/*.coffee': ['coffee']
    },

    coverageReporter: {
      type: 'html',
      instrumenters: {
        ibrik: require('ibrik')
      },
      instrumenter: {
        '**/*.coffee': 'ibrik'
      }
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress', 'coverage'],

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,

  });

  // for Travis CI
  if (process.env.TRAVIS) {
    var conf = {
      customLaunchers: {
        Chrome_travis_ci: {
          base: 'Chrome',
          flags: ['--no-sandbox']
        }
      },
      browsers: ['Chrome_travis_ci'],
      reporters: ['coverage', 'coveralls'],
      coverageReporter: {
        type: 'lcov',
        instrumenters: {
          ibrik: require('ibrik')
        },
        instrumenter: {
          '**/*.coffee': 'ibrik'
        }
      }
    }
    config.set(conf);
  }
}
