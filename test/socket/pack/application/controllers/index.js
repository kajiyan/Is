// ============================================================
// Controllers Module
var ControllersInstance;
var Controllers;



Controllers = (function() {
  var config = require('config');
  var validator = require('validator');
  var _ = require('lodash');
  var helpers = {
    utils: require(config.helpers + 'utils')
  };

  
  // --------------------------------------------------------------
  /**
   * コントローラーをまとめて登録する。
   * @constructor
   * @classdesc コントローラーを管理するクラス
   */
  // --------------------------------------------------------------
  function Controllers() {
    console.log('[Controllers] Index -> constructor');

    this.app = {};

    this.controllers = {
      extension: (function() {
        var Extension = require( config.controllers + 'extension' );
        var extension = new Extension();
        return extension;
      })()
    };

    // ref = sn.bb.models;
    // for (key in ref) {
    //   model = ref[key];
    //   a;
    // }
  }

  // --------------------------------------------------------------
  /**
   * setup
   * @param {string} modelName - 取得するモデルクラス名
   * @return {Object} 引数で指定したmodelNameのモデルクラスのインスタンスを返す
   */
  // --------------------------------------------------------------
  Controllers.prototype.setup = function( _options ) {
    console.log('[Controllers] Index -> setup');

    // アプリケーションをセット
    this.app = module.parent.exports;

    var options = _.extend({
    }, _options);

    for ( var key in this.controllers ) {
      var value = this.controllers[key];
      value.setup({
        'app': this.app
      });
    }
  };


  // Controllers.prototype.getModel = function( modelName ) {
  //   console.log('[Controllers] getModel(' + modelName + ')');
  //   var result = {};

  //   // modelNameで指定したインスタンスが存在するか
  //   try {
  //     if(this.controllers[modelName] != null){
  //       result = this.controllers[modelName];
  //       return result;
  //     }else{
  //       return result;
  //     }
  //   } catch (error) {
  //     return error;
  //   }
  // };

  return Controllers;
})();



module.exports = ControllersInstance = new Controllers();