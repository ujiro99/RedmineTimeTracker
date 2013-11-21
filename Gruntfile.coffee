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

  # plugins
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'

  # tasks
  grunt.registerTask "run", ["connect", "watch"]
  grunt.registerTask "build", ["coffee", "jade", "stylus"]

