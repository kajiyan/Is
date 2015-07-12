var util = require('util');
var config = require('config');
var Q = require('q');
var cron = require('cron');
var mongoose = require('mongoose');
var models = require(config.models);
var helpers = {
  utils: require(config.helpers + 'utils')
};

// cron
var cronJob;
try {
  var CronJob = cron.CronJob;
  cronJob = new CronJob({
    cronTime: "00 00 00 * * *",
    onTick: function() {
      console.log('cron');
    },
    start: false,
    timeZone: 'Asia/Tokyo'
  });
} catch( error ) {
  console.log('cron pattern not valid');
}

cronJob.start();

var dayModel = models.getModel('day');
dayModel.addMemory(
  {
    'dayID': helpers.utils.getDayID(),
    'roomID': '000000',
    'room': '55a15e4e987f154299a4a11f'
  }
);

// ルームがあるかないか判断
// なければルームをせいせい
// getRoomで返ってきた値が0もしくはisJoinがfalseだったら
// あらたにルームを作成する
// RoomIDを指定され満室だった場合エラーメッセージを返す

// dayModel.addDay();

/* test Add Room */
// dayModel.addRoom(
//   {
//     'dayID': helpers.utils.getDayID(),
//     'roomID': '000006'2
//   }
// ).then(
//   function( data ){
//     console.log(data);
//   }
// );
/* End. test Add Room */

/* test Get Room */
// dayModel.getRoom(
//   {
//     'dayID': helpers.utils.getDayID(),
//     'roomID': '000005'
//   }
// )
// .then(
//   function( data ){
//     console.log(data);
//   }
// );
/* End. Test Get Room */









// dayModel.addRoom()
//   .then(
//     function( data ){
//       // console.log(data);
//     }
//   );

// dayModel.getRoom()
//   .then(
//     function( data ){
//       console.log(data);
//     }
//   );

/* test0 */
// var testQ = function( delay ) {
//     var d = Q.defer();
//     setTimeout(function(){
//         d.resolve(delay);
//     }, delay);
//     return d.promise;
// };

// Q.when()
//   .then(
//     function( data ){
//       return Q.all([
//         testQ(3000),
//         testQ(10000)
//       ]);
//     }
//   )
//   .then(
//     function( data ){
//       console.log(data); // [ 3000, 10000 ]
//       console.log('complete');
//     }
//   );
/* End.test0 */


// var stepA = function(val) {
//     var d = Q.defer();
//     setTimeout(function(){
//         console.log(val);
//         d.reject('fuga');
//     }, 3000);
//     return d.promise;
// };





// var dayModel = models.getModel('day');
// // dayModel.create();
// Q.all([
//   dayModel.getDay(),
//   stepA()
// ]).then(
//   function( data ){
//     // console.log(util.inspect(data, { showHidden: true, depth: null }));
//     console.log( 'lesolve' );
//   },
//   function( data ){
//     // console.log(util.inspect(data, { showHidden: true, depth: null }));
//     console.log( 'reject' );
//   }
// ).then(
//   function( ){
//     console.log( 'complete' );
//   }
// );







// var stepA = function(val) {
//     var d = Q.defer();
//     setTimeout(function(){
//         console.log(val);
//         d.resolve('fuga');
//     }, 3000);
//     return d.promise
// };

// Q.when(
//   stepA('test'),
//   roomModel.create()
// ).done(function(val){
//     console.log(val);
// });


// console.log(models.getModel('rooms'));

// // MongoDBへ接続
// mongoose.connect('mongodb://localhost/is');

// // Memory スキーマの定義
// var MemorySchema = new mongoose.Schema(
//   {
//     roomId: String,
//     fileName: String,
//     link: String,
//     window: {
//       width: Number,
//       height: Number
//     },
//     image: {
//       name: String,
//       width: Number,
//       height: Number
//     },
//     position: [
//       {
//         x: Number,
//         y: Number
//       }
//     ],
//     date: { type: Date, default: new Date() }
//   },
//   {
//     toJSON: {
//       virtuals: true
//     }
//   }
// );

// // 個別のURL
// MemorySchema
//   .virtual( 'url' )
//   .get( function() {
//     var result = '';
//     var port = '';
    
//     if(config['port'] != null){
//       port = ':' + config['port'];
//     }

//     result = '//' + config.host + port + '/memory/' + this.roomId + '/' + this.id;

//     return result;
//   });


// // Room スキーマの定義
// var RoomSchema = new mongoose.Schema(
//   {
//     _id: String,
//     memorys: [ MemorySchema ],
//     numOfMemorys: { type: Number, default: 0 },
//     lastModified: { type: Date, default: new Date() }
//   },
//   {
//     _id: false,
//     toJSON: {
//       virtuals: true
//     }
//   }
// );

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

// var Room = mongoose.model( 'Room', RoomSchema );


