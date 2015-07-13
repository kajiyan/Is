module.exports = function( options ){
  if (options == null) {
    options = {};
  };

  var defaults = {
    m: "DEBUG", // mode
    l: true     // is localhost
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

  setting.PRODUCTION_HOST = "54.65.140.79";
  setting.PRODUCTION_PORT = 10022;

  setting.DEBUG_HOST = "localhost";
  setting.DEBUG_PORT = 10022;

  setting.DEBUG_LOCAL_HOST = "localhost";
  setting.DEBUG_LOCAL_PORT = 10022;

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
      window.console = { log: noop };
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
    PAGE: {
      INDEX: {
        TITLE: "",
        META: {
          KEYWORDS: "KEYWORDS",
          DESCRIPTION: "DESCRIPTION",
        },
        OGP: {
          TITLE: "TITLE",
          TYPE: "website",
          DESCRIPTION: "DESCRIPTION",
          URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
          IMAGE: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png"
        },
        FACEBOOK: {
          TITLE: "TITLE",
          TYPE: "website",
          DESCRIPTION: "DESCRIPTION",
          URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
          IMAGE: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png"
        },
        TWITTER: {
          CARD: "summary_large_image",
          TITLE: "TITLE",
          DESCRIPTION: "DESCRIPTION",
          URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
          IMAGE: {
            SRC: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png",
            WIDTH: 900,
            HEIGHT: 400
          },
          HASH_TAGS: "",
          DOMAIN: setting.HOST
        }
      }
    },
    META: {
      VIEWPORT: "width=980"
    },
    MODE: {
      REFRESH_INTERVAL: 10
    },
    IMAGES: {
      MAX_NUMBER_OF_IMAGES: 25,
      STUBS: [
        {
          WIDTH: 480,
          HEIGHT: 640,
          DATA: ""
        },
        {
          WIDTH: 480,
          HEIGHT: 640,
          DATA: ""
        },
        {
          WIDTH: 640,
          HEIGHT: 480,
          DATA: ""
        }
      ]
    },
    VIEWER: {
      VIEW: {
        IMAGE: {
          BASE_SIZE_RATIO: 0.75,
          MAX_ROTATION: 15
        }
      }
    },
    CLIENT: {
      DEVICE_ORIENTATION: {
        THRESHOLD: 1.5 * 9.8
      }
    },
    RESIZE: {
      WIDTH: 640,
      HEIGHT: 640
    }
  };

  // if (typeof window !== "undefined" && window !== null && setting.IS_FRONT_END_SETTING) {
  //   var noop = function() {};

  //   if ( window.location.hostname.indexOf(setting.DEBUG_LOCAL_HOST) >= 0 ) {
  //     if (window.console == null) {
  //       window.console = {
  //         log: noop
  //       };
  //     }
  //   } else if ( window.location.hostname.indexOf(setting.DEBUG_HOST) >= 0 ){
  //     if (window.console == null) {
  //       window.console = {
  //         log: noop
  //       };
  //     }
  //   } else {
  //     window.console = {
  //       log: noop
  //     };
  //   }

  //   console.log( "Front End Setting! | /system/core/config/setting.js" );
  // }else{
  //   console.log( "Gulp Setting! | /system/core/config/setting.js" );
  //   console.log( "MODE: " + defaults.m.toUpperCase() + "| IS_LOCALHOST: " + defaults.l );
  //   console.log( "HOST: " + setting.HOST + "| PORT: " + setting.PORT );
  // }

  return setting;
};

// module.exports = function( options ){
//   if (options == null) {
//     options = {};
//   };

//   var defaults = {
//     m: "DEBUG", // mode
//     l: true     // is localhost
//   };

//   for (var key in options) {
//     if ( options.hasOwnProperty( key ) ) {
//       defaults[key] = options[key];
//     }
//   }

//   defaults.l = (defaults.l == "false") ? false : defaults.l;

//   var setting = {};

//   setting.MODE = defaults.m.toUpperCase(); // string
//   setting.IS_LOCALHOST = defaults.l;       // bool

//   setting.IS_FRONT_END_SETTING = true;     // bool

//   setting.TARGET = {
//     index: ""
//   };

//   setting.PRODUCTION_HOST = "";
//   setting.PRODUCTION_PORT = 80;

