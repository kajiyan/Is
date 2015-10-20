var fs = require('fs');
var path = require('path');


module.exports = (function(){
  var result = {};

  result.EXTENSION_ID = "deigneohddgilekagppfbninocicdjhp";
  result.BASE_PATH = process.cwd();
  result.AVAILABLE_PERIOD = 0.25 * 24 * 60 * 60 * 1000;
  result.protocol = 'http';
  result.host = '160.16.230.26';
  result.port = 8001;
  result.roomIdLength = 6;
  result.roomCapacity = 6;
  result.SOCKET_IO_URL = '/not-found/extention/';
  result.PUBLIC = path.join(result.BASE_PATH, 'public/');
  result.MEMORYS_DIR_NAME = 'memorys';
  result.MEMORYS_DIR_PATH = path.join(result.BASE_PATH, 'public/' + result.MEMORYS_DIR_NAME + '/');
  result.models = path.join(result.BASE_PATH, 'models/');
  result.views = path.join(result.BASE_PATH, 'views/');
  result.controllers = path.join(result.BASE_PATH, 'controllers/');
  result.routes = path.join(result.BASE_PATH, 'routes/');
  result.helpers = path.join(result.BASE_PATH, 'helpers/');

  return result;
})();