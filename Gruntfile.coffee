'use strict'
module.exports = (grunt) ->
  require('load-grunt-tasks') grunt
  require('time-grunt') grunt

  grunt.initConfig
    app:
      app: 'app'
      dist: 'www'
      tmp: '.tmp'

    cfg: {}

    hoodie: start: options: callback: (cfg) ->
      grunt.config.set 'cfg', cfg

    watch:
      options:
        livereload: '<%= connect.options.livereload %>'

      js:
        files: ['<%= app.app %>/scripts/**/*.js']
        tasks: ['jshint:watch']

      styles:
        files: ['<%= app.tmp %>/styles/main.css']

      view:
        files: ['<%= app.app %>/index.html', '<%= app.app %>/views/**/*.html']

      less:
        options:
          livereload: off
        files: ['<%= app.app %>/styles/**/*.less']
        tasks: ['less:styles']

      gruntfile:
        files: ['Gruntfile.js']

    connect:
      options:
        port: 9000
        hostname: '0.0.0.0'
        livereload: 35729
        middleware: (connect, options) ->
          unless Array.isArray options.base
            options.base = [options.base]

          middlewares = [require('grunt-connect-proxy/lib/utils').proxyRequest]
          options.base.forEach (base) -> middlewares.push connect.static base
          directory = options.directory or options.base[options.base.length - 1]
          middlewares.push connect.directory directory

          middlewares

      livereload:
        options:
          open: true
          base: [
            '<%= app.tmp %>'
            '<%= app.app %>'
          ]
        proxies: [
          context: '/_api'
          host: '<%= cfg.stack.www.host %>'
          port: '<%= cfg.stack.www.port %>'
        ]

    jshint:
      options:
        jshintrc: '.jshintrc'
        force: yes
      watch: [ '<%= app.app %>/scripts/**/*.js' ]

    clean:
      dist:
        files: [
          dot: true
          src: [
            '<%= app.tmp %>'
            '<%= app.dist %>/*'
            '!<%= app.dist %>/.git*'
          ]
        ]

      server: '<%= app.tmp %>'

    useminPrepare:
      html: '<%= app.app %>/index.html'
      options:
        dest: '<%= app.dist %>'

    rev:
      dist:
        files:
          src: [
            '<%= app.dist %>/scripts/**/*.js'
            '<%= app.dist %>/styles/**/*.css'
          ]

    usemin:
      html: ['<%= app.dist %>/**/*.html']
      css: ['<%= app.tmp %>/styles/**/*.css']
      options:
        assetsDirs: ['<%= app.dist %>']

    manifest:
      generate:
        options:
          basePath: '<%= app.dist %>'
          preferOnline: yes
          verbose: no
          cache: ['/_api/_files/hoodie.js']
        src: [
          'scripts/*.js'
          'styles/*.css'
          'img/*.{gif,png,jpg}'
        ]
        dest: '<%= app.dist %>/manifest.appcache'

    less:
      styles:
        src: ['<%= app.app %>/styles/main.less']
        dest: '<%= app.tmp %>/styles/main.css'

    copy:
      dist:
        files: [
          src: ['<%= app.app %>/bower_components/my-first-hoodie/www/assets/img/pattern_130.gif']
          dest: '<%= app.dist %>/img/pattern_130.gif'
        ,
          expand: true
          dot: true
          cwd: '<%= app.app %>'
          dest: '<%= app.dist %>'
          src: [
            'index.html'
          ]
        ]

    bump: options:
      commitMessage: 'v%VERSION%'
      files: ['package.json', 'bower.json']

  grunt.registerTask 'serve', [
    'clean:server'
    'hoodie'
    'less:styles'
    'connect:livereload'
    'configureProxies:livereload'
    'watch'
  ]

  # TODO: remove "continueOn" hack to work around https://github.com/yeoman/grunt-usemin/issues/291
  grunt.registerTask 'build', [
    'clean'
    'less:styles'
    'continueOn'
    'useminPrepare'
    'continueOff'
    'copy'
    'concat'
    'uglify'
    'cssmin'
    'rev'
    'manifest'
    'usemin'
  ]

  grunt.registerTask 'default', ['build']
