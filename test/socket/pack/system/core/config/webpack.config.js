var SETTING = require("./setting.js")();

var config           = "/";
var appComponents    = "../../" + SETTING.BUILDER + "/app_components/";
var nodeModules      = "../../" + SETTING.BUILDER + "/node_modules/";
var bowerComponents  = "../../" + SETTING.BUILDER + "/bower_components/";

var webpack = require(nodeModules + "webpack");
var path    = require(nodeModules + "path");

module.exports = function(key, value) {

  var result = {
    // context: __dirname,
    cache: true,
    progress: true,
    entry: (function() {
      var result = {};
      // key, value がどちらとも指定されていなければ common js とみなす
      if ((typeof key !== "undefined" && key !== null) && (typeof value !== "undefined" && value !== null)){
        result["index"] = "../" + SETTING.SYSTEM_CORE + "/" + SETTING.ALT_JS + value;
      } else {
        result["common"] = SETTING.PATH.COMMON_ALT_JS + "/";
      }
      
      return result;
    })(),
    output: {
      path: path.join(__dirname, "../../../" + SETTING.DIST + "/" + SETTING.JS),
      publicPath: SETTING.BASE_URL,
      filename: "[name].js",
      chunkFilename: '[chunkhash].js'
    },
    devtool: "sourcemap",
    debug: SETTING.MODE === "DEBUG" ? true : false,
    module: {
      loaders: [
        { test: /\.json$/, loader: "json-loader" },
        { test: /\.css$/, loader: "style-loader!css-loader" },
        { test: /\.scss$/, loader: "style!css!sass?outputStyle=expanded&includePaths[]=" + (path.resolve(__dirname, './bower_components/bootstrap-sass-official')) },
        { test: /\.coffee$/, loader: "coffee" },
        { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" },
        { test: /\.png$/, loader: "url-loader?prefix=../images/&limit=5000" },
        { test: /\.jpg$/, loader: "url-loader?prefix=../images/&limit=5000" },
        { test: /\.gif$/, loader: "url-loader?prefix=../images/&limit=5000" },
        { test: /\.woff$/, loader: "url-loader?prefix=font/&limit=5000" },
        { test: /\.eot$/, loader: "file-loader?prefix=font/" },
        { test: /\.ttf$/, loader: "file-loader?prefix=font/" },
        { test: /\.svg$/, loader: "file-loader?prefix=font/" },
        { test: /\.wav$/, loader: "file-loader" },
        { test: /\.mp3$/, loader: "file-loader" }
      ]
    },
    resolve: {
      root: [
        __dirname,
        path.join(__dirname, config),
        path.join(__dirname, appComponents),
        path.join(__dirname, nodeModules),
        path.join(__dirname, bowerComponents)
      ],
      moduleDirectories: ["config", "app_components", "node_modules", "bower_components"],
      extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
    },
    resolveLoader: {
      root: [
        __dirname,
        path.join(__dirname, config),
        path.join(__dirname, appComponents),
        path.join(__dirname, nodeModules),
        path.join(__dirname, bowerComponents)
      ]
    },
    plugins: [
      new webpack.ResolverPlugin([
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
      ]),
      new webpack.DefinePlugin({
        "process.env": {
          "NODE_ENV": JSON.stringify("production")
        }
      }),
      new webpack.optimize.DedupePlugin(),
      // new webpack.optimize.UglifyJsPlugin(),
      new webpack.ProvidePlugin({
        jQuery: "jquery",
        $: "jquery",
        _: "underscore",
        Backbone: "backbone"
      })
    ]
  };

  return result;
};