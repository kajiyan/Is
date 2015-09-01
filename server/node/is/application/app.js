// ============================================================
// PACKAGE
var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var swig = require('swig');
var io = require('socket.io');
var debug = require('debug');

var app = express();

// ============================================================
// MODULE
var socketController = require('./src/socket/controller.js');


// view engine setup
app.engine('html', swig.renderFile);
app.set('view cache', true);
swig.setDefaults({ cache: false });
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'swig');



// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));



// ============================================================
// SERVER
debug('Is');
app.set('port', process.env.PORT || 3000);
var server = app.listen(app.get('port'), function() {
  debug('Express server listening on port ' + server.address().port);
});
app.set('socketio', io.listen(server));
socketController(app.get('socketio').sockets);



// ============================================================
// ROUTER
var routes = require('./routes/index');
var api = require('./routes/api/index');
app.use('/', routes);
app.use('/api', api);


// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error.swig.html', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error.swig.html', {
        message: err.message,
        error: {}
    });
});


module.exports = app;