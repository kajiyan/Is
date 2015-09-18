# ============================================================
# Connect
#
# EVENT
#   - connectChangeIsRun
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: DarkGreen; color: #ffffff;"

  App.module "ConnectModule", (ConnectModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Connect] ConnectModule", debug.style

    # ============================================================
    # Controller
    # ============================================================



    # ============================================================
    # Model
    # ============================================================
    ConnectModel = Backbone.Model.extend
      # ------------------------------------------------------------
      # /** 
      #  * ConnectModel#defaults
      #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
      #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
      #  * @type {Object}
      #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      #  * @prop {boolean} extensionState.isRoomJoin - room 入室状態
      #  */
      # ------------------------------------------------------------
      defaults: 
        extensionState:
          isRun: false
          isConnected: false
          isRoomJoin: false

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#initialize
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Connect] ConnectModel -> initialize", debug.style

        @listenTo @, "change:extensionState", @_changeExtensionStateHandler

        # background へのLong-lived 接続
        @port = chrome.runtime.connect name: "popupScript"
        
        # セットアップを行う、起動状態を取得する
        @port.postMessage
          to: "background"
          from: "popupScript"
          type: "setup"

        @port.onMessage.addListener (message) =>
          # isrunが変わった時 join した時 disconnectした時
          if (message.to? and message.to is "popupScript") and (message.from? and message.from is "background") and message.type?
            console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message
            
            switch message.type
              # --------------------------------------------------------------
              when "setup"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup", debug.style, message.body
                App.vent.trigger "connectSetup", message.body
                # @set "extensionState", message.body

              # # --------------------------------------------------------------
              # when "changeIsRun"
              #   console.log "%c[Connect] ConnectModel | Long-lived Receive Message | changeIsRun", debug.style, message.body
              #   @set "extensionState", message.body

              # --------------------------------------------------------------
              when "jointed"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | jointed", debug.style, message.body
                @set "extensionState",
                  isRun: message.body.isRun
                  isConnected: message.body.isConnected
                  isRoomJoin: message.body.isRoomJoin
                App.vent.trigger "connectJointed", message.body

              # --------------------------------------------------------------
              when "disconnect"
                console.log "%c[Connect] ConnectModel | Long-lived Receive Message | disconnect", debug.style, message.body
                App.vent.trigger "connectDisconnect", message.body

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeExtensionStateHandler
      #  * background からエクステンションの起動状態を受信した時の処理を設定する 
      #  * connectChangeExtensionState イベントを発火させる
      #  * @param {Object} model - BackBone Model Object
      #  * @param {Object} extensionState
      #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      #  */
      # --------------------------------------------------------------
      _changeExtensionStateHandler: (model, extensionState) ->
        console.log "%c[Connect] ConnectModel | _changeExtensionStateHandler", debug.style, extensionState
        App.vent.trigger "connectChangeExtensionState", extensionState



    # ============================================================
    ConnectModule.addInitializer (options) ->
      console.log "%c[Connect] addInitializer", debug.style, options

      @models = 
        connect: new ConnectModel()

      # ============================================================
      # COMMANDS


    # ============================================================
    ConnectModule.addFinalizer (options) ->
      console.log "%c[Connect] addFinalizer", debug.style, options





























