// ============================================================
// Day
var DayInstance;
var Day;

// ============================================================
/* 
  Day
    - setup
    - getRooms
 */
// ============================================================



Day = (function() {
  var config = require('config');
  var Q = require('q');
  var _ = require('lodash');
  var validator = require('validator');
  var helpers = {
    utils: require(config.helpers + 'utils')
  };

  // --------------------------------------------------------------
  /**
   * Day Class
   * @param {Object} _keyData - インスタンスの初期値を設定する
   * @prop {Object} mongoose - mongoose オブジェクト
   * @throws {string} keyDataが指定されていなければエラーメッセージをスローする
   */
  // --------------------------------------------------------------
  function Day(_keyData) {
    console.log('[Model] Day -> constructor');

    var keyData = _.extend({
      'mongoose': null
    }, _keyData);
    
    if (keyData.mongoose !== null) {
      this.mongoose = keyData.mongoose;
    } else {
      throw new Error("[Model] Day -> constructor | [ReferenceError: keyData.mongoose is not defined]");
    }
  }



  // --------------------------------------------------------------
  Day.prototype.setup = function(_keyData) {
    console.log('[Model] Day -> setup');

    var keyData = _.extend({
      'app': null
    }, _keyData);

    if (keyData.app === null) {
      throw new Error("[Model] Day -> setup | [ReferenceError: keyData.app is not defined]");
    }

    var mongoose = this.mongoose;

    // Memory Schema 定義
    var MemorySchema = new mongoose.Schema(
      {
        dayId: {
          type: String,
          required: true
        },
        link: String,
        window: {
          width: Number,
          height: Number
        },
        ext: {
          type: String,
          required: true
        },
        positions: [
          {
            _id: false,
            x: Number,
            y: Number
          }
        ],
        random: {
          type: [Number, Number],
          default: [Math.random(), 0],
          index: '2d'
        },
        createAt: { type: Date, default: new Date() }
      },
      {
        toJSON: {
          virtuals: true
        }
      }
    );
    
    MemorySchema
      .virtual('url')
      .get(function() {
        var result = '';
        var port = '';
         
        if (config['port'] !== null) {
          port = ':' + config['port'];
        }

        result = config.protocol + '://' + config.host + port + '/memorys/' + this.dayId + '/' + this._id;
        return result;
      });

    MemorySchema
      .virtual('landscape')
      .get(function() {
        var result = '';
        var port = '';
         
        if (config['port'] !== null) {
          port = ':' + config['port'];
        }

        result = config.protocol + '://' + config.host + port + '/memorys/' + this.dayId + '/' + this._id + this.ext;
        return result;
      });

    // MemorySchema
    //   .virtual('imgSrc')
    //   .get(function() {
    //     var result = '';
    //     var port = '';
         
    //     if (config['port'] !== null) {
    //       port = ':' + config['port'];
    //     }

    //     result = '//' + config.host + port + '/memorys/' + this.dayId + '/' + this._id + this.ext;
    //     return result;
    //   });


    // ManualRoom Schema の定義
    var ManualRoomSchema = new mongoose.Schema(
      {
        dayId: {
          type: String,
          required: true,
          index: true
        },
        roomId: {
          type: String,
          required: true,
          index: true
        },
        compositeId: {
          type: String,
          required: true,
          index: {
            unique: true,
            sparse: true
          }
        },
        capacity: {
          type: Number,
          min: 0,
          max: config.roomCapacity,
          default: config.roomCapacity
        },
        lastModified: { type: Date, default: new Date() },
      },
      {
        toJSON: {
          virtuals: true
        }
      }
    );

    // AutomaticRoom Schema の定義
    var AutomaticRoomSchema = new mongoose.Schema(
      {
        dayId: {
          type: String,
          required: true,
          index: true
        },
        roomId: {
          type: String,
          required: true,
          index: true
        },
        compositeId: {
          type: String,
          required: true,
          index: {
            unique: true,
            sparse: true
          }
        },
        capacity: {
          type: Number,
          min: 0,
          max: config.roomCapacity,
          default: config.roomCapacity
        },
        lastModified: { type: Date, default: new Date() },
      },
      {
        toJSON: {
          virtuals: true
        }
      }
    );


    // Day スキーマの定義
    var DaySchema = new mongoose.Schema({
      dayId: {
        type: String,
        required: true,
        index: {
          unique: true,
          sparse: true
        }
      },
      manualRooms: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ManualRoom'
      }],
      automaticRooms: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'AutomaticRoom'
      }],
      memorys: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Memory'
      }],
      createAt: { type: Date, default: new Date() }
    });

    this.Model = {
      'Memory': mongoose.model('Memory', MemorySchema),
      'ManualRoom': mongoose.model('ManualRoom', ManualRoomSchema),
      'AutomaticRoom': mongoose.model('AutomaticRoom', AutomaticRoomSchema),
      'Day': mongoose.model('Day', DaySchema)
    };
  };





  // --------------------------------------------------------------
  /**
   * Day Class -> getDay
   * @param {Object} _query -
   *   id: 取得するDay Collection のID を指定する
   *       何も指定されていなければサーバー内の時間を
   *       ベースに生成されたid　をクエリのキーにする
   * @return {Object} Q promise を返す
   *
   * Day Document を返す 
   *
   */
  // --------------------------------------------------------------
  Day.prototype.getDay = function( _query ) {
    console.log('[Models] Day -> getDay');
    
    var query = _.extend({
      id: helpers.utils.getDayID()
    }, _query);

    var defer = Q.defer();

    this.Model.Day
      .findById( query.id )
      .exec(function( error, doc ){
        if( error ){
          defer.reject( error );
          return;
        }

        defer.resolve( doc );
      });

    return defer.promise;
  };





  // --------------------------------------------------------------
  /**
   * Day Class -> addAutomaticRoom
   * @param {Object} _query
   * @prop {String} dayId - 
   *   取得するDay Collection のID を指定する
   *   何も指定されていなければサーバー内の時間を
   *   ベースに生成されたid　をクエリのキーにする
   * @prop {String} roomId - 
   *   追加するRoom Dcumentに設定するroomId を
   *   数字6桁で構成された文字列で設定する
   * @return {Object} Q promise を返す
   *
   * Day Document を返す 
   */
  // --------------------------------------------------------------
  Day.prototype.addAutomaticRoom = function( _query ) {
    console.log('[Model] Day -> addAutomaticRoom');

    try {
      var query = _.extend({
        'dayId': helpers.utils.getDayId(),
        'roomId': null
      }, _query);
      
      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          // クエリをバリデーションする
          if(
            !validator.isNumeric(query.roomId) ||
            !validator.isLength(query.roomId, 6)
          ) {
            rreject({
              status: 'error',
              type: 'BudQuery',
              body: { message: 'There is a problem with the query.' }
            });
            return;
          }

          // 追加するAutomaticRoom ドキュメントを作る
          var result = {};
          var room = new _this.Model.AutomaticRoom({
            'dayId': query.dayId,
            'roomId': query.roomId,
            'compositeId': query.dayId + query.roomId,
            'lastModified': new Date()
          });

          // ドキュメントを追加する
          room.save(function(error, doc, numberAffected) {
            // console.log(error, doc, numberAffected);
            if (error) {
              reject(error);
              return;
            }

            result = doc;

            // ドキュメントの追加が成功したら 
            // クエリで指定されているdayId を持つDay Collection に 
            // 追加されたRoom の_id を追加する 
            _this.Model.Day
              .findOneAndUpdate(
                { 'dayId': query.dayId },
                {
                  '$push': {
                    'automaticRooms': doc._id
                  }
                },
                {
                  'new': true,
                  'upsert': true
                }
              )
              .exec(function(error, doc) {
                // console.log(error, doc);
                if (error) {
                  reject(error);
                  return;
                }

                resolve(result);
              });
          });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // --------------------------------------------------------------
  /**
   * Day Class -> addManualRoom
   * @param {Object} _query
   * @prop {String} dayId - 
   *   追加するManualRoom Collection のDayID を指定する
   *   何も指定されていなければサーバー内の時間をベースに生成されたidをクエリのキーにする
   * @prop {String} roomId - 
   *   追加するRoom Dcumentに設定するroomId を半角英数字6桁で構成された文字列で設定する
   * @return {Object} Q promise を返す
   */
  // --------------------------------------------------------------
  Day.prototype.addManualRoom = function(_query) {
    console.log('[Model] Day -> addManualRoom');

    try {
      var query = _.extend({
        'dayId': helpers.utils.getDayId(),
        'roomId': null
      }, _query);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          if(
            !validator.isAlphanumeric(query.roomId) ||
            !validator.isLength(query.roomId, 6)
          ) {
            reject({
              status: 'error',
              type: 'BudQuery',
              body: { message: 'There is a problem with the query.' }
            });
            return;
          }

          var result = {};
          var room = new _this.Model.ManualRoom({
            'dayId': query.dayId,
            'roomId': query.roomId,
            'compositeId': query.dayId + query.roomId,
            'lastModified': new Date()
          });

          room.save(function(error, doc, numberAffected) {
            console.log(error, doc, numberAffected);
            if (error) {
              reject(error);
              return;
            }

            result = doc;

            _this.Model.Day
              .findOneAndUpdate(
                {
                  'dayId': query.dayId
                },
                {
                  '$push': {
                    'manualRooms': doc._id
                  }
                },
                {
                  'new': true,
                  'upsert': true
                }
              )
              .exec(function(error, doc) {
                // console.log(error, doc);
                if (error) {
                  reject(error);
                  return;
                }

                resolve(result);
              });
          });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // --------------------------------------------------------------
  /**
   * Day#getNamberOfAutomaticRoom
   * @param {Object} [_query] - クエリを指定する
   * @prop {string} dayId - カウント対象のdayId を指定する
   *
   * promiseの状態がresolve　になるとAutomaticRoom Document の数を返す 
   */
  // --------------------------------------------------------------
  Day.prototype.getNamberOfAutomaticRoom = function(_query) {
    console.log('[Model] Day -> getNamberOfAutomaticRoom');

    try {
      var query = _.extend({
        'dayId': helpers.utils.getDayId()
      }, _query);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          // クエリをバリデーションする
          if (
            !validator.isNumeric(query.dayId) ||
            !validator.isLength(query.dayId, 8, 8)
          ) {
            reject({
              status: 'error',
              type: 'BudQuery',
              body: { message: 'There is a problem with the query.' }
            });
            return;
          }

          _this.Model.AutomaticRoom
            .count(query)
            .exec(function(error, doc, numberAffected) {
              console.log(error, doc, numberAffected);

              if (error) {
                reject({
                  status: 'error',
                  type: 'FailedExtraction',
                  body: { message: 'Failed to extraction of data.' }
                });
                return;
              }
              resolve(doc);
            });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // --------------------------------------------------------------
  /**
   * Day Class -> getAutomaticRooms
   * @param {Object} _keyData
   * @prop {Object} query - mongoose.find に設定するクエリ
   * @prop {Object} query.conditions - 取得条件
   * @prop {String} query.projection - 取得するフィールド
   * @prop {String} query.options - ソートやリミット、オフセットの指定
   * @return {Object} Q promise を返す
   *
   * promise　の状態がresolve　になるとAutomaticRoom Document を返す 
   */
  // --------------------------------------------------------------
  Day.prototype.getAutomaticRooms = function( _query ) {
    console.log('[Model] Day -> getAutomaticRooms');

    try {
       var query = _.extend({
        'dayId': helpers.utils.getDayId(),
        'populatePath': 'automaticRooms',
        'populateSelect': {},
        'populateMatch': {},
        'populateOptions': {}
      }, _query);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          // クエリをバリデーションする
          if (
            !validator.isNumeric(query.dayId) ||
            !validator.isLength(query.dayId, 8, 8)
          ) {
            reject({
              status: 'error',
              type: 'BudQuery',
              body: { message: 'There is a problem with the query.' }
            });
            return;
          }

          _this.Model.Day
            .findOne({
              'dayId': query.dayId
            })
            .populate({
              'path': query.populatePath,
              'select': query.populateSelect,
              'match': query.populateMatch,
              'options': query.populateOptions
            })
            .select({
              '_id': 0,
              'automaticRooms': 1
            })
            .exec(function(error, doc, numberAffected) {
              // console.log(error, doc.automaticRooms, numberAffected);
              if (error) {
                reject({
                  status: 'error',
                  type: 'FailedExtraction',
                  body: { message: 'Failed to extraction of data.' }
                });
                return;
              }

              if (doc.automaticRooms.length > 0) {
                resolve(doc.automaticRooms);
              } else {
                reject({
                  status: 'error',
                  type: 'NoneData',
                  body: { message: 'There is no corresponding data.' }
                });
              }
            });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };


  // --------------------------------------------------------------
  /**
   * Day Class -> getManualRooms
   */
  // --------------------------------------------------------------
  Day.prototype.getManualRooms = function(_query) {
    console.log('[Model] Day -> getManualRooms');

    try {
       var query = _.extend({
        'dayId': helpers.utils.getDayId(),
        'populatePath': 'manualRooms',
        'populateSelect': {},
        'populateMatch': {},
        'populateOptions': {}
      }, _query);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          if (
            !validator.isNumeric(query.dayId) ||
            !validator.isLength(query.dayId, 8, 8) ||
            !validator.isAlphanumeric(query.populateMatch.compositeId) ||
            !validator.isLength(query.populateMatch.compositeId, 14, 14)
          ) {
            reject({
              status: 'error',
              type: 'BudQuery',
              body: { message: 'There is a problem with the query.' }
            });
            return;
          }

          _this.Model.Day
            .findOne({
              'dayId': query.dayId
            })
            .populate({
              'path': query.populatePath,
              'select': query.populateSelect,
              'match': query.populateMatch,
              'options': query.populateOptions
            })
            .select({
              '_id': 0,
              'manualRooms': 1
            })
            .exec(function(error, doc, numberAffected) {
              // console.log(error, doc.manualRooms, numberAffected);
              if (error) {
                reject({
                  status: 'error',
                  type: 'FailedExtraction',
                  body: { message: 'Failed to extraction of data.' }
                });
                return;
              }

              if (doc.manualRooms.length > 0) {
                resolve(doc.manualRooms);
              } else {
                reject({
                  status: 'error',
                  type: 'NoneData',
                  body: { message: 'There is no corresponding data.' }
                });
              }
            });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };


  // --------------------------------------------------------------
  /**
   * Day Class -> updateAutomaticRoom
   */
  // --------------------------------------------------------------
  Day.prototype.updateAutomaticRoom = function( _keyData ) {
    console.log('[Model] Day -> updateAutomaticRoom');

    try {
      var keyData = _.extend({
        'query': {
          'conditions': {},
          'update': {},
          'options': {},
          'callback': {}
        }
      }, _keyData);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          _this.Model.AutomaticRoom
            .update(
              keyData.query.conditions,
              keyData.query.update,
              keyData.query.options,
              keyData.query.callback
            )
            .exec(function(error, doc, numberAffected) {
              console.log(error, doc, numberAffected);

              if (error) {
                // Roomのcapacityに空きがない場合
                if (error.errors.capacity) {
                  reject({
                    status: 'error',
                    type: 'CapacityOver',
                    body: { message: 'We have reached capacity.' }
                  });
                  return;
                }
                // updateの対象オブジェクトがない場合
                reject({
                  status: 'error',
                  type: 'FailedExtraction',
                  body: { message: 'Failed to extraction of data.' }
                });
                return;
              }
              resolve(doc);
            });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };


  // --------------------------------------------------------------
  /**
   * Day Class -> updateManualRoom
   */
  // --------------------------------------------------------------
  Day.prototype.updateManualRoom = function(_keyData) {
    console.log('[Model] Day -> updateManualRoom');

    try {
      var keyData = _.extend({
        'query': {
          'conditions': {},
          'update': {},
          'options': {},
          'callback': {}
        }
      }, _keyData);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          _this.Model.ManualRoom
            .update(
              keyData.query.conditions,
              keyData.query.update,
              keyData.query.options,
              keyData.query.callback
            )
            .exec(function(error, doc, numberAffected) {
              // console.log(error, doc, numberAffected);

              if (error) {
                // Roomのcapacityに空きがない場合
                if (error.errors.capacity) {
                  reject({
                    status: 'error',
                    type: 'CapacityOver',
                    body: { message: 'We have reached capacity.' }
                  });
                  return;
                }
                // updateの対象オブジェクトがない場合
                reject({
                  status: 'error',
                  type: 'FailedExtraction',
                  body: { message: 'Failed to extraction of data.' }
                });
                return;
              }
              resolve(doc);
            });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };



  // Day.prototype.addRoom = function( data ) {
  //   console.log('[Models] Day -> addRoom');

  //   var query = _.extend({
  //     'dayID': helpers.utils.getDayID(),
  //     'roomID': null
  //   }, data);

  //   return (function(_this) {
  //     return Q.Promise(function( resolve, reject, notify ) {
  //       var room = new _this.Model.Room({
  //         'roomID': query['roomID'],
  //         'memorys': [],
  //         'isJoin': true,
  //         'lastModified': new Date()
  //       });

  //       room.save(function( error, doc, numberAffected ){
  //         console.log( error, doc, numberAffected );

  //         if( error ){
  //           reject( error );
  //           return;
  //         }

  //         _this.Model.Day
  //           .findOneAndUpdate(
  //             {
  //               'dayID': query['dayID']
  //             },
  //             {
  //               '$push': {
  //                 'rooms': doc._id
  //               }
  //             },
  //             {
  //               'new': true,
  //               'upsert': true
  //             }
  //           )
  //           .exec(function( error, doc ){
  //             if( error ){
  //               reject( error );
  //               return;
  //             }

  //             resolve();
  //           });
  //       });
  //     });
  //   })(this);
  // };



  // --------------------------------------------------------------
  /**
   * Day Class -> getRooms
   * @param 
   * @return 
   *   
   * Rooms Document を返す 
   */
  // --------------------------------------------------------------
  Day.prototype.getRooms = function( _query ) {
    console.log('[Model] Day -> getRooms');

    var query = _.extend({
      'dayId': helpers.utils.getDayId()
    }, _query);

    return (function(_this) {
      return Q.Promise(function(resolve, reject, notify) {
        try {
          _this.Model.Day
            .findOne(
              {
                'dayId': query.dayId
              }
            )
            .populate({
              'path': 'rooms',
              'select': {},
              // 'match': {
              //   'roomId': query.dayId
              // },
              'options': {}
            })
            .exec(function(error, doc) {
              console.log( error, doc );

              if( error ){
                reject( error );
                return;
              }

              resolve( doc );
            });
        } catch (error) {
          
        }
      });
    })(this);

    // try {


    //   // if (typeof query[roomId] !== "undefined" && query[roomId] !== null) {

    //   // } else {
    //   //   throw new Error('[Model] Day -> getRooms | Not: Query Data');
    //   // }
    // } catch (error) {
    //    console.log(error);
    // }
  };



  /**
   * Day Class -> getRoom
   * @param {Object} data -
   *   _id: 取得するDay Collection のID を指定する
   *     何も指定されていなければサーバー内の時間を
   *     ベースに生成されたid　をクエリのキーにする
   *   rooms._id: 取得する Rooms Collection のID を指定する
   * @return {Object} Q promise を返す
   *   reject された場合はErrorオブジェクトが、
   *   resolve された場合はroomsの配列が返される
   *   
   * Day Document を返す 
   *
   */
  Day.prototype.getRoom = function( options ) {
    console.log('[Models] Day -> getRoom');

    var query = _.extend({
      'dayID': helpers.utils.getDayID(),
      'roomID': null
    }, options);

    return (function(_this) {
      return Q.Promise(function( resolve, reject, notify ) {
        _this.Model.Day
          .findOne(
            {
              'dayID': query['dayID']
            }
          )
          .populate({
            'path': 'rooms',
            'select': {},
            'match': {
              'roomID': query['roomID']
            },
            'options': {}
          })
          .select(
            {
              '_id': 0,
              'rooms': 1
            }
          )
          .exec(function( error, doc ){
            if( error ){
              reject( error );
              return;
            }

            resolve( doc );
          });
      });
    })(this);
  };








  // --------------------------------------------------------------
  /**
   * Day Class -> addDay
   * @param {Object} options - インスタンスの初期値を設定する
   * @prop {string} dayId -
   *   insert する Day Document のID を指定する 
   *   何も指定されていなければサーバー内の時間をベースに生成された dayId が指定される
   * @return {Object} Q promise を返す
   *
   * DaySchema で定義したスキーマのコレクションをデータベースに新たに生成する
   */
  // --------------------------------------------------------------
  Day.prototype.addDay = function( _query ) {
    console.log('[Models] Day -> addDay');

    var query = _.extend({
      'dayId': helpers.utils.getDayId()
    }, _query);

    query.createDate = new Date();
    
    return (function(_this) {
      return Q.Promise( function(resolve, reject, notify) {
        var day = new _this.Model.Day(query);

        day.save( function(error, doc, numberAffected) {
          // console.log(error, doc, numberAffected);
          if(error) {
            reject(error);
            return;
          }
            
          resolve();
        });
      });
    })(this);
  };


  // --------------------------------------------------------------
  /**
   * Day#addMemory
   * @param {Object} _query
   * @prop {string} dayId - 登録時のDayID
   * @prop {string} link - 登録時に閲覧していたサイトのURL
   * @prop {Object} window
   * @prop {number} window.width - 登録時のWindow幅
   * @prop {number} window.height - 登録時のWindow高さ
   * @prop {string} [ext] - 登録時閲覧していたサイトのスクリーンショットの拡張子
   * @prop {string} landscape - 登録時閲覧していたサイトのスクリーンショット（base64）
   * @prop {[Object]} positions - 軌跡の配列
   * @prop {number} positions[n].x - 軌跡のx座標
   * @prop {number} positions[n].y - 軌跡のy座標
   */
  // --------------------------------------------------------------
  Day.prototype.addMemory = function(_query) {
    console.log('[Models] Day -> addMemory');

    var query = _.extend({
      'dayId': helpers.utils.getDayId(),
      'link': null,
      'window': {
        'width': 0,
        'height': 0
      },
      'landscape': '',
      'ext': '',
      'positions': []
    }, _query);

    return (function(_this) {
      return Q.Promise(function(resolve, reject, notify) {
        if (!validator.isLength(query.landscape, 1)) {
          reject(new Error('[Model] Day -> addMemorys | Validation Error: query.landscape Not base64.'));
          return;
        }

        var result = {};
        var memory = new _this.Model.Memory(query);

        helpers.utils.parseDataUrl({
          'dataUrl': query.landscape
        })
        .then(
          function(data) {
            var ext = '.' + data.ext;
            memory.ext = ext;
            
            return helpers.utils.writeFile({
              'dirPath': config.MEMORYS_DIR_PATH + helpers.utils.getDayId() + '/',
              'fileName': validator.toString(memory._id) + ext,
              'blob': data.blob
            });
          }
        )
        .then(
          function() {
            memory.save( function(error, doc, numberAffected) {
              if(error) {
                reject(error);
                return;
              }

              result = doc;

              // ドキュメントの追加が成功したら 
              // クエリで指定されているdayId を持つDay Collection に 
              // 追加されたMemory の_id を追加する 
              _this.Model.Day
                .findOneAndUpdate({
                  'dayId': query.dayId
                }, {
                  '$push': {
                    'memorys': doc._id
                  }
                }, {
                  'new': true,
                  'upsert': true
                })
                .exec(function(error, doc) {
                  if (error) {
                    reject(error);
                    return;
                  }

                  resolve(result);
                });
            });
          }
        );
      });
    })(this);
  };

  // --------------------------------------------------------------
  /**
   * Day#getRandomMemory
   * @param {Object} _query -
   * @prop {Object} query.conditions - 取得条件
   * @prop {String} query.projection - 取得するフィールド
   * @prop {String} query.options - ソートやリミット、オフセットの指定
   * @return {Object} Q promise を返す
   *
   * Memory Document をランダムに取得する
   */
  // --------------------------------------------------------------
  Day.prototype.getRandomMemory = function(_query) {
    console.log('[Models] Day -> getRandomMemory');

    var query = _.extend({
      'conditions': {
        'random': {
          '$near': [Math.random(), 0]
        }
      },
      'projection': {},
      'options': {}
    }, _query);

    return (function(_this) {
      return Q.Promise(function(resolve, reject, notify) {
        _this.Model.Memory
          .find(
            query.conditions,
            query.projection,
            query.options
          )
          .select({
            '__v': 0
          })
          .exec(function(error, doc, numberAffected) {
            // console.log(error, doc, numberAffected);
            if (error) {
              reject(error);
              return;
            }
            resolve(doc);
          });
      });
    })(this);
  };


  return Day;
})();


module.exports = Day;














































