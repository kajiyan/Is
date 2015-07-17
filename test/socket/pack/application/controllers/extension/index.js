// ============================================================
// Extension Controller
var ExtensionInstance;
var Extension;


Extension = (function() {
  var config = require('config');
  var Q = require('q');
  var _ = require('lodash');
  var helpers = {
    utils: require(config.helpers + 'utils')
  };

  // --------------------------------------------------------------
  /**
   * ここの説明はコンストラクタの説明になる。
   * @constructor
   */
  // --------------------------------------------------------------
  function Extension( data ){
    console.log('[Controller] Extension -> constructor');

    this._NAMESPACE = 'extension'; // WebSocket の名前空間
    this._socketIo = null;
  }


  /**
   * setup
   * @param {Object} [_options] - 
   */
  Extension.prototype.setup = function( _options ) {
    console.log('[Controller] Extension -> setup');

    this.app = _options.app;

    var options = _.extend({
    }, _options);

    this._socketIo = this.app.get('socketIo').of(this._NAMESPACE);

    // socket.io の setup
    this._socketIo.on('connection', function( socket ){
      console.log('[Controller] Extension -> connection');
    });
  };





  return Extension;
})();


module.exports = Extension;