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


        chrome.runtime.onConnect.addListener (port) =>
          console.log "%c[Connect] ConnectModel | onConnect", debug.style

          # background からの接続
          if port.name is "background"
            @_setBackgroundPort port


        # データの受信
        chrome.extension.onMessage.addListener (request, sender, sendResponse) =>
          # console.log "%c[Connect] ConnectModel | Receive Message", debug.style, request, sender, sendResponse

          # background からの通知か判別する
          if (request.from? and request.from is "background") and request.type?
            switch request.type
              when "changeIsRun"
                console.log "%c[Connect] ConnectModel | Receive Message | changeIsRun", debug.style, request, sender, sendResponse
                @set "isRun", request.body.isRun

              when "checkIn"
                console.log "%c[Connect] ConnectModel | Receive Message | checkIn", debug.style, request, sender, sendResponse
                @set "users", request.body.users


        # background にデータを送信
        chrome.runtime.sendMessage
          to: "background"
          from: "contentScript"
          type: "setup"
          ,
          (response) =>
            # エクステンションの起動状態が返ってくる
            console.log "%c[Connect] ConnectModel | setup | Response Message", debug.style, response
            @set "isRun", response.body.isRun

        @_updateLandscape()

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

        if not isRun
          App.vent.off "stagePointerMove"
          # @stopListening sn.bb.models.stage, "change:pointerPosition"

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

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_updateLandscape
      #  * Background Scriptが保持しているスクリーンショットをアップデートする
      #  */
      # --------------------------------------------------------------
      _updateLandscape: () ->
        console.log "%c[Connect] ConnectModel | _updateLandscape", debug.style

        chrome.runtime.sendMessage
          to: "background"
          from: "contentScript"
          type: "updateLandscape"
          ,
          (response) =>
            console.log "%c[Connect] ConnectModel | updateLandscape | Response Message", debug.style, response

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_setBackgroundPort
      #  * background と接続しているLong-lived なポートの設定をする
      #  * @param {Port} port - 双方向通信を可能にするオブジェクト
      #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
      #  */
      # --------------------------------------------------------------
      _setBackgroundPort: (port) ->
        console.log "%c[Connect] ConnectModel | _setBackgroundPort", debug.style, port

        port.postMessage
          to: "background"
          from: "contentScript"

        App.vent.on "stagePointerMove", @_pointerMoveHandler(port)

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changePointerPositionHandler
      #  * ポインターの座標に変化があった時のイベントハンドラー
      #  */
      # --------------------------------------------------------------
      _pointerMoveHandler: (port) ->
        return (pointerPosition) ->
          console.log "%c[Connect] ConnectModel | _changePointerPositionHandler", debug.style, pointerPosition, port

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



















