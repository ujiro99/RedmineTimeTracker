module.exports = (grunt) ->

  grunt.initConfig

    connect:
      server:
        options:
          port: 35729
          base: '.'

    watch:
      coffee:
        files: "coffee/**/*.coffee",
        tasks: ["coffee"]

      coffee_with_test:
        files: ["coffee/**/*.coffee", 'test/**/*_test.coffee'],
        tasks: ["coffee:compile", 'simplemocha']

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
          dest: 'styles/'
          ext: '.css'
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

  grunt.loadNpmTasks 'grunt-contrib'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  grunt.registerTask "run", ["coffee","connect", "watch:coffee"]
  grunt.registerTask "run_with_test", ["coffee","connect", "watch:coffee_with_test"]
