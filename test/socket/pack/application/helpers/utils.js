var Utils = (function() {
  var config = require('config');
  var events = require('events');
  var moment = require('moment');
  var _ = require('lodash');
  var validator = require('validator');

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

  // --------------------------------------------------------------
  /**
   * getRoomId
   * @param {Object} _keyData -
   * @prop {Number} baseNumber - 
   *   生成するRoomIDのベースになる数値
   *   基本的にはRoom のドキュメント数の合計を指定する
   * @return {string} 生成したRoomIDを返す
   * @throws {Object} バリデーションに失敗するとエラーメッセージをスローする
   *
   * config.roomIdLength に指定された桁数になるように_keyData.baseNumber を補完する
   */
  // --------------------------------------------------------------
  Utils.prototype.getRoomId = function(_keyData) {
    console.log('[Helpers] -> Utils -> getRoomId');

    var keyData = _.extend({
      'baseNumber': ''
    }, _keyData);

    // 文字列型にキャスト
    keyData.baseNumber = keyData.baseNumber.toString();

    if (validator.isNumeric(keyData.baseNumber) && validator.isLength(keyData.baseNumber, 1)) {
      var result = '';
      var completion = '';
      var baseLen = keyData.baseNumber.length;

      if (baseLen == config.roomIdLength) {
        result = keyData.baseNumber;
        return result;
      } else {
        for (var i = baseLen; i < config.roomIdLength; i++) {
          completion += '0';
        }
        result = completion + baseLen;
        return result;
      }
    } else {
      throw new Error('[Helpers] Utils -> getRoomId | There is a problem with the value of the _keyData.');
    }
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