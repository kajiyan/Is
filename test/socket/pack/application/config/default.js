var fs = require('fs');
var path = require('path');


module.exports = (function(){
  var result = {};

  result.BASE_PATH = process.cwd();
  result.AVAILABLE_PERIOD = 0.25 * 24 * 60 * 60 * 1000;
  result.host = 'localhost';
  result.port = 8001;
  result.roomIdLength = 6;
  result.roomCapacity = 6;
  result.PUBLIC = path.join(result.BASE_PATH, 'public/');
  result.models = path.join(result.BASE_PATH, 'models/');
  result.views = path.join(result.BASE_PATH, 'views/');
  result.controllers = path.join(result.BASE_PATH, 'controllers/');
  result.routes = path.join(result.BASE_PATH, 'routes/');
  result.helpers = path.join(result.BASE_PATH, 'helpers/');

  return result;
})();

// module.exports = {
//   "BASE_PATH": process.cwd(),
//   "host": "localhost",
//   "port": 8001,
//   "roomIdLength": 6,
//   "roomCapacity": 6,
//   "AVAILABLE_PERIOD": 0.25 * 24 * 60 * 60 * 1000,
//   "models": path.join(__dirname, '../models/'),
//   "views": path.join(__dirname, '../views/'),
//   "controllers": path.join(__dirname, '../controllers/'),
//   "routes": path.join(__dirname, '../routes/'),
//   "helpers": path.join(__dirname, '../helpers/')
// };