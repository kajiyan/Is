var Utils = (function() {
  var config = require('config');
  var fs = require('fs');
  var path = require('path');
  var events = require('events');
  var childProcess = require('child_process');
  var moment = require('moment');
  var Q = require('q');
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
    console.log('[Helpers] Utils -> getDayId');

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
    console.log('[Helpers] Utils -> getRoomId');

    var keyData = _.extend({
      'baseNumber': ''
    }, _keyData);

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
        result = completion + keyData.baseNumber;
        return result;
      }
    } else {
      throw new Error('[Helpers] Utils -> getRoomId | There is a problem with the value of the _keyData.');
    }
  };

  // --------------------------------------------------------------
  /**
   * utils#mkdir
   * @param {Object} _keyData - 書き出すディレクトリについて記述する
   * @prop {strinf} [basePath] - 書き出し先のディレクトリを設定する、初期値はpublic 以下
   * @prop {strinf} dirName - 書き出すディレクトリ名
   * @return {Object} Q promise
   */
  // --------------------------------------------------------------
  Utils.prototype.mkdir = function(_keyData) {
    console.log('[Helpers] Utils -> mkdir');
    try {
      var keyData = _.extend({
        'basePath': config.PUBLIC,
        'dirName': null
      }, _keyData);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          if (validator.isLength(keyData.baseNumber, 1)) {
            reject(new Error('[Helpers] Utils -> mkdir | Validation Error: Query Value.'));
            return;
          }

          fs.mkdir(path.join(keyData.basePath, keyData.dirName), function(error) {
            if(error){
              reject(error);
              return;
            }

            resolve();
          });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // --------------------------------------------------------------
  /**
   * utils#parseDataURL
   * 引数に渡された画像のDataURL から拡張子とバイナリデータを取り出す 
   * @param {Object} _keyData
   * @prop {string} dataUrl - 画像のDataURL
   * @return {Object} Q promise
   */
  // --------------------------------------------------------------
  Utils.prototype.parseDataUrl = function(_keyData) {
    console.log('[Helpers] Utils -> parseDataUrl');

    try {
      var keyData = _.extend({
        'dataUrl': null,
      }, _keyData);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          if (/^data:.+\/(.+);base64,(.*)$/.test(keyData.dataUrl)) {
            resolve({
              ext: RegExp.$1,
              blob: new Buffer(RegExp.$2, 'base64')
            });
          } else {
            reject(new Error('[Helpers] Utils -> mkdir | Validation Error: Query Value Type is not DataURL.'));
          }
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // --------------------------------------------------------------
  /**
   * utils#writeFile
   * バイナリデータをファイルに書き出す
   * @param {Object} _keyData
   * @prop {strinf} [basePath] - 書き出し先のディレクトリを設定する、初期値はpublic 以下
   * @prop {strinf} dirName - 書き出し先のディレクトリ名
   * @prop {strinf} fileName - 書き出すファイル名
   * @prop {buffer} blob - ファイルに書き出すバイナリデータ
   * @return {Object} Q promise
   */
  // --------------------------------------------------------------
  Utils.prototype.writeFile = function(_keyData) {
    console.log('[Helpers] Utils -> writeFile');

    try {
      var keyData = _.extend({
        'dirPath': config.PUBLIC,
        'fileName': null,
        'blob': null
      }, _keyData);

      return (function(_this) {
        return Q.Promise(function(resolve, reject, notify) {
          if (!validator.isLength(keyData.fileName, 1) && validator.isNull(keyData.blob)) {
            reject(new Error('[Helpers] Utils -> writeFile | Validation Error: Query Value.'));
            return;
          }

          fs.writeFile(path.join(keyData.dirPath, keyData.fileName), keyData.blob, function(error){
            if (error) {
              reject(error);
              return;
            }

            resolve();
          });
        });
      })(this);
    } catch(error) {
      console.log(error);
    }
  };

  // ImageFile.prototype.save = function(roomId, fileName, data) {
  //   console.log('ImageFile -> save');
  //   console.log(roomId, fileName, data);
  //   console.log(path.join(BASE_PATH, roomId.toString(), fileName));
  //   console.log("---------");

  //   fs.writeFile(path.join(BASE_PATH, roomId.toString(), fileName), data, function(err){
  //   });
  // };


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