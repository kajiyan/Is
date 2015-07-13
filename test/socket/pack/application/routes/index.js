// var app = module.parent.exports;

// var express = require('express');
// var router = express.Router();

// console.log( app );

// /* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });

// module.exports = router;


// ============================================================
// Routes Module
var RoutesInstance;
var Routes;


Routes = (function() {
  var config = require('config');
  var express = require('express');
  var router = express.Router();
  var _ = require('lodash');

  // --------------------------------------------------------------
  function Routes() {
    console.log('[Routes] constructor');

    this.app = {};

    this.Routes = {
      'index': (function() {
        var Index = require( config.routes + 'index/' );
        var index = new Index({
          'rootURL': '/'
        });
        return index;
      })()
    };

    // this.Routes.day.setup();
  }


  Routes.prototype.setup = function( data ) {
    console.log('[Routes] setup');

    var options = _.extend({
      'app': module.parent.exports
    }, data);

    this.app = options.app;

    // URL ルーティングを設定する
    for ( var key in this.Routes ) {
      var value = this.Routes[key];
      value.setup({
        'app': this.app
      });
    }


    // catch 404 and forward to error handler
    this.app.use( function( req, res, next ) {
      var error = new Error( 'Not Found' );
      error.status = 404;
      next( error );
    });

    // error handlers

    // development error handler
    // will print stacktrace
    if ( this.app.get( 'env' ) === 'development' ) {
      this.app.use( function( error, req, res, next ) {
        res.status( error.status || 500 );
        res.render(
          'error',
          {
            'message': error.message,
            'error': error
          }
        );
      });
    }

    // production error handler
    // no stacktraces leaked to user
    this.app.use( function( error, req, res, next ) {
      res.status( error.status || 500 );
      res.render(
        'error',
        {
          'message': error.message,
          'error': {}
        }
      );
    });
    
  };

  return Routes;
})();



module.exports = RoutesInstance = new Routes();