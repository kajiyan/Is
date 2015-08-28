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

    this._NAMESPACE = 'extension'; // Web Socket の名前空間
    
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

    var modelsEventEmitter = this._models.getEventEmitter();
    modelsEventEmitter.addListener('databaseConnected', this._databaseConnectedHandler.bind(this));
  };

  // --------------------------------------------------------------
  /**
   * Extension#_setupSocket
   * 
   * 
   */
  // --------------------------------------------------------------
  Extension.prototype._setupSocket = function() {
    console.log('[Controller] Extension -> _setupSocket');
    
    (function(_this) {
      _this._extensionSocketIo.on('connection', function(socket) {
        console.log('[Controller] Extension -> connection');

        // console.log("----------");
        // console.log(socket.id);
        // console.log("----------");

        var joinRoomDocId = ''; // 所属するRoom Document のID
        var joinRoomId = ''; // 所属するRoom ID

        // --------------------------------------------------------------
        // 接続が切れるとroom をデクリメントする
        socket.on('disconnect', function() {
          console.log('[Controller] Extension -> disconnect', joinRoomDocId);

          // 同じRoom に所属するユーザーにSocket ID を送信する
          _this._extensionSocketIo
            .to(joinRoomId)
            .emit('checkOut', socket.id);

          // disconnect が発生したらそれまでユーザーが所属していたRoom の
          // capacity をインクリメントする
          _this._dayModel.updateAutomaticRoom({
            'query': {
              'conditions': {
                '_id': joinRoomDocId
              },
              'update': {
                '$inc': {
                  'capacity': 1
                }
              }
            }
          });
        });

        // --------------------------------------------------------------
        socket.on('join', function(_keyData, callback) {
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

            var createRoom = function() {
              Q.all([
                // 現在のAutomaticRoom の数を取得する
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
                function(data) {
                  console.log('resolve', data);
                  // data[0] に追加されたAutomaticRoom が入っている
                  var rooms = [];
                  rooms.push(data[0]);
                  joinRoom(rooms)();
                },
                function(data) {
                  console.log('reject', data);
                }
              );
            };

            var joinRoom = function(rooms) {
              console.log('joinRoom');

              var index = 0;
              var roomsLength = rooms.length;

              return function() {
                Q.all([
                  // join できるRoom のcapacity を減らす
                  _this._dayModel.updateAutomaticRoom({
                    'query': {
                      'conditions': {
                        '_id': rooms[index]._id
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
                    console.log(data[0]);
                    // update に成功したAutomaticRoomへjoin する
                    if (data[0].ok) {
                      // disconnect の際に使うMongo ID
                      joinRoomDocId = rooms[index]._id;
                      joinRoomId = rooms[index].roomId;

                      console.log('join - ' + joinRoomId);
                      socket.join(joinRoomId);

                      // // 同じRoom に所属するユーザーのSocket ID の配列を送信
                      // _this._extensionSocketIo
                      //   .to(joinRoomId)
                      //   .emit('checkIn', {
                      //     'users': _.keys(_this._extensionSocketIo.adapter.rooms[joinRoomId])}
                      //   );

                      // これが呼ばれるとclient 側のjoin emit 第3引数を呼び出す
                      callback();
                      // _this._extensionSocketIo
                      //   .to(socket.id)
                      //   .emit('jointed');
                    }
                  },
                  function(data) {
                    // update に失敗したら取得した他のAutomaticRoom への接続を試す
                    index++;
                    if (index < roomsLength) {
                      joinRoom();
                    } else {
                      // 新たにAutomaticRoom を作ってjoin する
                      createRoom();
                    }
                  }
                );
              };
            };

            Q.all([
              // join できるAutomaticRoom を取得してくる
              _this._dayModel.getAutomaticRooms({
                'populateSelect': {},
                'populateMatch': {
                  'capacity': { '$ne': 0 }
                },
                'populateOptions': {
                  'sort': { 'lastModified': 1 }
                }
              })
            ]).then(
              function(data) {
                console.log('getAutomaticRooms Length: ' + data[0].length);
                
                if (data[0].length > 0) {
                  // join できるAutomaticRoomがある場合の処理
                  joinRoom(data[0])();
                } else {
                  // join できるAutomaticRoomがない場合の処理
                  createRoom();
                }
              },
              function(data) { /* reject */ }
            );
          }

          // console.log(a);
          // これが呼ばれるとclient 側のemit 第3引数が呼び出される
          // callbecl('hello');
        });

        // --------------------------------------------------------------
        socket.on('initializeUser',
          /**
           * @param {Object} data
           * @prop {string} id - 接続ユーザーのsocket.id
           * @prop {number} position.x - 接続ユーザーのポインター x座標
           * @prop {number} position.y - 接続ユーザーのポインター y座標
           * @prop {number} width - 接続ユーザーのwindow の幅
           * @prop {number} height - 接続ユーザーのwindow の高さ
           * @prop {string} link - 接続ユーザーが閲覧していたページのURL
           * @prop {string} landscape - スクリーンショット（base64）
           */
          function(data) {
            // ポインターの初期値を送信者以外に送る
            socket
              .broadcast
              .to(joinRoomId)
              .emit('addUser', {
                'id': socket.id,
                'position': {
                  'x': data.position.x,
                  'y': data.position.y
                },
                'window': {
                  'width': data.window.width,
                  'height': data.window.height
                },
                'link': data.link,
                'landscape': data.landscape
              });
          }
        );

        // --------------------------------------------------------------
        socket.on('pointerMove', function(pointerPosition) {
          // console.log(pointerPosition);

          // ポインターの座標を送信者以外に送る
          // _this._extensionSocketIo
          socket
            .broadcast
            .to(joinRoomId)
            .emit('updatePointer', {
              'socketId': socket.id,
              'x': pointerPosition.x,
              'y': pointerPosition.y
            });
        });

        // --------------------------------------------------------------
        /**
         * 接続ユーザーのスクリーンショットが更新されたタイミングで通知される
         * 同じRoom にJoin しているユーザーに updateLandscape を発信する
         * @param {Object} data
         * @prop {string} landscape - スクリーンショット（base64）
         */
        // --------------------------------------------------------------
        socket.on('shootLandscape', function(data) {
          console.log('[Controller] Extension -> Socket Receive Message | pointerPosition');
          
          // 同じRoom に所属するユーザーにスクリーンショットをBase64 で発信する
          socket
            .broadcast
            .to(joinRoomId)
            .emit('updateLandscape', {
              'id': socket.id,
              'landscape': data.landscape
            });
        });
      });
    })(this);
  };


  // --------------------------------------------------------------
  /**
   * Extension#_databaseConnectedHandler
   * Models がデータベースへの接続が正常に完了したら呼び出されるイベントハンドラ 
   * ・起動時の日付のDay Document をデータベースに追加する
   * ・画像の書き出し先のフォルダを生成する
   * ・Socket.io の設定を行う
   */
  // --------------------------------------------------------------
  Extension.prototype._databaseConnectedHandler = function() {
    console.log('[Controller] Extension -> _databaseConnectedHandler');

    (function(_this) {
      Q.all([
        helpers.utils.mkdir({
          'dirName': config.MEMORYS_DIR_NAME
        })
      ])
      .fin(function() {
        Q.all([
          _this._dayModel.addDay(),
          helpers.utils.mkdir({
            'dirName': config.MEMORYS_DIR_NAME + '/' + helpers.utils.getDayId()
          })
        ])
        .fin(
          _this._setupSocket(_this)
        );
      });
    })(this);
    
    // テスト用
    // (function(_this) {
    //   console.log('call');
    //   _this._setupSocket(_this);
    // })(this);

    // this._dayModel.addMemory(
    //   config.base64,
    //   {
    //     'link': 'https://www.google.co.jp/',
    //     'window': {
    //       'width': 1920,
    //       'height': 1080
    //     },
    //     'positions': [
    //       { x: 0, y: 0 },
    //       { x: 0, y: 0 }
    //     ]
    //   }
    // );

    // this._dayModel.getRandomMemory({
    //   'options': {
    //     'limit': 1
    //   }
    // });

  };

  return Extension;
})();


module.exports = Extension;




















