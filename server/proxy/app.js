var http = require("http");
var httpProxy = require("http-proxy");

var server = http.createServer(function(req, res){
  res.end("node app");
});

server.listen(80, function(){
  process.setuid(500);
});

console.log("app run");