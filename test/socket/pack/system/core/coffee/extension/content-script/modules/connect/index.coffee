# ============================================================
# Connect
# 
# EVENT
#   - connectChangeUsers
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

              when "checkIn"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | checkIn", debug.style, message.body
                @set "users", message.body.users

              when "checkOut"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | checkOut", debug.style, message.body

              when "updatePointer"
                # console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updatePointer", debug.style, message.body
                
                # マウス座標の変化を検知したらconnectUpdatePointer イベントを発火させる
                App.vent.trigger "connectUpdatePointer", message.body


      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * background からエクステンションの起動状態を受信した時の処理を設定する 
      #  * @prop {Object} model - BackBone Model Object
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  */
      # --------------------------------------------------------------
      _changeIsRunHandler: (model, isRun) ->
        console.log "%c[Connect] ConnectModel | _changeIsRunHandler", debug.style, isRun

        if isRun
          App.vent.on "stagePointerMove", @_pointerMoveHandler @port
        else if not isRun
          App.vent.off "stagePointerMove"

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
      # #  * ConnectModel#_setBackgroundPort
      # #  * background と接続しているLong-lived なポートの設定をする
      # #  * @param {Port} port - 双方向通信を可能にするオブジェクト
      # #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
      # #  */
      # # --------------------------------------------------------------
      # _setBackgroundPort: (port) ->
      #   console.log "%c[Connect] ConnectModel | _setBackgroundPort", debug.style, port

      #   # メッセージを受信した時の処理
      #   port.onMessage.addListener (message) =>
      #     console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

      #   port.postMessage
      #     to: "background"
      #     from: "contentScript"

      #   App.vent.on "stagePointerMove", @_pointerMoveHandler(port)

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_pointerMoveHandler
      #  * ポインターの座標に変化があった時のイベントハンドラー
      #  */
      # --------------------------------------------------------------
      _pointerMoveHandler: (port) ->
        return (pointerPosition) ->
          # console.log "%c[Connect] ConnectModel | _pointerMoveHandler", debug.style, pointerPosition, port

          port.postMessage
            to: "background"
            from: "contentScript"
            type: "pointerMove"
            body: pointerPosition
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



















