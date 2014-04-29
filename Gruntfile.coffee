module.exports = (grunt) ->

  # set variables
  config =
    app: 'app',
    dist: 'dist',
    manifest: grunt.file.readJSON('app/manifest.json'),

  # configure
  grunt.initConfig

    config: config

    connect:
      options:
        livereload: 35729,
        hostname: 'localhost',
        base: '<%= config.app %>'

    watch:
      options:
        livereload: true
      coffee:
        files: "coffee/**/*.coffee",
        tasks: ["coffee:develop"]
      test:
        files: "test/**/*.coffee"
        tasks: ["coffee:test"]
      stylus:
        files: "stylus/**/*.styl",
        tasks: ["stylus:develop"]
      jade:
        files: "jade/**/*.jade",
        tasks: ["jade:develop"]

    coffee:
      production:
        options:
          bare: true
          join: true
        files: [
          '<%= config.dist %>/scripts/script.js': [
            'coffee/app.coffee',
            'coffee/**/*.coffee',
            '!coffee/chromereload.coffee'
          ]
        ]
      develop:
        options:
          bare: true
        files: [
          expand: true
          cwd: 'coffee/'
          src: ['**/*.coffee']
          dest: '<%= config.app %>/scripts/'
          ext: '.js'
        ]
      test:
        options:
          bare: true
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
          expand: true
          cwd: 'stylus/'
          src: ['**/*.styl']
          dest: '<%= config.dist%>/css/'
          ext: '.css'
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
          data: (dest, src) ->
            return { production: true }
        files: [
          expand: true
          cwd: 'jade/'
          src: ['**/*.jade']
          dest: '<%= config.dist %>/views/'
          ext: '.html'
        ]
      develop:
        options:
          data: (dest, src) ->
            return { production: false }
        files: [
          expand: true
          cwd: 'jade/'
          src: ['**/*.jade']
          dest: '<%= config.app %>/views/'
          ext: '.html'
        ]

    bower:
      options:
        targetDir: './'
        install: true
        verbose: true
        cleanTargetDir: false
        cleanBowerDir: false
      dev:
        options:
          layout: (type, component) ->
            if type is 'css'
              return config.app + '/css/lib'
            else
              return config.app + '/scripts/lib'
      production:
        options:
          layout: (type, component) ->
            if type is 'css'
              return config.dist + '/css/lib'
            else
              return config.dist + '/scripts/lib'

    ngmin:
      production:
        src: '<%= config.dist %>/scripts/script.js'
        dest: '<%= config.dist %>/scripts/script.js'

    uglify:
      production:
        src: '<%= config.dist %>/scripts/script.js'
        dest: '<%= config.dist %>/scripts/script.min.js'

    chromeManifest:
      dist:
        options:
          buildnumber: true
          background:
            target: 'scripts/eventPage.js'
            exclude: [
              'scripts/chromereload.js'
            ]
        src: '<%= config.app %>'
        dest: '<%= config.dist %>'


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-chrome-manifest'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-bower-task'


  # tasks
  grunt.registerTask "run", ["connect", "watch"]
  grunt.registerTask "minify", ["ngmin", "uglify"]

  grunt.registerTask "dev", [
    "bower:dev",
    "coffee:develop",
    "jade:develop",
    "stylus:develop"]

  grunt.registerTask "production", [
    "bower:install",
    "chromeManifest:dist",
    "coffee:production",
    "jade:production",
    "stylus:production",
    "minify"]

