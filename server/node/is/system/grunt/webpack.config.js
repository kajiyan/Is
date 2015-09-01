var path = require('path');
var webpack = require('webpack');

var setting = require("./app_components/config/setting.js");

module.exports = {
  // context: __dirname,
  cache: true,
  progress: true,
  entry: {
    typePack: "../system/coffee/"
  },
  output: {
    path: path.join(__dirname, "../application/public/js"),
    publicPath: setting.BASE_URL,
    filename: "[name].js",
    chunkFilename: '[chunkhash].js'
  },
  module: {
    loaders: [
      { test: /\.json$/, loader: "json-loader" },
      { test: /\.css$/, loader: "style-loader!css-loader" },
      { test: /\.scss$/, loader: "style!css!sass?outputStyle=expanded&includePaths[]=" + (path.resolve(__dirname, './bower_components/bootstrap-sass-official')) },
      { test: /\.coffee$/, loader: "coffee" },
      { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" },
      { test: /\.png$/, loader: "url-loader?prefix=images/&limit=5000" },
      { test: /\.jpg$/, loader: "url-loader?prefix=images/&limit=5000" },
      { test: /\.gif$/, loader: "url-loader?prefix=images/&limit=5000" },
      { test: /\.woff$/, loader: "url-loader?prefix=font/&limit=5000" },
      { test: /\.eot$/, loader: "file-loader?prefix=font/" },
      { test: /\.ttf$/, loader: "file-loader?prefix=font/" },
      { test: /\.svg$/, loader: "file-loader?prefix=font/" },
      { test: /\.wav$/, loader: "file-loader" },
      { test: /\.mp3$/, loader: "file-loader" }
    ]
  },
  resolve: {
    root: [path.join(__dirname, "app_components"), path.join(__dirname, "node_modules"), path.join(__dirname, "bower_components")],
    moduleDirectories: ["app_components", "node_modules", "bower_components"],
    extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
  },
  resolveLoader: {
    root: [path.join(__dirname, "app_components"), path.join(__dirname, "node_modules"), path.join(__dirname, "bower_components")]
  },
  plugins: [
    new webpack.ResolverPlugin([
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
    ]),
    new webpack.ProvidePlugin({
      jQuery: "jquery",
      $: "jquery",
      _: "underscore",
      Backbone: "backbone"
    })
  ]
};
