module.exports = (grunt) ->

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
          extensions: ['coffee', 'stylus', 'jade', 'html']
      # extension settings
      coffee: (path) ->
        grunt.config 'coffee.options.bare', true
        if path.match(/test/)
          grunt.config 'coffee.compile.files', [
            expand: true
            cwd: 'test/'
            src: path
            dest: 'test/'
            ext: '.js'
          ]
        else
          grunt.config 'coffee.compile.files', [
            expand: true
            cwd: 'coffee/'
            src: path
            dest: '<%= config.app %>/scripts/'
            ext: '.js'
          ]
        'coffee:compile'
      styl: (path) ->
        grunt.config 'stylus.options.compress', false
        grunt.config 'stylus.compile.files', [
          expand: true
          cwd: 'stylus/'
          src: path
          dest: '<%= config.app %>/css/'
          ext: '.css'
        ]
        'stylus:compile'
      jade: (path) ->
        grunt.config 'jade.options.data', { production: false }
        grunt.config 'jade.options.pretty', true
        grunt.config 'jade.compile.files', [
          expand: true
          cwd: 'jade/'
          ext: '.html'
          src: path
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
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadNpmTasks 'grunt-chrome-manifest'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-bower-task'


  # tasks
  grunt.registerTask 'watch', ['esteWatch']
  grunt.registerTask 'minify', ['ngmin', 'uglify']

  grunt.registerTask 'dev', [
    'bower:dev',
    'coffee:develop',
    'jade:develop',
    'stylus:develop']

  grunt.registerTask 'production', [
    'bower:production',
    'chromeManifest:dist',
    'coffee:production',
    'jade:production',
    'stylus:production',
    'minify']

