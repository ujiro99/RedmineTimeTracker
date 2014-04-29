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
        tasks: ["stylus"]

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
          dest: 'dist/scripts/'
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
      compile:
        files: [
          expand: true
          cwd: 'stylus/'
          src: ['**/*.styl']
          dest: 'dist/css/'
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
          dest: 'dist/views/'
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
          dest: 'dist/views/'
          ext: '.html'
        ]

    bower:
      install:
        options:
          targetDir: './'
          layout: (type, component) ->
            if type is 'css'
              return 'dist/css/lib'
            else
              return 'dist/scripts/lib'
          install: true
          verbose: true
          cleanTargetDir: false
          cleanBowerDir: false

    ngmin:
      production:
        src: 'dist/scripts/script.js'
        dest: 'dist/scripts/script.js'

    uglify:
      production:
        src: 'dist/scripts/script.js'
        dest: 'dist/scripts/script.min.js'


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-bower-task'


  # tasks
  grunt.registerTask "run", ["connect", "watch"]
  grunt.registerTask "minify", ["ngmin", "uglify"]
  grunt.registerTask "dev", ["bower:install", "coffee:develop", "jade:develop", "stylus"]
  grunt.registerTask "production", ["bower:install", "coffee:production", "jade:production", "stylus", "minify"]