//   setting.DEBUG_HOST = "";
//   setting.DEBUG_PORT = 80;

//   setting.DEBUG_LOCAL_HOST = "localhost";
//   setting.DEBUG_LOCAL_PORT = 10022;

//   setting.SYSTEM      = "system";
//   setting.SYSTEM_CORE = "core";
//   setting.APPLICATION = "application";

//   setting.CORE = "../" + setting.SYSTEM_CORE + "/";
//   setting.DIST = "../../" + setting.APPLICATION  + "/public/";
  
//   setting.COMMON  = "common";
//   setting.IMAGES  = "images";
//   setting.CSS     = "css";
//   setting.JS      = "js";
//   setting.FONT    = "fonts";
//   setting.AUDIO   = "audio";
//   setting.VIDEO   = "video";

//   setting.BUILDER          = "gulp";
//   setting.ENGINE           = "swig";
//   setting.ENGINE_ATTRIBUTE = "swig";
//   setting.STYLE            = "sass";
//   setting.ALT_JS           = "coffee";


//   if (setting.MODE === "PRODUCTION") {
//     /*
//      * 本番用サーバーの設定
//      */
//     setting.PROTOCOL = "http";
//     setting.HOST = setting.PRODUCTION_HOST;
//     setting.PORT = setting.PRODUCTION_PORT;
//     setting.BASE_URL = "//" + setting.PRODUCTION_HOST + "/";
//     setting.BASE_PATH = "";
//     setting.BASE_VIDEO_URL = "";
//     setting.BASE_SOUND_URL = "";
//     setting.BASE_IMG_URL = "";
//   } else {
//     if (!setting.IS_LOCALHOST) {
//       /*
//        * 開発用サーバーの設定
//        */
//       setting.PROTOCOL = "http";
//       setting.HOST = setting.DEBUG_HOST;
//       setting.PORT = setting.DEBUG_PORT;
//       setting.BASE_URL = "//" + setting.DEBUG_HOST + "/-/hiranomami/";
//       setting.BASE_PATH = "";
//       setting.BASE_VIDEO_URL = "";
//       setting.BASE_SOUND_URL = "";
//       setting.BASE_IMG_URL = "";
//     } else {
//       /*
//        * ローカルサーバーの設定
//        */
//       setting.PROTOCOL = "http";
//       setting.HOST = setting.DEBUG_LOCAL_HOST;
//       setting.PORT = setting.DEBUG_LOCAL_PORT;
//       setting.BASE_URL = "//" + setting.DEBUG_LOCAL_HOST + ":" + setting.DEBUG_LOCAL_PORT + "/";
//       setting.BASE_PATH = "";
//       setting.BASE_VIDEO_URL = "";
//       setting.BASE_SOUND_URL = "";
//       setting.BASE_IMG_URL = "";
//     }
//   }

//   setting.PATH = {
//     COMMON: setting.BASE_URL + setting.COMMON + "/",
//     COMMON_IMAGES: setting.BASE_URL + setting.COMMON + "/" + setting.IMAGES + "/",
//     COMMON_CSS: setting.BASE_URL + setting.COMMON + "/" + setting.CSS + "/",
//     COMMON_JS: setting.BASE_URL + setting.COMMON + "/" + setting.JS + "/",
//     COMMON_FONT: setting.BASE_URL + setting.COMMON + "/" + setting.FONT + "/",
//     COMMON_AUDIO: setting.BASE_URL + setting.COMMON + "/" + setting.AUDIO + "/",
//     COMMON_VIDEO: setting.BASE_URL + setting.COMMON + "/" + setting.VIDEO + "/",
//     ABSOLUTE: setting.BASE_URL + setting.BASE_PATH,
//     ABSOLUTE_IMAGES: setting.BASE_URL + setting.BASE_PATH + setting.IMAGES + "/",
//     ABSOLUTE_CSS: setting.BASE_URL + setting.BASE_PATH + setting.CSS + "/",
//     ABSOLUTE_JS: setting.BASE_URL + setting.BASE_PATH + setting.JS + "/",
//     ABSOLUTE_FONT: setting.BASE_URL + setting.BASE_PATH + setting.FONT + "/",
//     ABSOLUTE_AUDIO: setting.BASE_URL + setting.BASE_PATH + setting.AUDIO + "/",
//     ABSOLUTE_VIDEO: setting.BASE_URL + setting.BASE_PATH + setting.VIDEO + "/"
//   };

