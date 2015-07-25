// ============================================================
// Models Module
var modelsInstance;
var Models;





Models = (function() {
  var config = require('config');
  var events = require('events');
  var mongoose = require('mongoose');
  var Q = require('q');
  var _ = require('lodash');
  var utils = require(config.helpers + 'utils');

  
  // --------------------------------------------------------------
  function Models() {
    console.log('[Models] constructor');
    // events.EventEmitter.call(this);
    this.eventEmitter = new events.EventEmitter;

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
  }

  // --------------------------------------------------------------
  /**
   * Models#setup
   * データベースへの接続が完了した後、 
   * コンストラクタで登録されたモデルのセットアップを行う 
   * @return {Object} Q.promise
   */
  // --------------------------------------------------------------
  Models.prototype.setup = function() {
    console.log('[Models] Index -> setup');

    return (function(_this) {
      return Q.Promise(function(resolve, reject, notify) {
        _this.app = module.parent.exports;
      
        Q.all([
          _this._connect()
        ]).then(
          function() {
            // データベースへの接続成功したら、各モデルのセットアップを行う
            for ( var key in _this.models ) {
              var value = _this.models[key];
              value.setup({
                'app': _this.app
              });
            }
            resolve();
          },
          function(error) {
            reject();
            throw error;
          }
        );
      });
    })(this);
  };

  // --------------------------------------------------------------
  /**
   * Models#_connect
   * データベースへ接続する
   * @return {Object} Q.promise
   */
  // --------------------------------------------------------------
  Models.prototype._connect = function() {
    console.log('[Models] Index -> _connect');

    return (function(_this) {
      return Q.Promise(function(resolve, reject, notify) {
        // データベースへ接続
        mongoose.connect('mongodb://localhost/is');

        this.db = mongoose.connection;

        this.db.once('open', function() {
          console.log('[Models] mongoDB connected.');
          _this.eventEmitter.emit('databaseConnected');
          resolve();
        });

        this.db.on('error', function(error) {
          console.log('[Models] mongoDB connection error', error);
          reject(error);
        });
      });
    })(this);
  };

  // --------------------------------------------------------------
  Models.prototype.getEventEmitter = function() {
    return this.eventEmitter;
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