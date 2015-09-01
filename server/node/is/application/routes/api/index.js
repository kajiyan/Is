// ============================================================
// API DOCS
/*

 https://github.com/kajiyan/Is/blob/master/docs/api.md

*/



var express = require('express');
var router = express.Router();

// var app = module.parent.exports;
// app.get('socketio');

// router.get('/test', function(req, res) {
//   console.log('send socket');

//   var app = module.parent.exports;
//   app.get('socketio').sockets.on('connection', function (socket) {
//     console.log('connection');
//   });
//   res.end("");
//   // res.json({ hoge: 'huga' });
// });

// ============================================================
// SOCKET API
// http://is-eternal.me/api/socket/
router.get('/socket', function(req, res) {
  var app = module.parent.exports;
  var io = app.get('socketio');

  console.log('call');

  // io.sockets.on('connection', function (socket) {
  // //   // socket.join('room1');
  //   console.log('connection');

  // //   // ソケット通信が切断された時に呼ばれる
  // //   socket.on('disconnect', function () {
  // //     console.log('disconnect');
  // //   });
  // });

  // io.of('/receive').on('connection', function (socket) {
  //   console.log('receive connection');
  // });


  // res.end("socket API");
});

// ============================================================
// GET IS
// http://is-eternal.me/api/get-is/
router.get('/get-is', function(req, res) {
  res.end("get-is");
});

// ============================================================
// GET DAY IS
// http://is-eternal.me/api/get-is/
router.get('/get-day-is', function(req, res) {
  res.end("get-day-is");
});

// ============================================================
// GET SEARCH IS
// http://is-eternal.me/api/get-search-is/
router.get('/get-search-is', function(req, res) {
  res.end("get-search-is");
});

// ============================================================
// ADD IS
// http://is-eternal.me/api/add-is/
router.get('/add-is', function(req, res) {
  res.end("add-is");
});


module.exports = router;
