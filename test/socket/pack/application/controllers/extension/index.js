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

        socket.join('test');
        // 接続が切れるとroom をデクリメントする

        socket.on('join', function( _keyData, callback ){
          console.log('[Controller] Extension -> join');

          var keyData = _.extend({
            'roomId': null
          }, _keyData);

          if (keyData.roomId !== null) {
            // Room ID が指定されている場合の処理
            console.log('[Controller] Extension -> join | ID Join');

          } else {
            // Room ID が指定されていない場合の処理
            console.log('[Controller] Extension -> join | Random Join');

            // _this._dayModel.addDay();

            // _this._dayModel.addAutomaticRoom({
            //   'roomId': '000000'
            // });
            
            var joinAutomaticRoom = (function(){

            })();

            Q.all([
              // join できるAutomaticRoom を取得してくる
              _this._dayModel.getAutomaticRooms({
                'query': {
                  'conditions': {
                    'capacity': { '$ne': 0 }
                  },
                  'projection': {
                    'roomId': 1
                  },
                  'options': {
                    'sort': {
                      'lastModified': 1
                    }
                  }
                }
              })
            ]).then(
              function(data) {
                console.log(data[0]);

                // join できるAutomaticRoomがある場合の処理
                if (data[0].length > 0) {
                  var joinRoom = (function(automaticRooms) {
                    var index = 0;
                    var len = automaticRooms.length;

                    return function(){
                      Q.all([
                        // join できるRoom のcapacity を減らす
                        _this._dayModel.updateAutomaticRoom({
                          'query': {
                            'conditions': {
                              '_id': automaticRooms[index]._id
                            },
                            'update': {
                              '$inc': {
                                'capacity': -1
                              }
                            }
                          }
                        })
                      ]).then(
                        function(data) {
                          // update に成功したAutomaticRoomへjoin する
                          if (data[0].ok) {
                            console.log('join - ' + automaticRooms[index].roomId);

                            socket.join(automaticRooms[index].roomId);
                            _this._extensionSocketIo.to(automaticRooms[index].roomId).emit('jointed','jointed!');
                          }
                        },
                        function(data) {
                          // update に失敗したら取得した他のAutomaticRoom への接続を試す
                          index++;
                          if (index < len) {
                            joinRoom();
                          } else {
                            // 新たにAutomaticRoom を作ってjoin する
                          }
                        }
                      );
                    };
                  })(data[0]);

                  joinRoom();

                } else {
                  // join できるAutomaticRoomがない場合の処理
                  console.log('Not Automatic Room');

                  Q.all([
                    // 現在のAutomaticRoom の数を取得して RoomIDを生成する
                    _this._dayModel.getNamberOfAutomaticRoom()
                  ]).then(
                    function(data) {
                      // data[0] にAutomaticRoom のDocument 数が返ってくるので
                      // この数値をベースに新しくAutomaticRoomを作る
                      return Q.all([
                        _this._dayModel.addAutomaticRoom({
                          'roomId': helpers.utils.getRoomId({
                            'baseNumber': data[0]
                          })
                        })
                      ]);
                    },
                    function(data) { /* reject */ }
                  ).then(
                    function(data){
                      // data[0] に追加されたAutomaticRoom が入っている

                      // console.log(data[0].roomId);
                      // socket.join(automaticRooms[index].roomId);

                      //こういう処理
                      // Q.all([
                      //   // join できるRoom のcapacity を減らす
                      //   _this._dayModel.updateAutomaticRoom({
                      //     'query': {
                      //       'conditions': {
                      //         '_id': automaticRooms[index]._id
                      //       },
                      //       'update': {
                      //         '$inc': {
                      //           'capacity': -1
                      //         }
                      //       }
                      //     }
                      //   })
                      // ]).then(
                      //   function(data) {
                      //     // update に成功したAutomaticRoomへjoin する
                      //     if (data[0].ok) {
                      //       console.log('join - ' + automaticRooms[index].roomId);

                      //       socket.join(automaticRooms[index].roomId);
                      //       _this._extensionSocketIo.to(automaticRooms[index].roomId).emit('jointed','jointed!');
                      //     }
                      //   },
                      //   function(data) {
                      //     // update に失敗したら取得した他のAutomaticRoom への接続を試す
                      //     index++;
                      //     if (index < len) {
                      //       joinRoom();
                      //     } else {
                      //       // 新たにAutomaticRoom を作ってjoin する
                      //     }
                      //   }
                      // );
                    },
                    function(data) { /* reject */ }
                  );
                }
              },
              function(data) {

              }
            );





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