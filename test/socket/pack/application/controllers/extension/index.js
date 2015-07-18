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
    
    this._app = null;
    this._models = null;
    this._dayModel = null;
    this._socketIo = null;
    this._extensionSocketIo = null;
  }


  /**
   * setup
   * @param {Object} [_options] - 
   */
  Extension.prototype.setup = function( _keyData ) {
    console.log('[Controller] Extension -> setup');

    var keyData = _.extend({
      'app': null
    }, _keyData);

    if (keyData.app === null) {
      throw new Error("[Controller] Extension -> setup | [ReferenceError: keyData.app is not defined]");
    }

    this._app = keyData.app;
    this._models = this._app.get('models');
    this._dayModel = this._models.getModel('day');
    this._socketIo = this._app.get('socketIo');
    this._extensionSocketIo = this._socketIo.of(this._NAMESPACE);

    return (function(_this) {
      // socket.io の setup
      _this._extensionSocketIo.on('connection', function( socket ){
        console.log('[Controller] Extension -> connection');

        socket.on('join', function( _keyData, callback ){
          console.log('[Controller] Extension -> join');

          var keyData = _.extend({
            'roomId': null
          }, _keyData);

          console.log(keyData);

          if (keyData.roomId !== null) {
            // Room ID が指定されている場合の処理
            console.log('[Controller] Extension -> join | ID Join');

          } else {
            // Room ID が指定されていない場合の処理
            console.log('[Controller] Extension -> join | Random Join');

            // join できるルームだけ取得してくる
            // _this._dayModel.getRooms();

            // _this._dayModel.addRoom({
            //   'roomId': '000000'
            // });


            // _this._dayModel.getRooms();

            // _this._dayModel

            // _this._dayModel.addDay({
            //  'dayId': '20150717'
            // });
            // データベース上にJoin 可能なRoom Collection があるか調べる

          }

          // console.log(a);
          // これが呼ばれるとclient 側のemit 第3引数が呼び出される
          // callbecl('hello');
        });
      });
    })(this);

    // this._app = keyData.app;
    // this._models = this._app.get('models');
    // this._dayModel = this._models.getModel('day');
    // this._socketIo = this._app.get('socketIo');
    // this._extensionSocketIo = this._socketIo.of(this._NAMESPACE);

    
    // // socket.io の setup
    // this._extensionSocketIo.on('connection', function( socket ){
    //   console.log('[Controller] Extension -> connection');

    //   socket.on('join', function( _keyData, callback ){
    //     console.log('[Controller] Extension -> join');

    //     var keyData = _.extend({
    //       'roomId': null
    //     }, _keyData);

    //     console.log(keyData);

    //     if (keyData.roomId !== null) {
    //       // Room ID が指定されている場合の処理
    //       console.log('[Controller] Extension -> join | ID Join');

    //     } else {
    //       // Room ID が指定されていない場合の処理
    //       console.log('[Controller] Extension -> join | Random Join');
          
    //       // this._dayModel.addDay();
    //       // データベース上にJoin 可能なRoom Collection があるか調べる
          
    //     }

    //     // console.log(a);
    //     // これが呼ばれるとclient 側のemit 第3引数が呼び出される
    //     // callbecl('hello');
    //   });
    // });
  };





  return Extension;
})();


module.exports = Extension;