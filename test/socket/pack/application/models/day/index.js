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
        roomId: {
          type: String,
          required: true
        },
        link: String,
        window: {
          width: Number,
          height: Number
        },
        image: {
          fileName: String,
          width: Number,
          height: Number
        },
        positions: [
          {
            x: Number,
            y: Number
          }
        ],
        room: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Room',
          required: true
        },
        createDate: { type: Date, default: new Date() }
      },
      {
        toJSON: {
          virtuals: true
        }
      }
    );
    
    MemorySchema
      .virtual( 'url' )
      .get( function() {
        var result = '';
        var port = '';
         
        if(config['port'] !== null){
          port = ':' + config['port'];
        }

        result = '//' + config.host + port + '/memory/' + this.dayID + '/' + this.roomID + '/' + this.id;

        return result;
      });


    // Room Schema の定義
    var RoomSchema = new mongoose.Schema(
      {
        roomId: {
          type: String,
          required: true,
          index: {
            unique: true,
            sparse: true
          }
        },
        memorys: [{
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Memory'
        }],
        lastModified: { type: Date, default: new Date() },
        isJoin: Boolean
      },
      {
        toJSON: {
          virtuals: true
        }
      }
    );
    
    // // Roomの有効期限
    // RoomSchema
    //   .virtual( 'expired' )
    //   .get(
    //     /**    
    //      * @return {boolean} Roomが有効化の真偽値を返す
    //      */
    //     function() {
    //       var result = '';
    //       result = this.lastModified < helpers.utils.getExpirationDate( config.AVAILABLE_PERIOD );
    //       return result;
    //     }
    //   );


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
      rooms: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room'
      }],
      createDate: { type: Date, default: new Date() }
    });

    // // // Day の有効期限
    // // DaySchema
    // //   .virtual( 'expired' )
    // //   .get(
    // //     /**    
    // //      * @return {boolean} Roomが有効化の真偽値を返す
    // //      */
    // //     function() {
    // //       var result = '';
    // //       result = this.lastModified < helpers.utils.getExpirationDate( config.AVAILABLE_PERIOD );
    // //       return result;
    // //     }
    // //   );

    this.Model = {
      Memory: mongoose.model( 'Memory', MemorySchema ),
      Room: mongoose.model( 'Room', RoomSchema ),
      Day: mongoose.model( 'Day', DaySchema )
    };
  };





  // --------------------------------------------------------------
  // Day.prototype.test = function() {
    // console.log('[Models] Day -> test');
  // };




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

    // this.Model.Day

    return defer.promise;
  };





  // Day.prototype.test = function() {
  //   console.log('[Models] Day -> test');
  // };
  
  /**
   * ルームがない場合のみに実行される（getRoomと組み合わせて使う）
   */
  Day.prototype.addRoom = function( data ) {
    console.log('[Models] Day -> addRoom');

    var query = _.extend({
      'dayID': helpers.utils.getDayID(),
      'roomID': null
    }, data);

    return (function(_this) {
      return Q.Promise(function( resolve, reject, notify ) {
        var room = new _this.Model.Room({
          'roomID': query['roomID'],
          'memorys': [],
          'isJoin': true,
          'lastModified': new Date()
        });

        room.save(function( error, doc, numberAffected ){
          console.log( error, doc, numberAffected );

          if( error ){
            reject( error );
            return;
          }

          _this.Model.Day
            .findOneAndUpdate(
              {
                'dayID': query['dayID']
              },
              {
                '$push': {
                  'rooms': doc._id
                }
              },
              {
                'new': true,
                'upsert': true
              }
            )
            .exec(function( error, doc ){
              if( error ){
                reject( error );
                return;
              }

              resolve();
            });
        });
      });
    })(this);
  };



  /****/
  Day.prototype.addMemory = function( options ) {
    console.log('[Models] Day -> addMemory');

    var query = _.extend({
      'dayID': helpers.utils.getDayID(),
      'roomID': '',
      'link': '',
      'window': {},
      'image': {
        'filename': '',
        'width': 0,
        'height': 0
      },
      'positions': [],
      'createDate': new Date()
    }, options);

    return (function( _this ) {
      return Q.Promise(function( resolve, reject, notify ) {
        

      });
    })(this);
  };




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
    console.log('[Models] Day -> getRooms');

    var query = _.extend({
      'dayId': helpers.utils.getDayID()
    }, _query);

    try {


      // if (typeof query[roomId] !== "undefined" && query[roomId] !== null) {

      // } else {
      //   throw new Error('[Model] Day -> getRooms | Not: Query Data');
      // }
    } catch (error) {
       console.log(error);
    }
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

    console.log(query);

    return (function(_this) {
      return Q.Promise( function(resolve, reject, notify) {
        var day = new _this.Model.Day( query );

        day.save( function(error, doc, numberAffected) {
          console.log(error, doc, numberAffected);

          if( error ){
            reject( error );
            return;
          }

          resolve();
        });
      });
    })(this);
  };



  return Day;
})();


module.exports = Day;