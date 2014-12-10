// // ============================================================
// // Module
// var http = require("http");
// var httpProxy = require("http-proxy");

// // ============================================================
// // プロキシの設定
// var nginxProxy = new httpProxy.createProxyServer({
//   target: {
//     host: "localhost",
//     port: 3001
//   }
// });

// var nodeProxy = new httpProxy.createProxyServer({
//   target: {
//     host: "localhost",
//     port: 3000
//   }
// });

// var server = http.createServer(function(req, res){
//   console.log(res);

//   if (req.url !== "/favicon.ico") {
//     var href = req.headers.host + req.url;

//     console.log(href);

//     if (href === "is-eternal.me/") {
//       // nodeProxy.web(req, res);
//       nginxProxy.web(req, res);
//       // res.end("NGINX");
//     // //   // nginxProxy.web(req, res);
//     } else if (href === 'is-eternal.me/api/') {
//       // res.end("NODE");
//       nodeProxy.web(req, res);
//     } else {
//       res.end();
//     // //   res.writeHead(404);
//     // //   res.end("NOT FOUND");
//     }
//   }
//   // res.end("res end");
// });

// server.listen(80, function(){
//   process.setuid(500);
// });

// console.log("app run");