// ============================================================
// Controllers Module
var ControllersInstance;
var Controllers;



Controllers = (function() {
  var config = require('config');
  
  // --------------------------------------------------------------
  function Controllers() {
    console.log('[Controllers] constructor');

    this.controllers = {
      // day: (function() {
      //   var Day = require(config.Controllers + 'day');
      //   var day = new Day({
      //     'mongoose': mongoose
      //   });
      //   return day;
      // })()
    };

    // this.controllers.day.setup();

  }

  /**
   * getModel
   * @param {string} modelName - 取得するモデルクラス名
   * @return {Object} 引数で指定したmodelNameのモデルクラスのインスタンスを返す
   */
  Controllers.prototype.getModel = function( modelName ) {
    console.log('[Controllers] getModel(' + modelName + ')');
    var result = {};

    // modelNameで指定したインスタンスが存在するか
    try {
      if(this.controllers[modelName] != null){
        result = this.controllers[modelName];
        return result;
      }else{
        return result;
      }
    } catch (error) {
      return error;
    }
  };

  return Controllers;
})();



module.exports = ControllersInstance = new Controllers();