//   if (!(typeof window !== "undefined" && window !== null)) {
//     // フロントからの呼び出しでなければコマンドライン用のモジュールを読み込む
//     var path = require("path");

//     var common = path.join(__dirname, "../../../../") + setting.COMMON + "/";

//     setting.PATH.COMMON_FILE     = common;
//     setting.PATH.COMMON_ENGINE   = common + setting.ENGINE + "/";
//     setting.PATH.COMMON_SASS     = common + setting.STYLE + "/";
//     setting.PATH.COMMON_ALT_JS   = common + setting.ALT_JS + "/";
//   }

//   setting.CONFIG = {
//     COMMON: {
//       BASE_WIDTH      : 1000,
//       BASE_HEIGHT     : 600,
//       BASE_MAX_WIDTH  : 1600,
//       BASE_MAX_HEIGHT : 900,
//       BASE_MIN_WIDTH  : 1000,
//       BASE_MIN_HEIGHT : 600
//     },
//     PAGE: {
//       INDEX: {
//         TITLE: "",
//         META: {
//           KEYWORDS: "KEYWORDS",
//           DESCRIPTION: "DESCRIPTION",
//         },
//         OGP: {
//           TITLE: "TITLE",
//           TYPE: "website",
//           DESCRIPTION: "DESCRIPTION",
//           URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
//           IMAGE: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png"
//         },
//         FACEBOOK: {
//           TITLE: "TITLE",
//           TYPE: "website",
//           DESCRIPTION: "DESCRIPTION",
//           URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
//           IMAGE: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png"
//         },
//         TWITTER: {
//           CARD: "summary_large_image",
//           TITLE: "TITLE",
//           DESCRIPTION: "DESCRIPTION",
//           URL: setting.PROTOCOL + ":" + setting.BASE_URL + setting.BASE_PATH,
//           IMAGE: {
//             SRC: setting.PROTOCOL + ":" + setting.PATH.COMMON_IMAGES + "ogp/index-0.png",
//             WIDTH: 900,
//             HEIGHT: 400
//           },
//           HASH_TAGS: "",
//           DOMAIN: setting.HOST
//         }
//       }
//     },
//     META: {
//       VIEWPORT: "width=980"
//     },
//     MODE: {
//       REFRESH_INTERVAL: 10
//     },
//     IMAGES: {
//       MAX_NUMBER_OF_IMAGES: 25,
//       STUBS: [
//         {
//           WIDTH: 480,
//           HEIGHT: 640,
//           DATA: ""
//         },
//         {
//           WIDTH: 480,
//           HEIGHT: 640,
//           DATA: ""
//         },
//         {
//           WIDTH: 640,
//           HEIGHT: 480,
//           DATA: ""
//         }
//       ]
//     },
//     VIEWER: {
//       VIEW: {
//         IMAGE: {
//           BASE_SIZE_RATIO: 0.75,
//           MAX_ROTATION: 15
//         }
//       }
//     },
//     CLIENT: {
//       DEVICE_ORIENTATION: {
//         THRESHOLD: 1.5 * 9.8
//       }
//     }
//   };

//   if (typeof window !== "undefined" && window !== null && setting.IS_FRONT_END_SETTING) {
//     var noop = function() {};

//     if ( window.location.hostname.indexOf(setting.DEBUG_LOCAL_HOST) >= 0 ) {
//       if (window.console == null) {
//         window.console = {
//           log: noop
//         };
//       }
//     } else if ( window.location.hostname.indexOf(setting.DEBUG_HOST) >= 0 ){
//       if (window.console == null) {
//         window.console = {
//           log: noop
//         };
//       }
//     } else {
//       window.console = {
//         log: noop
//       };
//     }

//     console.log( "Front End Setting! | /system/core/config/setting.js" );
//   }else{
//     console.log( "Gulp Setting! | /system/core/config/setting.js" );
//     console.log( "MODE: " + defaults.m.toUpperCase() + "| IS_LOCALHOST: " + defaults.l );
//     console.log( "HOST: " + setting.HOST + "| PORT: " + setting.PORT );
//   }

//   return setting;
// };