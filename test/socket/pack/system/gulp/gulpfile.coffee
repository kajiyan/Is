# gulp --ENV -m production -l false
# gulp --ENV -m debug -l false
# gulp --ENV -m debug -l true

"use strict"


gulp        = require "gulp"
util        = require "gulp-util"
webpack     = require "gulp-webpack" 
swig        = require "gulp-swig"
compass     = require "gulp-compass"
coffee      = require "gulp-coffee"
concat      = require "gulp-concat"
minify      = require "gulp-minify-css"
rename      = require "gulp-rename"
plumber     = require "gulp-plumber"
notify      = require "gulp-notify"
using       = require "gulp-using"
cached      = require "gulp-cached"
size        = require "gulp-size"
sourceMaps  = require "gulp-sourcemaps"
rename      = require "gulp-rename"
watch       = require "gulp-watch"
runSequence = require "run-sequence"
browserSync = require "browser-sync"
path        = require "path"
minimist    = require "minimist"


# minimistでコマンドライン引数をパース
env = minimist(process.argv.slice(2))

SETTING = require("../core/config/setting.js")( env )

# ------------------------------
plumberWithNotify = ->
  return plumber
    errorHandler: notify.onError "<%= error.message %>"


for key, value of SETTING.TARGET
  # ------------------------------
  # swig
  # ------------------------------
  gulp.task "#{key}TemplateEngine", do ->
    _key = if key is "index" then "" else key
    _value = value

    return () ->
      options = 
        data: SETTING
        defaults:
          cache: false

      return gulp.src ["#{SETTING.CORE}#{SETTING.ENGINE}#{_value}/*.#{SETTING.ENGINE_ATTRIBUTE}.html"]
        .pipe plumberWithNotify()
        .pipe using()
        .pipe cached()
        .pipe swig(options)
        .pipe rename (filePath) ->
          filePath.basename = path.basename filePath.basename, ".#{SETTING.ENGINE_ATTRIBUTE}"
          return
        .pipe gulp.dest "#{SETTING.DIST}#{_value.replace(/\//, "")}"

  # ------------------------------
  # compass
  # ------------------------------
  gulp.task "#{key}Compass", do ->
    _key = if key is "index" then "" else key + "/"
    _value = value

    return () ->
      # console.log "#{path.join(__dirname, SETTING.DIST)}#{_value.replace(/\//, "")}"

      return gulp.src ["#{SETTING.CORE}#{SETTING.STYLE}#{_value}/#{SETTING.CSS}/*.scss"]
        .pipe plumberWithNotify()
        .pipe using()
        .pipe cached()
        .pipe compass
          project_path: __dirname
          css: "#{SETTING.DIST}"
          sass: "#{path.join(__dirname, "..")}/#{path.basename("#{SETTING.CORE}")}/#{SETTING.STYLE}"
          image: "#{SETTING.DIST}"
          javascript: "#{SETTING.DIST}#{SETTING.JS}"
          font: "#{SETTING.DIST}#{SETTING.FONT}"
        .pipe gulp.dest "#{SETTING.DIST}"

  # ------------------------------
  # webpack
  # ------------------------------
  gulp.task "#{key}Webpack", do ->
    _key = key
    _value = if value is "" then "/index" else value

    return () ->
      # return gulp.src ["#{SETTING.CORE}#{SETTING.ALT_JS}/pack#{value}/*.coffee", "#{SETTING.CORE}#{SETTING.ALT_JS}/pack#{value}/**/*.coffee"]
      return gulp.src "#{SETTING.CORE}#{SETTING.ALT_JS}/pack#{value}/*.coffee"
        .pipe plumberWithNotify()
        .pipe using()
        .pipe cached()
        .pipe webpack require("#{SETTING.CORE}config/webpack.config.js")(_key, _value)
        .pipe gulp.dest "#{SETTING.DIST}#{_value.replace(/^\/index|^\//, "")}/#{SETTING.JS}"


# ------------------------------
# extensionAppWebpack
# ------------------------------
gulp.task "extensionAppWebpack", ->
  return gulp.src "##{SETTING.CORE}#{SETTING.ALT_JS}/extension/app/*.coffee"
    .pipe plumberWithNotify()
    .pipe using()
    .pipe cached()
    .pipe webpack require("../core/config/webpack.config.js")("app", "/extension/app/")
    .pipe gulp.dest "#{SETTING.DIST}#{SETTING.JS}/extension/app"


