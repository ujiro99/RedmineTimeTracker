module.exports = (grunt) ->

  # Load plugins automatically
  require("load-grunt-tasks") grunt

  # set variables
  config =
    src: 'src',
    app: 'app',
    dist: 'dist',
    manifest: grunt.file.readJSON('app/manifest.json'),

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
        grunt.config 'jade.options.data', { production: false }
        grunt.config 'jade.options.pretty', true
        grunt.config 'jade.compile.files', [
          nonull: true
          expand: true
          cwd: '<%= config.src %>/jade'
          ext: '.html'
          src: '**/*.jade'
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
            '!<%= config.src %>/coffee/chromereload.coffee'
            '!<%= config.src %>/coffee/plugins/*'
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
      production:
        options:
          data: (dest, src) -> return { production: true }
        files: [
          expand: true
          cwd: '<%= config.src %>/jade/'
          src: ['**/!(_)*.jade']
          dest: '<%= config.dist %>/views/'
          ext: '.html'
        ]
      develop:
        options:
          data: (dest, src) -> return { production: false }
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
      production:
        files: [
          '<%= config.dist %>/scripts/script.js': '<%= config.dist %>/scripts/script.js'
          '<%= config.dist %>/scripts/eventPage.js': '<%= config.dist %>/scripts/eventPage.js'
          '<%= config.dist %>/scripts/plugins/notification.js': '<%= config.dist %>/scripts/plugins/notification.js'
        ]

    cssmin:
      minify:
        expand: true
        src:  '*.css'
        cwd:  '<%= config.dist %>/css/'
        dest: '<%= config.dist %>/css/'
        ext:  '.css'

    chromeManifest:
      dist:
        options:
          buildnumber: false
          background:
            target: 'scripts/eventPage.js'
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
            "scripts/plugins/*.js"
            "scripts/eventPage.js"
            "views/template/**/*.html"
          ]
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
          archive: "package/chrome-<%= grunt.file.readJSON(config.dist + '/manifest.json').version %>.zip"
        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

    # Excec test.
    exec:
      test: "./node_modules/.bin/mocha-phantomjs -p ./node_modules/mocha-phantomjs/node_modules/phantomjs2/bin/phantomjs test/test.html"


  # tasks
  grunt.registerTask 'watch', ['esteWatch']
  grunt.registerTask 'minify', ['ngmin', 'uglify', 'cssmin']
  grunt.registerTask 'test', ['exec:test']

  grunt.registerTask 'dev', [
    'bower:install',
    'coffee:develop',
    'jade:develop',
    'stylus:develop']

  grunt.registerTask 'production', [
    'clean',
    'bower:install',
    'copy:dist',
    'coffee:production',
    'jade:production',
    'stylus:production',
    'minify'
  ]

  grunt.registerTask 'release-minor', [
    'production',
    'release:minor',
    'compress'
  ]

  grunt.registerTask 'release-patch', [
    'production',
    'release:patch',
    'compress'
  ]
