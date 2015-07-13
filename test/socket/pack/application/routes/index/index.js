// ============================================================
// Routes Index Module
var RouteIndex;

RouteIndex = (function() {
  var config = require('config');
  var express = require('express');
  var router = express.Router();
  var _ = require('lodash');

  // --------------------------------------------------------------
  function RouteIndex( data ) {
    console.log('[RouteIndex] Index -> constructor');

    var options = _.extend({
      'rootURL': ''
    }, data);

    this.app = {};
    this.rootURL = options.rootURL;


    // this.RouteIndex = {
    //   // day: (function() {
    //   //   var Day = require(config.RouteIndex + 'day');
    //   //   var day = new Day({
    //   //     'mongoose': mongoose
    //   //   });
    //   //   return day;
    //   // })()
    // };

    // // this.RouteIndex.day.setup();
  }


  RouteIndex.prototype.setup = function( data ) {
    console.log('[RouteIndex] Index -> setup');

    var options = _.extend({
      'app': module.parent.exports
    }, data);

    this.app = options.app;

    // ルーティングを設定する
    // ------------------------------------------------------------
    router.get('/', function(req, res, next) {
      var keyData = {};
      res.render('index.swig.html', keyData);
    });


    this.app.use( this.rootURL, router );
  };

  return RouteIndex;
})();



module.exports = RouteIndex;