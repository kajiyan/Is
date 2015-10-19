module.exports = function( options ){
  if (options == null) {
    options = {};
  };

  // var defaults = {
  //   m: "DEBUG", // mode
  //   l: true     // is localhost
  // };

  var defaults = {
    m: "PRODUCTION",
    l: false
  };

  for (var key in options) {
    if ( options.hasOwnProperty( key ) ) {
      defaults[key] = options[key];
    }
  }

  defaults.l = (defaults.l == "false") ? false : defaults.l;

  var setting = {};

  setting.MODE = defaults.m.toUpperCase(); // string
  setting.IS_LOCALHOST = defaults.l;       // bool

  setting.IS_FRONT_END_SETTING = true;     // bool

  setting.TARGET = {
    index: ""
  };

  setting.PRODUCTION_HOST = "160.16.230.26";
  setting.PRODUCTION_PORT = 8001;

  setting.DEBUG_HOST = "localhost";
  setting.DEBUG_PORT = 8001;

  setting.DEBUG_LOCAL_HOST = "localhost";
  setting.DEBUG_LOCAL_PORT = 8001;

  setting.SYSTEM      = "system";
  setting.SYSTEM_CORE = "core";
  setting.APPLICATION = "application";

  setting.CORE = "../" + setting.SYSTEM_CORE + "/";
  setting.DIST = "../../" + setting.APPLICATION  + "/public/";
  
  setting.COMMON  = "common";
  setting.IMAGES  = "images";
  setting.CSS     = "css";
  setting.JS      = "js";
  setting.FONT    = "fonts";
  setting.AUDIO   = "audio";
  setting.VIDEO   = "video";

  setting.BUILDER          = "gulp";
  setting.ENGINE           = "swig";
  setting.ENGINE_ATTRIBUTE = "swig";
  setting.STYLE            = "sass";
  setting.ALT_JS           = "coffee";


  if (setting.MODE === "PRODUCTION") {
    /*
     * 本番用サーバーの設定
     */
    setting.PROTOCOL = "http";
    setting.HOST = setting.PRODUCTION_HOST;
    setting.PORT = setting.PRODUCTION_PORT;
    setting.BASE_URL = "//" + setting.PRODUCTION_HOST + "/";
    setting.BASE_PATH = "";
    setting.BASE_VIDEO_URL = "";
    setting.BASE_SOUND_URL = "";
    setting.BASE_IMG_URL = "";
  } else {
    if (!setting.IS_LOCALHOST) {
      /*
       * 開発用サーバーの設定
       */
      setting.PROTOCOL = "http";
      setting.HOST = setting.DEBUG_HOST;
      setting.PORT = setting.DEBUG_PORT;
      setting.BASE_URL = "//" + setting.DEBUG_HOST + "/-/hiranomami/";
      setting.BASE_PATH = "";
      setting.BASE_VIDEO_URL = "";
      setting.BASE_SOUND_URL = "";
      setting.BASE_IMG_URL = "";
    } else {
      /*
       * ローカルサーバーの設定
       */
      setting.PROTOCOL = "http";
      setting.HOST = setting.DEBUG_LOCAL_HOST;
      setting.PORT = setting.DEBUG_LOCAL_PORT;
      setting.BASE_URL = "//" + setting.DEBUG_LOCAL_HOST + ":" + setting.DEBUG_LOCAL_PORT + "/";
      setting.BASE_PATH = "";
      setting.BASE_VIDEO_URL = "";
      setting.BASE_SOUND_URL = "";
      setting.BASE_IMG_URL = "";
    }
  }



  if (typeof window !== "undefined" && window !== null && setting.IS_FRONT_END_SETTING) {
    var noop = function() {};

    if (setting.MODE === "DEBUG") {
      if (window.console == null) {
        window.console = { log: noop };
      }
    } else if (setting.MODE === "PRODUCTION") {
      // window.console = { log: noop };
    }

    if ( window.location.hostname.indexOf(setting.PRODUCTION_HOST) >= 0 ) {
      setting.PROTOCOL = "http";
      setting.HOST = setting.PRODUCTION_HOST;
      setting.PORT = setting.PRODUCTION_PORT;
      setting.BASE_URL = "//" + setting.PRODUCTION_HOST + "/";
      setting.BASE_PATH = "top/";
      setting.BASE_VIDEO_URL = "";
      setting.BASE_SOUND_URL = "";
      setting.BASE_IMG_URL = "";
    } else if ( window.location.hostname.indexOf(setting.DEBUG_HOST) >= 0 ){
      setting.PROTOCOL = "http";
      setting.HOST = setting.DEBUG_HOST;
      setting.PORT = setting.DEBUG_PORT;
      setting.BASE_URL = "//" + setting.DEBUG_HOST + "/renewal/";
      setting.BASE_PATH = "";
      setting.BASE_VIDEO_URL = "";
      setting.BASE_SOUND_URL = "";
      setting.BASE_IMG_URL = "";
    } else if ( window.location.hostname.indexOf(setting.DEBUG_LOCAL_HOST) >= 0 ) {
      setting.PROTOCOL = "http";
      setting.HOST = setting.DEBUG_LOCAL_HOST;
      setting.PORT = setting.DEBUG_LOCAL_PORT;
      setting.BASE_URL = "//" + setting.DEBUG_LOCAL_HOST + ":" + setting.DEBUG_LOCAL_PORT + "/";
      setting.BASE_PATH = "";
      setting.BASE_VIDEO_URL = "";
      setting.BASE_SOUND_URL = "";
      setting.BASE_IMG_URL = "";
    }

    console.log( "Front End Setting | /system/core/config/setting.js" );
  } else {
    console.log( "MODE: " + defaults.m.toUpperCase() + "| IS_LOCALHOST: " + defaults.l );
    console.log( "HOST: " + setting.HOST + "| PORT: " + setting.PORT );
  }



  setting.PATH = {
    COMMON: setting.BASE_URL + setting.COMMON + "/",
    COMMON_IMAGES: setting.BASE_URL + setting.COMMON + "/" + setting.IMAGES + "/",
    COMMON_CSS: setting.BASE_URL + setting.COMMON + "/" + setting.CSS + "/",
    COMMON_JS: setting.BASE_URL + setting.COMMON + "/" + setting.JS + "/",
    COMMON_FONT: setting.BASE_URL + setting.COMMON + "/" + setting.FONT + "/",
    COMMON_AUDIO: setting.BASE_URL + setting.COMMON + "/" + setting.AUDIO + "/",
    COMMON_VIDEO: setting.BASE_URL + setting.COMMON + "/" + setting.VIDEO + "/",
    ABSOLUTE: setting.BASE_URL + setting.BASE_PATH,
    ABSOLUTE_IMAGES: setting.BASE_URL + setting.BASE_PATH + setting.IMAGES + "/",
    ABSOLUTE_CSS: setting.BASE_URL + setting.BASE_PATH + setting.CSS + "/",
    ABSOLUTE_JS: setting.BASE_URL + setting.BASE_PATH + setting.JS + "/",
    ABSOLUTE_FONT: setting.BASE_URL + setting.BASE_PATH + setting.FONT + "/",
    ABSOLUTE_AUDIO: setting.BASE_URL + setting.BASE_PATH + setting.AUDIO + "/",
    ABSOLUTE_VIDEO: setting.BASE_URL + setting.BASE_PATH + setting.VIDEO + "/"
  };

  if (!(typeof window !== "undefined" && window !== null)) {
    // フロントからの呼び出しでなければコマンドライン用のモジュールを読み込む
    var path = require("path");

    var common = path.join(__dirname, "../../../../") + setting.COMMON + "/";

    setting.PATH.COMMON_FILE     = common;
    setting.PATH.COMMON_ENGINE   = common + setting.ENGINE + "/";
    setting.PATH.COMMON_SASS     = common + setting.STYLE + "/";
    setting.PATH.COMMON_ALT_JS   = common + setting.ALT_JS + "/";
  }

  setting.CONFIG = {
    COMMON: {
      BASE_WIDTH      : 1000,
      BASE_HEIGHT     : 600,
      BASE_MAX_WIDTH  : 1600,
      BASE_MAX_HEIGHT : 900,
      BASE_MIN_WIDTH  : 1000,
      BASE_MIN_HEIGHT : 600
    },
    FRAME_RATE: 24,
    REC_INTERVAL: 1000 * 60 * 1,
    MEMORY_GET_INTERVAL: 1000 * 30,
    MEMORY: {
      _id: '55e5c4b75ae10c89bf74c8fd',
      dayId: '20150902',
      link: 'http://www.aozora.gr.jp/cards/001695/files/55131_49647.html',
      ext: '.jpeg',
      createAt: '2015-07-26T14:18:07.492Z',
      random: [ 0.6454489470925182, 0 ],
      positions: [
        { x: 685, y: 151 },
        { x: 684, y: 151 },
        { x: 683, y: 151 },
        { x: 682, y: 151 },
        { x: 681, y: 151 },
        { x: 680, y: 151 },
        { x: 679, y: 151 },
        { x: 678, y: 151 },
        { x: 677, y: 151 },
        { x: 676, y: 151 },
        { x: 675, y: 151 },
        { x: 674, y: 151 },
        { x: 673, y: 151 },
        { x: 672, y: 151 },
        { x: 671, y: 151 },
        { x: 670, y: 151 },
        { x: 669, y: 151 },
        { x: 668, y: 151 },
        { x: 667, y: 151 },
        { x: 666, y: 151 },
        { x: 665, y: 151 },
        { x: 664, y: 151 },
        { x: 663, y: 151 },
        { x: 662, y: 151 },
        { x: 661, y: 151 },
        { x: 660, y: 151 },
        { x: 659, y: 151 },
        { x: 658, y: 151 },
        { x: 657, y: 151 },
        { x: 656, y: 151 },
        { x: 655, y: 151 },
        { x: 654, y: 151 },
        { x: 653, y: 151 },
        { x: 652, y: 151 },
        { x: 651, y: 151 },
        { x: 650, y: 151 },
        { x: 649, y: 151 },
        { x: 648, y: 151 },
        { x: 647, y: 151 },
        { x: 646, y: 151 },
        { x: 645, y: 151 },
        { x: 644, y: 151 },
        { x: 643, y: 151 },
        { x: 642, y: 151 },
        { x: 641, y: 151 },
        { x: 640, y: 151 },
        { x: 639, y: 151 },
        { x: 638, y: 151 }
      ],
      window: { width: 1255, height: 425 },
      landscape: 'http://localhost:8001/memorys/20150902/55e5c4b75ae10c89bf74c8fd.jpeg',
      url: '//localhost:8001/memorys/20150902/55e5c4b75ae10c89bf74c8fd',
      id: '55e5c4b75ae10c89bf74c8fd'
    },
    MEMORY1: {
      _id: '55e5c4b75ae10c89bf74c8fe',
      dayId: '20150902',
      link: 'http://www.aozora.gr.jp/cards/001695/files/55131_49647.html',
      ext: '.jpeg',
      createAt: '2015-07-26T14:18:07.492Z',
      random: [ 0.6454489470925182, 0 ],
      positions: [
        { x: 685, y: 151 },
        { x: 684, y: 152 },
        { x: 683, y: 153 },
        { x: 682, y: 154 },
        { x: 681, y: 155 },
        { x: 680, y: 156 },
        { x: 679, y: 157 },
        { x: 678, y: 158 },
        { x: 677, y: 159 },
        { x: 676, y: 160 },
        { x: 675, y: 161 },
        { x: 674, y: 162 },
        { x: 673, y: 163 },
        { x: 672, y: 164 },
        { x: 671, y: 165 },
        { x: 670, y: 166 },
        { x: 669, y: 167 },
        { x: 668, y: 168 },
        { x: 667, y: 169 },
        { x: 666, y: 170 },
        { x: 665, y: 171 },
        { x: 664, y: 172 },
        { x: 663, y: 173 },
        { x: 662, y: 174 },
        { x: 661, y: 175 },
        { x: 660, y: 176 },
        { x: 659, y: 177 },
        { x: 658, y: 178 },
        { x: 657, y: 179 },
        { x: 656, y: 180 },
        { x: 655, y: 181 },
        { x: 654, y: 182 },
        { x: 653, y: 183 },
        { x: 652, y: 184 },
        { x: 651, y: 185 },
        { x: 650, y: 186 },
        { x: 649, y: 187 },
        { x: 648, y: 188 },
        { x: 647, y: 189 },
        { x: 646, y: 190 },
        { x: 645, y: 191 },
        { x: 644, y: 192 },
        { x: 643, y: 193 },
        { x: 642, y: 194 },
        { x: 641, y: 195 },
        { x: 640, y: 196 },
        { x: 639, y: 197 },
        { x: 638, y: 198 }
      ],
      window: { width: 1255, height: 425 },
      landscape: 'http://localhost:8001/memorys/20150902/55e5c4b75ae10c89bf74c8fd.jpeg',
      url: '//localhost:8001/memorys/20150902/55e5c4b75ae10c89bf74c8fd',
      id: '55e5c4b75ae10c89bf74c8fe'
    }
  };

  return setting;
};