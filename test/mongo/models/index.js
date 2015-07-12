// ============================================================
// Models Module
var modelsInstance;
var Models;



Models = (function() {
  var config = require('config');
  var mongoose = require('mongoose');
  var utils = require(config.helpers + 'utils');

  
  // --------------------------------------------------------------
  function Models() {
    console.log('[Models] constructor');

    // データベースへ接続
    mongoose.connect('mongodb://localhost/is');

    this.db = mongoose.connection;

    this.db.on('error', function (err) {
      console.log('[Models] mongoDB connection error', err);
    });

    this.db.once('open', function () {
      console.log('[Models] mongoDB connected.');
    });
    

    this.models = {
      day: (function() {
        var Day = require(config.models + 'day');
        var day = new Day({
          'mongoose': mongoose
        });
        return day;
      })()
    };

    this.models.day.setup();

  }

  /**
   * getModel
   * @param {string} modelName - 取得するモデルクラス名
   * @return {Object} 引数で指定したmodelNameのモデルクラスのインスタンスを返す
   */
  Models.prototype.getModel = function( modelName ) {
    console.log('[Models] getModel(' + modelName + ')');
    var result = {};

    // modelNameで指定したインスタンスが存在するか
    try {
      if(this.models[modelName] != null){
        result = this.models[modelName];
        return result;
      }else{
        return result;
      }
    } catch (error) {
      return error;
    }
  };

  return Models;
})();



module.exports = modelsInstance = new Models();