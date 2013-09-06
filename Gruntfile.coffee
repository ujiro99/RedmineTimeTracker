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
        tasks: ["coffee"]
        options:
          livereload: true

      coffee_with_test:
        files: ["coffee/**/*.coffee", 'test/**/*_test.coffee'],
        tasks: ["coffee:compile", 'simplemocha']

      stylus:
        files: "stylus/**/*.styl",
        tasks: ["stylus"]

      jade:
        files: "jade/**/*.jade",
        tasks: ["jade"]

    coffee:
      compile:
        files: [
          expand: true
          cwd: 'coffee/'
          src: ['**/*.coffee']
          dest: 'scripts/'
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
      compile:
        files: [
          expand: true
          cwd: 'jade/'
          src: ['**/*.jade']
          dest: 'views/'
          ext: '.html'
        ]

    simplemocha:
      options:
        globals: ['should']
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
        compilers: 'coffee:coffee-script'
      all:
        src: 'test/**/*.coffee'

  # plugins
  grunt.loadNpmTasks 'grunt-contrib'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  # tasks
  grunt.registerTask "run", ["connect", "watch:coffee"]
  grunt.registerTask "run_with_test", ["coffee", "connect", "watch:coffee_with_test"]
