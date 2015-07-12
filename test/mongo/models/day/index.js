// ============================================================
// Day
var DayInstance;
var Day;


// --------------------------------------------------------------
/**
 * Rooms Class
 * constructor
 * setup
 */
// --------------------------------------------------------------


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
   * @param {Object} options - インスタンスの初期値を設定する
   * @return {Object} 引数で指定したmodelNameのモデルクラスのインスタンスを返す
   */
  // --------------------------------------------------------------
  function Day( data ){
    console.log('[Models] Day -> constructor');
    
    if (data == null) {
      data = {};
    }

    this.defaults = {
      mongoose: require('mongoose')
    };

    this.options = this.defaults;

    // インスタンスにオプションが渡されていれば初期値を上書きする
    for ( var key in data ) {
      if ( this.options.hasOwnProperty( key ) ) {
        this.options[key] = data[key];
      } else {
        this.options[key] = data[key];
      }
    }

    // 初期値を削除
    delete this.defaults;
  }



  // --------------------------------------------------------------
  Day.prototype.setup = function() {
    console.log('[Models] Day -> setup');

    var mongoose = this.options.mongoose;

    // Memory スキーマの定義
    var MemorySchema = new mongoose.Schema(
      {
        dayID: {
          type: String,
          required: true
        },
        roomID: {
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
        position: [
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
        
        if(config['port'] != null){
          port = ':' + config['port'];
        }

        result = '//' + config.host + port + '/memory/' + this.dayID + '/' + this.roomID + '/' + this.id;

        return result;
      });





    // Room スキーマの定義
    var RoomSchema = new mongoose.Schema(
      {
        roomID: {
          type: String,
          required: true,
          index: {
            unique: true
          }
        },
        memorys: [{
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Memory'
        }],
        // numOfMemorys: { type: Number, default: 0 },
        lastModified: { type: Date, default: new Date() },
        isJoin: Boolean
      },
      {
        // _id: false,
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
      dayID: {
        type: String,
        required: true,
        index: {
          unique: true
        }
      },
      rooms: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room'
      }],
      createDate: { type: Date, default: new Date() }
    });

    // // Day の有効期限
    // DaySchema
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





  /**
   * Day Class -> getDay
   * @param {Object} data -
   *   id: 取得するDay Collection のID を指定する
   *       何も指定されていなければサーバー内の時間を
   *       ベースに生成されたid　をクエリのキーにする
   * @return {Object} Q promise を返す
   *
   * Day Document を返す 
   *
   */
  Day.prototype.getDay = function( data ) {
    console.log('[Models] Day -> getDay');
    
    var options = _.extend({
      id: helpers.utils.getDayID()
    }, data);

    var defer = Q.defer();

    this.Model.Day
      .findById( options.id )
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








  
  /**
   * Day Class -> addDay
   * @param {Object} options - インスタンスの初期値を設定する
   * @return {Object} Q promise を返す
   *
   * setupで定義したスキーマのコレクションをデータベースに新たに生成する
   *
   */
  Day.prototype.addDay = function( options ) {
    console.log('[Models] Day -> addDay');

    var query = _.extend({
      'dayID': helpers.utils.getDayID(),
      'createDate': new Date()
    }, options);

    return (function(_this) {
      return Q.Promise(function( resolve, reject, notify ) {
        var day = new _this.Model.Day( query );

        day.save(function( error, doc, numberAffected ){
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