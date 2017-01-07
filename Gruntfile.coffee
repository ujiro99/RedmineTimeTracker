module.exports = (grunt) ->

  # Load plugins automatically
  require("load-grunt-tasks") grunt

  # set variables
  config =
    src: 'src',
    app: 'app',
    dist: 'dist',

  # configure
  grunt.initConfig

    config: config

    esteWatch:
      options:
        dirs: [
            '<%= config.src %>/coffee/**/',
            '<%= config.src %>/stylus/**/',
            '<%= config.src %>/jade/**/',
            'test/**/'
          ]
        livereload:
          enabled: true
          port: 35729
          extensions: ['coffee', 'styl', 'jade', 'html']
      # extension settings
      coffee: (path) ->
        grunt.config 'coffee.options.bare', true
        if path.match(/test/)
          grunt.config 'coffee.compile.files', [
            nonull: true
            expand: true
            cwd: 'test/'
            src: path.slice(path.indexOf('/'))
            dest: 'test/'
            ext: '.js'
          ]
        else
          grunt.config 'coffee.compile.files', [
            nonull: true
            expand: true
            cwd: '<%= config.src %>/coffee/'
            src: path.slice(path.indexOf('/', path.indexOf('/') + 1))
            dest: '<%= config.app %>/scripts/'
            ext: '.js'
          ]
        'coffee:compile'
      styl: (path) ->
        grunt.config 'stylus.options.compress', false
        grunt.config 'stylus.compile.files', [
          nonull: true
          expand: true
          cwd: '<%= config.src %>/stylus'
          src: '**/*.styl'
          dest: '<%= config.app %>/css/'
          ext: '.css'
        ]
        'stylus:compile'
      jade: (path) ->
        jadeOptions = { production: false }
        jadeOptions["production"] = grunt.option('production')
        jadeOptions["electron"] = grunt.option('electron')
        jadeOptions["version"] = grunt.file.readJSON('./package.json').version
        grunt.config 'jade.options.data', jadeOptions
        grunt.config 'jade.options.pretty', true
        grunt.config 'jade.compile.files', [
          nonull: true
          expand: true
          cwd: '<%= config.src %>/jade'
          ext: '.html'
          src: ['**/!(_)*.jade']
          dest: '<%= config.app %>/views/'
        ]
        'jade:compile'

    coffee:
      options:
        bare: true
      production:
        options:
          join: true
        files: [
          '<%= config.dist %>/scripts/script.js': [
            '<%= config.src %>/coffee/app.coffee',
            '<%= config.src %>/coffee/log.coffee',
            '<%= config.src %>/coffee/state.coffee',
            '<%= config.src %>/coffee/config.coffee',
            '<%= config.src %>/coffee/**/*.coffee',
            '!<%= config.src %>/coffee/index.coffee',
            '!<%= config.src %>/coffee/index_chrome.coffee',
            '!<%= config.src %>/coffee/chromereload.coffee'
          ]
        ]
      chrome:
        files: [
          '<%= config.dist %>/scripts/index_chrome.js': [
            '<%= config.src %>/coffee/index_chrome.coffee'
          ]
        ]
      electron:
        files: [
          '<%= config.dist %>/scripts/index.js': [
            '<%= config.src %>/coffee/index.coffee'
          ]
        ]
      develop:
        files: [
          expand: true
          cwd: '<%= config.src %>/coffee/'
          src: ['**/*.coffee']
          dest: '<%= config.app %>/scripts/'
          ext: '.js'
        ]
      test:
        files: [
          expand: true
          cwd: 'test/'
          src: ['**/*.coffee']
          dest: 'test/'
          ext: '.js'
        ]

    stylus:
      production:
        files: [
          '<%= config.dist %>/css/main.css': [
            '<%= config.src %>/stylus/**/*.styl'
          ]
        ]
      develop:
        files: [
          expand: true
          cwd: '<%= config.src %>/stylus/'
          src: ['**/*.styl']
          dest: '<%= config.app %>/css/'
          ext: '.css'
        ]

    jade:
      chrome:
        options:
          data: (dest, src) ->
            jadeOptions = {
              production: true,
              electron: false
            }
            jadeOptions["version"] = grunt.file.readJSON('./package.json').version
            return jadeOptions
        files: [
          expand: true
          cwd: '<%= config.src %>/jade/'
          src: ['**/!(_)*.jade']
          dest: '<%= config.dist %>/views/'
          ext: '.html'
        ]
      electron:
        options:
          data: (dest, src) ->
            jadeOptions = {
              production: true,
              electron: true 
            }
            jadeOptions["version"] = grunt.file.readJSON('./package.json').version
            return jadeOptions
        files: [
          expand: true
          cwd: '<%= config.src %>/jade/'
          src: ['**/!(_)*.jade']
          dest: '<%= config.dist %>/views/'
          ext: '.html'
        ]
      develop:
        options:
          data: (dest, src) ->
            jadeOptions = { production: false}
            jadeOptions["production"] = grunt.option('production')
            jadeOptions["electron"] = grunt.option('electron')
            jadeOptions["version"] = grunt.file.readJSON('./package.json').version
            return jadeOptions
        files: [
          expand: true
          cwd: '<%= config.src %>/jade/'
          src: ['**/!(_)*.jade']
          dest: '<%= config.app %>/views/'
          ext: '.html'
        ]

    bower:
      install:
        options:
          targetDir: './<%= config.app %>/components'
          install: true
          verbose: true
          cleanTargetDir: true
          cleanBowerDir: false
          layout: 'byComponent'

    ngmin:
      production:
        src: '<%= config.dist %>/scripts/script.js'
        dest: '<%= config.dist %>/scripts/script.js'

    uglify:
      chrome:
        files: [
          '<%= config.dist %>/scripts/script.js': '<%= config.dist %>/scripts/script.js'
          '<%= config.dist %>/scripts/index_chrome.js': '<%= config.dist %>/scripts/index_chrome.js'
        ]
      electron:
        files: [
          '<%= config.dist %>/scripts/script.js': '<%= config.dist %>/scripts/script.js'
          '<%= config.dist %>/scripts/index.js': '<%= config.dist %>/scripts/index.js'
        ]

    chromeManifest:
      dist:
        options:
          buildnumber: false
          background:
            target: 'scripts/index_chrome.js'
            exclude: [
              'scripts/chromereload.js'
            ]
        src: '<%= config.app %>'
        dest: '<%= config.dist %>'

    # Empties folders to start fresh
    clean:
      dist:
        files: [
          dot: true
          src: [
            "<%= config.dist %>/*",
            "!<%= config.dist %>/manifest.json"
          ]
        ]
      manifest: [ "<%= config.dist %>/manifest.json" ]

    # Copies remaining files to places other tasks can use
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= config.app %>"
          dest: "<%= config.dist %>"
          src: [
            "_locales/{,*/}*.json"
            "css/lib/*.css"
            "components/**/*.*"
            "fonts/*.*"
            "images/*.png"
            "!images/icon_128_gray.png"
            "scripts/lib/*.js"
            "views/template/**/*.html"
          ]
        ]
      electron:
        files: [
          { src: '<%= config.app %>/package.json', dest: '<%= config.dist %>/package.json' },
          { src: '<%= config.app %>/index.js', dest: '<%= config.dist %>/index.js' },
          { expand: true,  cwd: '<%= config.app %>/node_modules', src: '**', dest: '<%= config.dist %>/node_modules/' }
        ]

    release:
      options:
        file: 'package.json'
        npm: false
        additionalFiles: [
          'bower.json',
          'app/manifest.json'
          'dist/manifest.json'
        ]

    # Compress files in dist to make Chromea Apps package
    compress:
      dist:
        options:
          archive: "release/chrome/chrome-<%= grunt.file.readJSON('./package.json').version %>.zip"
        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]
      ci:
        options:
          archive: "release/chrome/chrome-app.zip"
        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

    exec:
      install_electron_deps: "cd app && npm install"

  # tasks
  grunt.registerTask 'watch', ['esteWatch']

  grunt.registerTask 'dev', [
    'bower:install',
    'coffee:develop',
    'jade:develop',
    'stylus:develop'
  ]

  grunt.registerTask 'build-chrome', [
    'clean',
    'bower:install',
    'copy:dist',
    'coffee:production',
    'coffee:chrome',
    'jade:chrome',
    'stylus:production',
    'ngmin',
    'uglify:chrome'
  ]

  grunt.registerTask 'build-electron', [
    'clean',
    'exec:install_electron_deps'
    'clean:manifest',
    'bower:install',
    'copy:dist',
    'copy:electron',
    'coffee:production',
    'coffee:electron',
    'jade:electron',
    'stylus:production',
    'ngmin',
    'uglify:electron'
  ]

  grunt.registerTask 'release-minor', [
    'release:minor',
    'build-chrome',
    'compress:dist',
    'build-electron'
  ]

  grunt.registerTask 'release-patch', [
    'release:patch',
    'build-chrome',
    'compress:dist',
    'build-electron'
  ]