# ------------------------------
# contentScriptWebpack
# ------------------------------
gulp.task "contentScriptWebpack", ->
  return gulp.src "##{SETTING.CORE}#{SETTING.ALT_JS}/content-scripts/*.coffee"
    .pipe plumberWithNotify()
    .pipe using()
    .pipe cached()
    .pipe webpack require("../core/config/webpack.config.js")("contentScript", "/extension/content-script/")
    .pipe gulp.dest "#{SETTING.DIST}#{SETTING.JS}/extension/content-script"


# ------------------------------
# backgroundWebpack
# ------------------------------
gulp.task "backgroundWebpack", ->
  return gulp.src "##{SETTING.CORE}#{SETTING.ALT_JS}/background/*.coffee"
    .pipe plumberWithNotify()
    .pipe using()
    .pipe cached()
    .pipe webpack require("../core/config/webpack.config.js")("background", "/extension/background/")
    .pipe gulp.dest "#{SETTING.DIST}#{SETTING.JS}/extension/background"


# ------------------------------
# commonWebpack
# ------------------------------
gulp.task "commonWebpack", ->
  return gulp.src "#{SETTING.PATH.COMMON_ALT_JS}pack/*.coffee"
    .pipe plumberWithNotify()
    .pipe using()
    .pipe cached()
    .pipe webpack require("../core/config/webpack.config.js")()
    .pipe gulp.dest "#{SETTING.PATH.COMMON_FILE}#{SETTING.JS}"
    .pipe gulp.dest "#{SETTING.DIST}#{SETTING.COMMON}/#{SETTING.JS}"


# ------------------------------
# server
# ------------------------------
gulp.task "server", ->
  return browserSync
    server:
      baseDir: "#{SETTING.DIST}"
    port: "#{SETTING.DEBUG_LOCAL_PORT}"


# ------------------------------
# compass -> optimize
# ------------------------------
gulp.task "compassOptimize", ->
  runSequence "compass", "optimize"


# ------------------------------
# File watching
# ------------------------------
# gulp.task "watch", ["server"], ->
gulp.task "watch", ->
  for key, value of SETTING.TARGET
    gulp.watch(
      ["#{SETTING.CORE}#{SETTING.ENGINE}#{value}/*.#{SETTING.ENGINE_ATTRIBUTE}.html"]
      ["#{key}TemplateEngine", browserSync.reload]
    )
    gulp.watch(
      ["#{SETTING.CORE}#{SETTING.STYLE}#{value}/#{SETTING.CSS}/*.scss"]
      ["#{key}Compass", browserSync.reload]
    )
    gulp.watch(
      ["#{SETTING.CORE}#{SETTING.ALT_JS}/app/#{value}/*.coffee"
       "#{SETTING.CORE}#{SETTING.ALT_JS}/app/#{value}/**/*.coffee"]
      ["#{key}Webpack", browserSync.reload]
    )

  gulp.watch(
    ["#{SETTING.CORE}#{SETTING.ALT_JS}/extension/app/*.coffee"
     "#{SETTING.CORE}#{SETTING.ALT_JS}/extension/app/**/*.coffee"]
    ["extensionAppWebpack", browserSync.reload]
  )

  gulp.watch(
    ["#{SETTING.CORE}#{SETTING.ALT_JS}/extension/content-script/*.coffee"
     "#{SETTING.CORE}#{SETTING.ALT_JS}/extension/content-script/**/*.coffee"]
    ["contentScriptWebpack", browserSync.reload]
  )

  gulp.watch(
    ["#{SETTING.CORE}#{SETTING.ALT_JS}/extension/background/*.coffee"
     "#{SETTING.CORE}#{SETTING.ALT_JS}/extension/background/**/*.coffee"]
    ["backgroundWebpack", browserSync.reload]
  )

  gulp.watch(
    ["#{SETTING.PATH.COMMON_ALT_JS}*.coffee"]
    ["commonWebpack", browserSync.reload]
  )


# Task List
gulp.task "default", ["watch"]

gulp.task "build", () ->
  for key, value of SETTING.TARGET
    runSequence "#{key}TemplateEngine", "#{key}Compass", "#{key}Webpack"