var Utils = (function() {
  var events = require('events');
  var moment = require('moment');
  var _ = require('lodash');

  function Utils() {
    // constructor
    console.log('[Helpers] -> Utils -> Constructor');
    this.eve = new events.EventEmitter();
  }

  // --------------------------------------------------------------
  /**
   * getDayId
   * @return {string} 生成したIDを返す
   *
   * 日付をベースにしたIDを生成する
   */
  // --------------------------------------------------------------
  Utils.prototype.getDayId = function() {
    console.log('[Helpers] -> Utils -> getDayId');

    var result = '';

    var id = moment().format("YYYYMMDD");
    result = id.toString();

    return result;
  };

  // // --------------------------------------------------------------
  // Utils.prototype.generateID = function() {
  //   console.log('[Helpers] -> Utils -> generateID');

  //   var src = '0123456789'.split( '' );
  //   var dst = _.sample( src, 6 );
  //   return dst.join( '' );
  // };

  // // --------------------------------------------------------------
  // Utils.prototype.getExpirationDate = function( period ) {
  //   console.log('[Helpers] -> Utils -> getExpirationDate');

  //   var date = new Date();
  //   date.setTime( date.getTime() - period );
  //   return date;
  // };

  // // --------------------------------------------------------------
  // Utils.prototype.parseDataURL = function(string) {
  //   console.log('[Helpers] -> Utils -> parseDataURL');
    
  //   if(/^data:.+\/(.+);base64,(.*)$/.test(string)) {
  //     return {
  //       ext: RegExp.$1,
  //       data: new Buffer(RegExp.$2, 'base64')
  //     };
  //   }
  //   return;
  // };

  return Utils;
})();

module.exports = new Utils();