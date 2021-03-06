var fs = require('fs');
var path = require('path');

module.exports = {
  "host": "localhost",
  "port": 8000,
  "AVAILABLE_PERIOD": 0.25 * 24 * 60 * 60 * 1000,
  "models": path.join(__dirname, '../models/'),
  "views": path.join(__dirname, '../views/'),
  "controllers": path.join(__dirname, '../controllers/'),
  "helpers": path.join(__dirname, '../helpers/')
};