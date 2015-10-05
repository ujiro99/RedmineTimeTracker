module.exports = (grunt) ->

  # Load plugins automatically
  require("load-grunt-tasks") grunt

  # set variables
  config =
    app: 'app',
    dist: 'dist',
    manifest: grunt.file.readJSON('app/manifest.json'),

  # configure
  grunt.initConfig

    config: config

    esteWatch:
      options:
        dirs: [
            'coffee/**/',
            'stylus/**/',
            'jade/**/',
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
            cwd: 'coffee/'
            src: path.slice(path.indexOf('/'))
            dest: '<%= config.app %>/scripts/'
            ext: '.js'
          ]
        'coffee:compile'
      styl: (path) ->
        grunt.config 'stylus.options.compress', false
        grunt.config 'stylus.compile.files', [
          nonull: true
          expand: true
          cwd: 'stylus/'
          src: path.slice(path.indexOf('/'))
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
          cwd: 'jade/'
          ext: '.html'
          src: path.slice(path.indexOf('/'))
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
            'coffee/app.coffee',
            'coffee/log.coffee',
            'coffee/state.coffee',
            'coffee/config.coffee',
            'coffee/**/*.coffee',
            '!coffee/chromereload.coffee'
          ]
        ]
      develop:
        files: [
          expand: true
          cwd: 'coffee/'
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
            'stylus/**/*.styl'
          ]
        ]
      develop:
        files: [
          expand: true
          cwd: 'stylus/'
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
          cwd: 'jade/'
          src: ['**/*.jade']
          dest: '<%= config.dist %>/views/'
          ext: '.html'
        ]
      develop:
        options:
          data: (dest, src) -> return { production: false }
        files: [
          expand: true
          cwd: 'jade/'
          src: ['**/*.jade']
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
        src: '<%= config.dist %>/scripts/script.js'
        dest: '<%= config.dist %>/scripts/script.js'

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
          src: ["<%= config.dist %>/*"]
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
            "scripts/lib/*.js"
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
    'chromeManifest:dist',
    'compress'
  ]

  grunt.registerTask 'release-patch', [
    'production',
    'release:patch',
    'chromeManifest:dist',
    'compress'
  ]
