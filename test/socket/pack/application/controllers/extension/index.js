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

        // console.log(socket.handshake);
        // console.log(socket.handshake.headers.host.split(":").shift());
        // console.log(socket.handshake.headers.origin);

        // if (socket.handshake.headers.origin !== "") {
        //   return;
        // }

        socket.__joinRoomDocId = ''; // 所属するRoom Document のID
        socket.__joinRoomId = ''; // 所属するRoom ID

        // var joinRoomDocId = ''; // 所属するRoom Document のID
        // var joinRoomId = ''; // 所属するRoom ID

        // --------------------------------------------------------------
        // 接続が切れるとroom をデクリメントする
        socket.on('disconnect', function() {
          console.log('[Controller] Extension -> disconnect', socket.__joinRoomId, socket.__joinRoomDocId);

          capacity = config.roomCapacity - _.keys(_this._extensionSocketIo.adapter.rooms[socket.__joinRoomId]).length;

          // 同じRoom に所属するユーザーにSocket ID を送信する
          _this._extensionSocketIo
            .to(socket.__joinRoomId)
            .emit('checkOut', {
              'id': socket.id
            });

          // それまでユーザーが所属していたRoomのcapacity をインクリメントする
          _this._dayModel.updateAutomaticRoom({
            'query': {
              'conditions': {
                '_id': socket.__joinRoomDocId
              },
              'update': {
                'capacity': capacity
                // '$inc': {
                //   'capacity': capacity
                // }
              }
            }
          });
        });

        // --------------------------------------------------------------
        socket.on('join', function(_keyData, callback) {
          console.log('[Controller] Extension -> join');
          console.log(_keyData);

          var keyData = _.extend({
            'roomId': null
          }, _keyData);

          if (keyData.roomId !== null) {
            // Room ID が指定されている場合の処理 ManualRoomへのログイン
            console.log('[Controller] Extension -> join | ManualRoom');

            Q.fcall(
              function(){
                return _this._dayModel.getManualRooms({
                  'populateSelect': {
                    '__v': 0
                  },
                  'populateMatch': {
                    'compositeId': helpers.utils.getDayId() + keyData.roomId,
                  },
                  'populateOptions': {
                    'sort': { 'lastModified': 1 }
                  }
                });
              }
            )
            .then(
              function(manualRooms) {
                // 該当のcompositeIdのRoomがある場合、joinする
                var manualRoom = manualRooms[0].toJSON();

                _this._dayModel.updateManualRoom({
                  'query': {
                    'conditions': {
                      '_id': manualRoom._id
                    },
                    'update': {
                      'capacity': manualRoom.capacity - 1
                    },
                    'options': {
                      'runValidators': true
                    }
                  }
                })
                .then(
                  function(data) {
                    if (data.ok) {
                      socket.__joinRoomDocId = manualRoom._id;
                      socket.__joinRoomId = 'M-' + manualRoom.roomId;
                      console.log('join - ' + socket.__joinRoomId);
                      socket.join(socket.__joinRoomId);
                      callback({ status: 'success' });
                    }
                  },
                  function(error) { callback(error); }
                );
              },
              function(error) {
                console.log(error);
                // 該当のRoomがない場合、新たにRoomを作成する
                if (error.status === 'error' && error.type === 'NoneData') {
                  _this._dayModel.addManualRoom({
                    'roomId': keyData.roomId
                  })
                  .then(
                    function(manualRoom) {
                      // 作成したRoomのにjoinする
                      manualRoom.toJSON();
                      _this._dayModel.updateManualRoom({
                        'query': {
                          'conditions': {
                            '_id': manualRoom._id
                          },
                          'update': {
                            'capacity': manualRoom.capacity - 1
                          },
                          'options': {
                            'runValidators': true
                          }
                        }
                      })
                      .then(
                        function(data) {
                          if (data.ok) {
                            socket.__joinRoomDocId = manualRoom._id;
                            socket.__joinRoomId = 'M-' + manualRoom.roomId;
                            console.log('join - ' + socket.__joinRoomId);
                            socket.join(socket.__joinRoomId);
                            callback({ status: 'success' });
                          }
                        },
                        function(error) { callback(error); }
                      );
                    },
                    function(error) { callback(error); }
                  );
                } else {
                  // クエリにエラーがあろ場合、もしくはデータの問い合わせに失敗
                  callback(error);
                }
              }
            )
            .catch(function (error) {
              console.log(error);
              callback({
                status: 'error',
                type: 'Unknown',
                body: { message: 'Unknown error.' }
              });
            })
            .done();


          } else {
            // Room ID が指定されていない場合の処理
            console.log('[Controller] Extension -> join | AutomaticRoom');

            var createRoom = function() {
              _this._dayModel.getNamberOfAutomaticRoom()
                .then(
                  function(automaticRoomNum) {
                    // 引数に入った現在のAutomaticRoomのDocument数を
                    // ベースに新しくAutomaticRoomを作る
                    _this._dayModel.addAutomaticRoom({
                      'roomId': helpers.utils.getRoomId({
                        'baseNumber': automaticRoomNum
                      })
                    })
                    .then(
                      function(automaticRoom) {
                        joinRoom([automaticRoom])();
                      },
                      function(error) { callback(error); }
                    );
                  },
                  function(error) { callback(error); }
                );
            };


            var joinRoom = function(automaticRooms) {
              console.log('joinRoom - automaticRoom');

              var index = 0;
              var roomsLength = automaticRooms.length;
              return function() {
                Q.fcall(
                  function(){
                    // join できるRoom のcapacity を減らす
                    return _this._dayModel.updateAutomaticRoom({
                      'query': {
                        'conditions': {
                          '_id': automaticRooms[index]._id
                        },
                        'update': {
                          'capacity': automaticRooms[index].capacity - 1
                        },
                        'options': {
                          'runValidators': true
                        }
                      }
                    });
                  }
                )
                .then(
                  function(data) {
                    // update に成功したAutomaticRoomへjoinする
                    if (data.ok) {
                      // disconnectの際に使うMongoID
                      socket.__joinRoomDocId = automaticRooms[index]._id;
                      socket.__joinRoomId = 'A-' + automaticRooms[index].roomId;
                      console.log('join - ' + socket.__joinRoomId);
                      socket.join(socket.__joinRoomId);
                      callback({ status: 'success' });
                    }
                  },
                  function(error) {
                    // update に失敗したら取得した他のAutomaticRoom への接続を試す
                    index++;
                    if (index < roomsLength) {
                      joinRoom();
                    } else {
                      // 新たにAutomaticRoomを作ってjoinする
                      createRoom();
                    }
                  }
                )
                .catch(function (error) {
                  console.log(error);
                })
                .done();
              };
            };


            Q.fcall(
              function(){
                return _this._dayModel.getAutomaticRooms({
                  'populateSelect': {
                    '__v': 0
                  },
                  'populateMatch': {
                    'capacity': { '$ne': 0 }
                  },
                  'populateOptions': {
                    'sort': { 'lastModified': 1 }
                  }
                });
              }
            )
            .then(
              function(_automaticRooms) {
                // join できるAutomaticRoomがある場合の処理
                var automaticRooms = [];
                for (var i = 0, len = _automaticRooms.length; i < len; i++) {
                  automaticRooms[i] = _automaticRooms[i].toJSON();
                }
                joinRoom(automaticRooms)();
              },
              function(error) {
                // join できるAutomaticRoomがない場合の処理
                if (error.status === 'error' && error.type === 'NoneData') {
                  createRoom();
                }
              }
            )
            .catch(function (error) { console.log(error); })
            .done();
          }
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
            console.log('[Controller] Extension -> Socket Receive Message | initializeUser');

            // ポインターの初期値を送信者以外に送る
            socket
              .broadcast
              .to(socket.__joinRoomId)
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
        socket.on('initializeResident',
          /**
           * @param {Object} data
           * @prop {string} toSoketId - 送信先のsocketID
           * @prop {number} position.x - 接続ユーザーのポインター x座標
           * @prop {number} position.y - 接続ユーザーのポインター y座標
           * @prop {number} window.width - 接続ユーザーのwindow の幅
           * @prop {number} window.height - 接続ユーザーのwindow の高さ
           * @prop {string} link - 接続ユーザーが閲覧していたページのURL
           * @prop {string} landscape - スクリーンショット（base64）
           */
          function(data) {
            console.log('[Controller] Extension -> Socket Receive Message | initializeResident');

            socket
              .to(data.toSocketId)
              .emit('addResident', {
                'id': socket.id,
                'position': data.position,
                'window': data.window,
                'link': data.link,
                'landscape': data.landscape
              });
          }
        );

        // --------------------------------------------------------------
        socket.on('changeLocation',
          /**
           * @param {Object} data
           * @prop {string} link - 接続ユーザーの閲覧しているURL
           */
          function(data) {
            console.log('[Controller] Extension -> Socket Receive Message | changeLocation');
            
            socket
              .broadcast
              .to(socket.__joinRoomId)
              .emit('updateLocation', {
                'id': socket.id,
                'link': data.link
              });
          }
        );

        // --------------------------------------------------------------
        socket.on('windowResize',
          /**
           * @param {Object} windowSize
           * @prop {number} windowSize.width - 発信者のwindowの幅
           * @prop {number} windowSize.height - 発信者のwindowの高さ
           */
          function(windowSize) {
            console.log('[Controller] Extension -> Socket Receive Message | windowResize');

            socket
              .broadcast
              .to(socket.__joinRoomId)
              .emit('updateWindowSize', {
                'id': socket.id,
                'window': windowSize
              });
          }
        );

        // --------------------------------------------------------------
        socket.on('pointerMove', function(position) {
          // console.log(position);

          // ポインターの座標を送信者以外に送る
          // _this._extensionSocketIo
          socket
            .broadcast
            .to(socket.__joinRoomId)
            .emit('updatePointer', {
              'id': socket.id,
              'position': position
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
          console.log('[Controller] Extension -> Socket Receive Message | shootLandscape');
          
          // 同じRoom に所属するユーザーにスクリーンショットをBase64 で発信する
          socket
            .broadcast
            .to(socket.__joinRoomId)
            .emit('updateLandscape', {
              'id': socket.id,
              'landscape': data.landscape
            });
        });

        // --------------------------------------------------------------
        socket.on('addMemory',
          /**
           * @param {Object} data
           * @prop {string} link - 接続ユーザーの閲覧しているURL
           * @param {Object} window - 発信者のwindowのサイズ
           * @prop {number} window.width - 発信者のwindowの幅
           * @prop {number} window.height - 発信者のwindowの高さ
           * @prop {string} landscape - スクリーンショット（base64）
           * @param {[Object]} positions - 発信者のポインター軌跡の配列
           * @prop {number} positions[0].x - 発信者のポインターのx座標の軌跡
           * @prop {number} positions[0].y - 発信者のポインターのy座標の軌跡
           */
          function(data, callback) {
            console.log('[Controller] Extension -> Socket Receive Message | addMemory');
            // 通知されたデータをデータベースに保存する
            Q.fcall(
              function(){
                _this._dayModel.addMemory(data);
              }
            )
            .then(
              function(memory) {
                callback({
                  status: 'success'
                });
              }
            )
            .catch(function (error) {
              // console.log(error);
              callback({
                status: 'error',
                type: 'Unknown',
                body: { message: 'Unknown error.' }
              });
            })
            .done();
          }
        );

        // --------------------------------------------------------------
        socket.on('getMemory',
          /**
           * @param {Object} data
           * @prop {number} limit - 取得数
           */
          function(data, callback) {
            console.log('[Controller] Extension -> Socket Receive Message | addMemory');
                  
            Q.fcall(
              function(){
                return _this._dayModel.getRandomMemory({
                  'options': data
                });
              }
            )
            .then(
              function(memorys) {
                for (var i = 0, len = memorys.length; i < len; i++) {
                  memorys[i] = memorys[i].toJSON();
                  // console.log(memorys[i]);
                }
                return memorys;
              }
            )
            .catch(
              function (error) {
                console.log(error);
              }
            )
            .done(function(memorys){
              callback(memorys);
            });
          }
        );

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
    
    // // テスト用
    // (function(_this) {
    //   // 指定したRoomがあるか調べる
    //   var callback = function(data){
    //     console.log(data);
    //   };
    //   var keyData = {
    //     roomId: 'debug8'
    //   };
    //   var socket.__joinRoomDocId = '';
    //   var socket.__joinRoomId = '';
    //   var response = {};
    //   Q.fcall(
    //     function(){
    //       return _this._dayModel.getManualRooms({
    //         'populateSelect': {
    //           '__v': 0
    //         },
    //         'populateMatch': {
    //           'compositeId': helpers.utils.getDayId() + keyData.roomId,
    //         },
    //         'populateOptions': {
    //           'sort': { 'lastModified': 1 }
    //         }
    //       });
    //     }
    //   )
    //   .then(
    //     function(manualRooms) {
    //       // 該当のcompositeIdのRoomがある場合
    //       var manualRoom = manualRooms[0].toJSON();

    //       _this._dayModel.updateManualRoom({
    //         'query': {
    //           'conditions': {
    //             '_id': manualRoom._id
    //           },
    //           'update': {
    //             'capacity': manualRoom.capacity - 1
    //           },
    //           'options': {
    //             'runValidators': true
    //           }
    //         }
    //       })
    //       .then(
    //         function(data) {
    //           if (data.ok) {
    //             socket.__joinRoomDocId = manualRoom._id;
    //             socket.__joinRoomId = 'M-' + manualRoom.roomId;

    //             console.log('join - ' + socket.__joinRoomId);
    //             // socket.join(socket.__joinRoomId);

    //             // これが呼ばれるとclient 側のjoin emit 第3引数を呼び出す
    //             callback({
    //               status: 'success'
    //             });
    //           }
    //         },
    //         function(error) {
    //           callback(error);
    //         }
    //       );
    //     },
    //     function(error) {
    //       // データの抽出、クエリにエラーがある場合
    //       console.log("reject");

    //       // 該当のRoomがない場合、新たにRoomを作成する
    //       if (error.status === 'error' && error.type === 'NoneData') {
    //         _this._dayModel.addManualRoom({
    //           'roomId': keyData.roomId
    //         })
    //         .then(
    //           function(manualRoom) {
    //             console.log("resolve");
                
    //             // 作成したRoomのにjoinする
    //             manualRoom.toJSON();

    //             _this._dayModel.updateManualRoom({
    //               'query': {
    //                 'conditions': {
    //                   '_id': manualRoom._id
    //                 },
    //                 'update': {
    //                   'capacity': manualRoom.capacity - 1
    //                 },
    //                 'options': {
    //                   'runValidators': true
    //                 }
    //               }
    //             })
    //             .then(
    //               function(data) {
    //                 if (data.ok) {
    //                   socket.__joinRoomDocId = manualRoom._id;
    //                   socket.__joinRoomId = 'M-' + manualRoom.roomId;

    //                   console.log('join - ' + socket.__joinRoomId);
    //                   // socket.join(socket.__joinRoomId);

    //                   callback({ status: 'success' });
    //                 }
    //               },
    //               function(error) {
    //                 callback(error);
    //               }
    //             );
    //           },
    //           function(error) {
    //             console.log("reject");
    //           }
    //         );

    //       } else {
    //         callback(error);
    //       }
    //     }
    //   )
    //   .catch(function (error) {
    //     console.log(error);
    //   })
    //   .done();
    // })(this);



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

    // Memory のsparse取得
    // (function(_this) {
    //   Q.fcall(
    //     function(){
    //       return _this._dayModel.getRandomMemory({
    //         'options': {
    //           'limit': 1
    //         }
    //       });
    //     }
    //   )
    //   .then(
    //     function(memorys) {
    //       for (var i = 0, len = memorys.length; i < len; i++) {
    //         memorys[i] = memorys[i].toJSON();
    //       }
    //       console.log(memorys[0]);

    //       return memorys;
    //     }
    //   )
    //   .catch(
    //     function (error) {
    //       console.log(error);
    //     }
    //   )
    //   .done(function(memorys){
    //     console.log(memorys);
    //   });
    // })(this);
  };

  return Extension;
})();


module.exports = Extension;




















