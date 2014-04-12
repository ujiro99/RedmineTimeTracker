module.exports = (grunt) ->

  # configure
  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    connect:
      server:
        options:
          port: 35729
          base: '.'

    watch:
      coffee:
        files: "coffee/**/*.coffee",
        tasks: ["coffee:develop"]
        options:
          livereload: true

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
          'scripts/script.js': ['coffee/app.coffee', 'coffee/**/*.coffee']
        ]
      develop:
        options:
          bare: true
        files: [
          expand: true
          cwd: 'coffee/'
          src: ['**/*.coffee']
          dest: 'scripts/'
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
          dest: 'css/'
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
          dest: 'views/'
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
          dest: 'views/'
          ext: '.html'
        ]

    ngmin:
      production:
        src: 'scripts/script.js'
        dest: 'scripts/script.js'

    uglify:
      production:
        src: 'scripts/script.js'
        dest: 'scripts/script.min.js'


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ngmin'


  # tasks
  grunt.registerTask "run", ["connect", "watch"]
  grunt.registerTask "minify", ["ngmin", "uglify"]
  grunt.registerTask "dev", ["coffee:develop", "jade:develop", "stylus", "minify"]
  grunt.registerTask "production", ["coffee:production", "jade:production", "stylus", "minify"]

