exclude = [
  '!**/.DS_Store'
  '!**/Thumbs.db'
  '!**/_*'
  '!**/*.haml'
  '!**/*.coffee'
  '!**/*.map'
  '!**/*.scss'
  '!**/scss/*'
  '!**/*.less'
  '!**/less/*'
  '!**/css.compile/*'
  '!**/*.s.css'
  '!**/*.l.css'
  '!**/<%= dir.cssCompile %>/'
  '!**/haml/'
  '!**/coffee/'
  '!**/sass/'
  '!**/less/'
  '!**/_notes/'
  '!**/.idea/'
  '!**/.gitignore'
  '!**/*.mno'
  '!**/Templates/'
  '!**/Library'
  '!**/*.dwt'
  '!**/*.lbi'
  '!**/*.fla'
]

module.exports = (grunt) ->
  HOST = "localhost"
  PORT = 8080

  pkg = grunt.file.readJSON "package.json"

  grunt.file.expand("node_modules/grunt-*/tasks").forEach(grunt.loadTasks)
  # for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    # grunt.loadNpmTasks taskName

  webpack = require "webpack"
  webpackConfig = require "./webpack.config.js"

  grunt.initConfig
    # ------------------------------
    # DIRECTORY SETTING
    # ------------------------------
    dir :
      system      : "../../system"
      application : "../../application"
      dist        : "../../dist"
      js          : "js"
      coffee      : "coffee"
      sass        : "sass"
      css         : "compile/css"
      cssCompile  : "<%= dir.src %>/css.compile"
      webpack     : "pack"

    # ------------------------------
    # package.json file loading
    # ------------------------------
    pkg : pkg
    
  #   # ------------------------------
  #   #  CLEAN
  #   # ------------------------------
  #   clean:
  #     js:
  #       src : "<%= dir.src %>/<%= dir.js %>/*"
  #     css:
  #       src : "<%= dir.src %>/<%= dir.css %>/*"
  #     build :
  #       src : ["<%= dir.dist %>/**", "<%= dir.doc %>/**"]
    
  #   # ------------------------------
  #   # CoffeeScript compile
  #   # ------------------------------
  #   coffee:
  #     options:
  #       sourceMap : true
  #     # Main Directory coffeeScript File Compile
  #     main :
  #       expand: true
  #       cwd: "<%= dir.src %>/<%= dir.coffee %>/"
  #       src : ["*.coffee"]
  #       dest : "<%= dir.src %>/<%= dir.js %>/"
  #       ext: ".js"
  #     # coffeeScript File all Compile
  #     all :
  #       expand : true
  #       ext : ".js"
  #       src : ["<%= dir.src %>/**/*.coffee", "<%= dir.src %>/**/**/*.coffee"]
    
    # ------------------------------
    # SASS(Compass) compile
    # ------------------------------
    compass:
      # Main Directory SASS File Compile
      main :
        expand: true
        ext : ".css"
        src : ["<%= dir.system %>/<%= dir.sass %>/*.scss"]
        options :
          config : "config.rb"
          environment: "production"
          force: true
  #     # SASS File all Compile
  #     all :
  #       expand : true
  #       ext : ".css"
  #       src : ["<%= dir.src %>/**/*.scss", "<%= dir.src %>/**/**/*.scss"]
  #       options :
  #         config : "config.rb"
  #         environment: "production"
  #         force: true
    
  #   # ------------------------------
  #   # File Concat
  #   # ------------------------------
  #   concat:
  #     # Compiled CSS file concat
  #     css :
  #       src : "<%= dir.cssCompile %>/*.css"
  #       dest : "<%= dir.src %>/<%= dir.css %>/style.css"
  #       # dest : "<%= dir.src %>/<%= dir.css %>/<%= pkg.name %>.css"
    
  #   # ------------------------------
  #   # Image File Optimization
  #   # ------------------------------
  #   imagemin:
  #     dev :
  #       optimizationLevel: 3
  #       files : [
  #         expand: true
  #         src: "<%= dir.src %>/**/*.{png,jpg,jpeg}"
  #       ]
  #     dist :
  #       optimizationLevel: 3
  #       files : [
  #         expand: true
  #         src: "<%= dir.dist %>/**/*.{png,jpg,jpeg}"
  #       ]
    
  #   # ------------------------------
  #   # copy
  #   # ------------------------------
  #   copy:
  #     build :
  #       expand : true
  #       filter: "isFile"
  #       cwd : "<%= dir.src %>/"
  #       src : ["**"].concat exclude
  #       dest : "<%= dir.dist %>/"
    
  #   # ------------------------------
  #   # HTML minify
  #   # ------------------------------
  #   htmlmin:
  #     all :
  #       options :
  #         removeComments : true
  #         removeCommentsFromCDATA : true
  #         removeCDATASectionsFromCDATA : true
  #         collapseWhitespace : true
  #         removeRedundantAttributes : true
  #         removeOptionalTags : true
  #       expand : true
  #       src : "<%= dir.dist %>/**/*.html"
    
  #   # ------------------------------
  #   # JS minify
  #   # ------------------------------
  #   uglify:
  #     options :
  #       banner: "/*! <%= pkg.name %> <%= grunt.template.today('dd-mm-yyyy') %> */\n"
  #     main :
  #       expand : true
  #       src : "<%= dir.dist %>/<%= dir.js %>/*.js"
  #       # src : "<%= dir.dist %>/<%= dir.js %>/<%= pkg.name %>.js"
  #     all :
  #       expand : true
  #       src : ["<%= dir.dist %>/**/*.js", "!<%= uglify.main.src %>"]
    
  #   # ------------------------------
  #   # CSS minify
  #   # ------------------------------
  #   cssmin:
  #     main :
  #       expand : true
  #       src : "<$= dir.dist %>/<%= dir.css %>/<%= pkg.name %>.css"
  #     # all :
  #     #   expand : true
  #     #   src : ["<%= dir.dist %>/**/*.css", "!<%= cssmin.main.src %>"]

    # ------------------------------
    # BOWER
    # ------------------------------
    bower:
      install:
        options: 
          targetDir: "<%= dir.system %>/<%= dir.js %>/lib/"
          layout: "byType" # or "byComponent"
          install: true
          verbose: false
          cleanTargetDir: true
          cleanBowerDir: false

    # ------------------------------
    #  WEB PACK
    # ------------------------------
    webpack:
      options: webpackConfig
      build:
        plugins: webpackConfig.plugins.concat(
          new webpack.DefinePlugin({
            "process.env": {
              "NODE_ENV": JSON.stringify("production")
            }
          }),
          new webpack.optimize.DedupePlugin(),
          new webpack.optimize.UglifyJsPlugin()
        )
      "build-dev":
        devtool: "sourcemap"
        debug: true
    "webpack-dev-server": 
      options: 
        webpack: webpackConfig
        publicPath: "/" + webpackConfig.output.publicPath
        # publicPath: webpackConfig.output.publicPath
        contentBase: "../application/public/"
      start: 
        keepAlive: true
        webpack: 
          devtool: "eval"
          debug: true
    # open:
    #   dev:
    #     path: "http://" + HOST + ":" + PORT + "/"
    #     options: 
    #       delay: 500
    #   webpackDev:
    #     path: "http://" + HOST + ":" + PORT + "/webpack-dev-server/index.html"
    #     options: 
    #       delay: 500

    # ------------------------------
    # Test Server
    # ------------------------------
    # connect:
    #   server:
    #     options: 
    #       hostname: HOST
    #       port: PORT
    #       base: "<%= dir.system %>/compile/"
    #   livereload: 
    #     options: 
    #       port: PORT

    # ------------------------------
    # File watching
    # ------------------------------
    watch:
      options:
        livereload: true
      html:
        files : [
          "<%= dir.src %>/compile/*.html",
          "<%= dir.src %>/compile/**/*.html",
          "<%= dir.src %>/compile/**/**/*.html"
        ]
      # coffee:
      #   files : [
      #     "<%= dir.src %>/<%= dir.coffee %>/*.coffee",
      #     "!<%= dir.src %>/<%= dir.coffee %>/**/index.coffee",
      #     "!<%= dir.src %>/<%= dir.coffee %>/index.coffee",
      #     "!<%= dir.src %>/<%= dir.coffee %>/wp-*.coffee"
      #   ]
  #       tasks : ["coffee:main"]
  #     # coffeeAll:
  #     #   files : '<%= coffee.all.src %>'
  #     #   tasks : 'coffee:all'
  #     compass:
  #       files : [
  #         "<%= dir.src %>/<%= dir.sass %>/*.scss",
  #         "!<%= dir.src %>/<%= dir.sass %>/wp-*.scss"
  #       ]
  #       tasks : ["compass:main"]
  #     # compassAll:
  #     #   files : '<%= compass.all.src %>'
  #     #   tasks : 'compass:all'
  #     css:
  #       files : "<%= concat.css.src %>"
  #     wpJs:
  #       files : [
  #         "<%= dir.src %>/<%= dir.js %>/<%= dir.webpack %>/*.js",
  #         "<%= dir.src %>/<%= dir.js %>/<%= dir.webpack %>/**/*.coffee"
  #       ]
  #       tasks : ["webpack:build-dev"]
      wpCoffee:
        files : [
          "<%= dir.system %>/<%= dir.coffee %>/*.coffee",
          "<%= dir.system %>/<%= dir.coffee %>/**/*.coffee"
        ]
        tasks : ["webpack:build-dev"]
      wpCompass:
        files : ["<%= dir.system %>/<%= dir.sass %>/wp-*.scss"]
        tasks : ["compass:main"]


  #   # ------------------------------
  #   # yuidoc
  #   # ------------------------------
  #   yuidoc:
  #     dist:
  #       name : "<%= pkg.name %>"
  #       description : "<%= pkg.description %>"
  #       version : "<%= pkg.version %>"
  #     options :
  #       paths : "<%= dir.src %>/"
  #       outdir : "<%= dir.doc %>"
  #       syntaxtype : "coffee"
  #       extension : ".coffee"

  #   # ------------------------------
  #   # Style Guide
  #   # ------------------------------
  #   styledocco:
  #     dist: 
  #       options:
  #         name: "<%= pkg.name %>"
  #         preprocessor: "scss --compass"
  #       files:
  #         "<%= dir.doc %>/styleguide": ["<%= dir.src %>/sass/*.scss"]


  # Ailas
  grunt.registerTask "default", ["bower:install", "watch"]

  # # Ailas
  # grunt.registerTask "default", ["bower:install", "open:dev", "connect:server", "watch"]
  # grunt.registerTask "w", "watch"
  # grunt.registerTask "lib", "bower:install"
  # grunt.registerTask "c", ["clean:js",  "clean:css"]
  # grunt.registerTask "main", ["coffee:main", "compass:main"]
  # grunt.registerTask "compile", ["coffee:all", "compass:all"]
  # grunt.registerTask "img", "imagemin:dev"
  # grunt.registerTask "build", ["clean:build", "copy", "imagemin:dist", "htmlmin", "uglify:main", "cssmin"]
  # grunt.registerTask "guide", ["yuidoc", "styledocco"]

  # # Ailas - WEBPACK  
  # # Development webpack server
  # grunt.registerTask "wp", ["bower:install", "open:webpackDev", "webpack-dev-server:start"]
  # # Production build
  # grunt.registerTask "wpbuild", ["webpack:build", "clean:build", "copy", "imagemin:dist", "htmlmin", "uglify:main", "cssmin"]