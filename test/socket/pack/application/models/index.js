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

    this.db.on('error', function (error) {
      console.log('[Models] mongoDB connection error', error);
    });

    this.db.once('open', function () {
      console.log('[Models] mongoDB connected.');
    });

    try {
      this.models = {
        'day': (function() {
          var Day = require(config.models + 'day');
          var day = new Day({
            'mongoose': mongoose
          });
          return day;
        })()
      };
    } catch (e) {
      console.log(e);
    }

    // this.models.day.setup();
  }

  // --------------------------------------------------------------
  /**
   * setup
   * コンストラクタで登録されたモデルのセットアップを行う
   */
  // --------------------------------------------------------------
  Models.prototype.setup = function() {
    console.log('[Models] Index -> setup');

    this.app = module.parent.exports;

    for ( var key in this.models ) {
      var value = this.models[key];
      value.setup({
        'app': this.app
      });
    }
  };


  // --------------------------------------------------------------
  /**
   * getModel
   * @param {string} modelName - 取得するモデルクラス名
   * @return {Object} 引数で指定したmodelNameのモデルクラスのインスタンスを返す
   */
  // --------------------------------------------------------------
  Models.prototype.getModel = function( modelName ) {
    console.log('[Models] getModel(' + modelName + ')');
    var result = {};

    try {
      if (typeof this.models[modelName] !== "undefined" && this.models[modelName] !== null) {
        result = this.models[modelName];
        return result;
      } else {
        throw new Error('[Models] getModel | Not: ' + modelName + ' Model');
      }
    } catch (error) {
      console.log(error);
    }
  };

  return Models;
})();



module.exports = modelsInstance = new Models();