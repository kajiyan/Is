# ============================================================
# Connect
# 
# EVENT
#   - connectChangeIsRun
#   - connectChangeUsers
#   - connectCheckOut
#   - connectJointed
#   - connectDisconnect
#   - connectAddUser
#   - connectAddResident
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: #000000; color: #ffffff;"

  App.module "ConnectModule", (ConnectModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Connect] ConnectModule", debug.style

    @models = {}
    @views = {}

    # ============================================================
    # Controller

    # ============================================================
    # Model
    ConnectModel = Backbone.Model.extend(
      # ------------------------------------------------------------
      # /** 
      #  * ConnectModel#defaults
      #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
      #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
      #  * @type {Object}
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # ------------------------------------------------------------
      defaults: 
        isRun: false
        users: []

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#initialize
      #  * @constructor
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Connect] ConnectModel -> initialize", debug.style

        @listenTo @, "change:isRun", @_changeIsRunHandler
        @listenTo @, "change:users", @_changeUsersRunHandler

        # background へのLong-lived 接続
        @port = chrome.runtime.connect name: "contentScript"
        # @port = chrome.extension.connect name: "contentScript"
        
        # セットアップを行う
        @port.postMessage
          to: "background"
          from: "contentScript"
          type: "setup"

        @port.onMessage.addListener (message) =>
          # console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message
          # background からの通知か判別する
          if (message.from? and message.from is "background") and message.type?
            switch message.type
              when "setup"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup", debug.style, message.body
                @set "isRun", message.body.isRun

              when "changeIsRun"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | changeIsRun", debug.style, message.body
                @set "isRun", message.body.isRun

              when "jointed"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | jointed", debug.style, message.body
                App.vent.trigger "connectJointed"

              when "disconnect"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | disconnect", debug.style, message.body
                App.vent.trigger "connectDisconnect"

              when "addUser"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | addUser", debug.style, message.body
                App.vent.trigger "connectAddUser", message.body

              when "addResident"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | addResident", debug.style, message.body
                App.vent.trigger "connectAddResident", message.body
              
              when "initializeResident"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | initializeResident", debug.style, message.body
                App.vent.trigger "connectInitializeResident", message.body

              # when "checkIn"
              #   console.log "%c[Connect] ConnectModel | Long-lived Receive Message | checkIn", debug.style, message.body
              #   @set "users", message.body.users

              when "checkOut"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | checkOut", debug.style, message.body
                App.vent.trigger "connectCheckOut", message.body

              when "updateWindowSize"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updateWindowSize", debug.style, message.body
                App.vent.trigger "connectUpdateWindowSize", message.body
                
              when "updatePointer"
                # console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updatePointer", debug.style, message.body
                # マウス座標の変化を検知したらconnectUpdatePointer イベントを発火させる
                App.vent.trigger "connectUpdatePointer", message.body

              when "updateLandscape"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updateLandscape", debug.style, message.body
                # 同じRoom に所属しているユーザーのスクリーンショットの
                # 更新を検知したらconnectUpdateLandscape イベントを発火させる
                App.vent.trigger "connectUpdateLandscape", message.body

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * background からエクステンションの起動状態を受信した時の処理を設定する 
      #  * connectChangeIsRun イベントを発火させる
      #  * @prop {Object} model - BackBone Model Object
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  */
      # --------------------------------------------------------------
      _changeIsRunHandler: (model, isRun) ->
        console.log "%c[Connect] ConnectModel | _changeIsRunHandler", debug.style, isRun

        if isRun
          # App.vent.on "stageSetup", @_setupHandler @port
          App.vent.on "stageInitializeUser", @_initializeUserHandler @port
          App.vent.on "stageInitializeResident", @_initializeResidentHandler @port
          App.vent.on "stageWindowScroll", @_windowScrollHandler @port
          App.vent.on "stageWindowResize", @_windowResizeHandler @port
          App.vent.on "stagePointerMove", @_pointerMoveHandler @port

        else if not isRun
          App.vent.off "stageInitializeUser"
          App.vent.off "stageInitializeSpace"
          App.vent.off "stageWindowScroll"
          App.vent.off "stageWindowResize"
          App.vent.off "stagePointerMove"

        App.vent.trigger "connectChangeIsRun", isRun

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * connectChangeUsers イベントを発火させる
      #  * @prop {Object} model - BackBone Model Object
      #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # --------------------------------------------------------------
      _changeUsersRunHandler: (model, users) ->
        console.log "%c[Connect] ConnectModel | _changeUsersRunHandler", debug.style, users

        App.vent.trigger "connectChangeUsers", users

      # # --------------------------------------------------------------
      # # /**
      # #  * ConnectModel#_updateLandscape
      # #  * Background Scriptが保持しているスクリーンショットをアップデートする
      # #  */
      # # --------------------------------------------------------------
      # _updateLandscape: () ->
      #   console.log "%c[Connect] ConnectModel | _updateLandscape", debug.style

      #   # chrome.runtime.sendMessage
      #   #   to: "background"
      #   #   from: "contentScript"
      #   #   type: "updateLandscape"
      #   #   ,
      #   #   (response) =>
      #   #     console.log "%c[Connect] ConnectModel | updateLandscape | Response Message", debug.style, response

      # # --------------------------------------------------------------
      # # /**
      # #  * ConnectModel#_setupHandler
      # #  */
      # # --------------------------------------------------------------
      # _setupHandler: (port) ->
      #   return (data) ->
      #     console.log "%c[Connect] ConnectModel | _setupHandler", debug.style, data

      #     # port.postMessage
      #     #   to: "background"
      #     #   from: "contentScript"
      #     #   type: "updateLandscape"
      #     #   body: 
      #     #     devicePixelRatio: window.devicePixelRatio

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_initializeUserHandler
      #  * Stage Module で発火するstageInitializeUser イベントハンドラー
      #  * 受けっとたイベントオブジェクトを元にlover の初期化に必要な値を
      #  * background script へ通知する
      #  */
      # --------------------------------------------------------------
      _initializeUserHandler: (port) ->
        # /**
        #  * @param {Object} data
        #  * @prop {number} position.x - ポインターのx座標
        #  * @prop {number} position.y - ポインターのy座標
        #  * @prop {number} window.width - window の幅
        #  * @prop {number} window.height - window の高さ
        #  */
        return (data) ->
          console.log "%c[Connect] ConnectModel | _initializeUserHandler", debug.style, data

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "initializeUser"
            body: data

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_initializeResidentHandler
      #  * Stage Module で発火するstageInitializeResident のイベントハンドラー
      #  * 既存ユーザーのlover の初期化に必要な値を持つイベントオブジェクトを
      #  * background script へ通知する
      #  */
      # --------------------------------------------------------------
      _initializeResidentHandler: (port) ->
        # /**
        #  * @param {Object} data
        #  * @prop {string} toSocketId - 発信元のsocket.id
        #  * @prop {number} position.x - ポインターのx座標
        #  * @prop {number} position.y - ポインターのy座標
        #  * @prop {number} window.width - window の幅
        #  * @prop {number} window.height - window の高さ
        #  */
        return (data) ->
          console.log "%c[Connect] ConnectModel | _initializeResidentHandler", debug.style, data

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "initializeResident"
            body: data

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_windowScrollHandler
      #  * スクロール座標に変化があった時のイベントハンドラー
      #  * background script にスクリーンショットの撮影依頼をする
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # --------------------------------------------------------------
      _windowScrollHandler: (port) ->
        return () ->
          console.log "%c[Connect] ConnectModel | _windowScrollHandler", debug.style

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "updateLandscape"
            body: 
              devicePixelRatio: window.devicePixelRatio

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_windowResizeHandler
      #  * windowサイズに変化があった時のイベントハンドラー
      #  * background script にwindowサイズを通知とスクリーンショットの撮影依頼をする
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # --------------------------------------------------------------
      _windowResizeHandler: (port) ->
        # /**
        #  * @param {Object} windowSize
        #  * @prop {number} windowSize.width - 発信者のwindowの幅
        #  * @prop {number} windowSize.height - 発信者のwindowの高さ
        #  */
        return (windowSize) ->
          console.log "%c[Connect] ConnectModel | _windowResizeHandler", debug.style, windowSize

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "updateLandscape"
            body: null

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "windowResize"
            body: windowSize

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_pointerMoveHandler
      #  * ポインターの座標に変化があった時のイベントハンドラー
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # --------------------------------------------------------------
      _pointerMoveHandler: (port) ->
        # /**
        #  * @param {Object} position
        #  * @prop {number} position.x - 発信者のポインターのx座標
        #  * @prop {number} position.y - 発信者のポインターのy座標
        #  */
        return (position) ->
          # console.log "%c[Connect] ConnectModel | _pointerMoveHandler", debug.style, position

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "pointerMove"
            body: position
    )


    # ============================================================
    ConnectModule.addInitializer (options) ->
      console.log "%c[Connect] addInitializer", debug.style, options

      @models = 
        connect: new ConnectModel()

      # ============================================================
      # COMMANDS
      App.commands.setHandler "connectUpdateLandscape", () ->
        console.log "%c[Connect] Commands |connectUpdateLandscape", debug.style

      # App.execute "connectUpdateLandscape"

    # ============================================================
    ConnectModule.addFinalizer () ->
      console.log "%c[Connect] addFinalizer", debug.style



















