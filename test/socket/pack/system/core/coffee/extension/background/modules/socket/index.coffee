# ============================================================
# Socket
# 
# EVENT
#   - socketCheckIn
#   - socketCheckOut
#   - socketUpdatePointer
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: DarkTurquoise; color: #ffffff;"

  App.module "SocketModule", (SocketModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Socket] SocketModule", debug.style

    @models = {}

    # ============================================================
    # Controller
    # ============================================================


    # ============================================================
    # Model
    # ============================================================
    SocketModel = Backbone.Model.extend
      # ------------------------------------------------------------
      # /** 
      #  * SocketModel#defaults
      #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
      #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
      #  * @type {Object}
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  * @prop {boolean} isConnected - webSocketの接続状態
      #  * @prop {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # ------------------------------------------------------------
      defaults:
        isRun: false
        isConnected: false
        users: []

      # --------------------------------------------------------------
      # /**
      #  * SocketModel#initialize
      #  * @constructor
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Socket] SocketModel -> initialize", debug.style

        # エクステンションの起動状態に変化があった時のイベントリスナー
        @changeIsRunHandler = @_changeIsRunHandler.bind @
        App.vent.on "stageChangeIsRun", @changeIsRunHandler
        # window のサイズに変化があった時のイベントリスナー
        App.vent.on "connectWindowResize", @_windowResizeHandler.bind @
        # ポインターの座標に変化があった時のイベントリスナー
        App.vent.on "connectPointerMove", @_pointerMoveHandler.bind @
        # スクリーンショットが撮影された時のイベントリスナー
        App.vent.on "connectUpdateLandscape", @_updateLandscapeHandler.bind @
        # WebSocket の接続状態が変わった時に実行される
        @listenTo @, "change:isConnected", @_changeIsConnectedHandler.bind(@)

      # --------------------------------------------------------------
      # /**
      #  * SocketModel#_connect
      #  * webSocket サーバーに接続し、socket.io のイベントリスナーを登録する
      #  */
      # --------------------------------------------------------------
      _connect: () ->
        console.log "%c[Socket] SocketModel -> _connect", debug.style

        @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");

        @socket.on "connect", @_connectHandler.bind(@) # WebSocket が接続された時
        @socket.on "error", @_socketErrorHandler.bind(@)
        @socket.on "disconnect", @_disconnectHandler.bind(@) # WebSocket の接続が解除された時
        @socket.on "reconnect", @_reconnectHandler.bind(@)
        @socket.on "reconnect_attempt", @_reconnectAttemptHandler.bind(@)
        @socket.on "reconnecting", @_reconnectingHandler.bind(@)
        @socket.on "reconnect_error", @_reconnectErrorHandler.bind(@)
        @socket.on "reconnect_failed", @_reconnectFailedHandler.bind(@)

        # # 同じRoom に所属するユーザーのSocket ID の配列を受信する
        @socket.on "checkIn", @_receiveCheckInHandler.bind(@)
        # 同じRoom に所属していたユーザーのSocket ID を受信する
        @socket.on "checkOut", @_receiveCheckOutHandler.bind(@)
        # 同じRoom に所属するユーザーのポインター座標を受信する
        @socket.on "updatePointer", @_receiveUpdatePointerHandler.bind(@)

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_join
      #  * socket.io のroom へjoin する
      #  */
      # ------------------------------------------------------------
      _join: () ->
        console.log "%c[Socket] SocketModel -> join", debug.style

        @socket.emit "join"
        # @socket.emit "join", { roomId: "000000" }, (e) -> console.log e

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_windowResizeHandler
      #  */
      # ------------------------------------------------------------
      _windowResizeHandler: () ->
        console.log "%c[Socket] SocketModel -> _windowResizeHandler", debug.style
        
      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_pointerMoveHandler
      #  * ポインターの座標に変化があった時のイベントハンドラー
      #  * @param {Object}　pointerPosition
      #  * @prop {number} pointerPosition.x - ポインターのx座標
      #  * @prop {number} pointerPosition.y - ポインターのy座標
      #  */
      # ------------------------------------------------------------
      _pointerMoveHandler: (pointerPosition) ->
        # console.log "%c[Socket] SocketModel -> _pointerMoveHandler", debug.style, pointerPosition
        @socket.emit "pointerMove", pointerPosition

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_updateLandscapeHandler
      #  * @param {Object} landscape
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _updateLandscapeHandler: (landscape) ->
        console.log "%c[Socket] SocketModel -> _updateLandscapeHandler", debug.style, landscape
        @socket.emit "shootLandscape", landscape

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_connectHandler
      #  * webSocket サーバーと接続された時に実行される イベントハンドラー
      #  */
      # ------------------------------------------------------------
      _connectHandler: () ->
        console.log "%c[Socket] SocketModel -> _connectHandler", debug.style, @socket.id
        # 接続状態を変更
        @set "isConnected", true

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_changeIsRunHandler
      #  * エクステンションの起動された時に実行され、破棄される
      #  * @param {boolean} isRun - エクステンションの起動状態
      #  */
      # ------------------------------------------------------------
      _changeIsRunHandler: (isRun) ->
        console.log "%c[Socket] SocketModel -> _changeIsRunHandler", debug.style, isRun

        if isRun
          @set "isRun", isRun
          # エクステンションが起動状態であれば
          # このイベントリスナーを破棄し、Socket サーバーに接続する
          App.vent.off "stageChangeIsRun", @changeIsRunHandler
          @_connect()

          # socket の再接続と切断をするイベントリスナーを定義
          App.vent.on "stageChangeIsRun", @_toggleIsRunHandler.bind @

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_changeIsRunHandler
      #  * エクステンションの状態が変更された時に実行される
      #  * @param {boolean} isRun - エクステンションの起動状態
      #  */
      # ------------------------------------------------------------
      _toggleIsRunHandler: (isRun) ->
        console.log "%c[Socket] SocketModel -> _toggleIsRunHandler", debug.style, isRun
        @set "isRun", isRun

        if (isRun and (not @socket.connected))
          # エクステンションが起動され、かつWebSocket サーバーに接続されていない時
          # @_connect()
          @socket.connect()
        else if ((not isRun) and @socket.connected)
          # エクステンションが終了された時にWebSocket サーバーに接続されている時 
          @socket.disconnect()

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_socketErrorHandler
      #  * @param {Object} error - エラーデータ
      #  * socket 通信にエラーが発生した時に実行される
      #  */
      # ------------------------------------------------------------
      _socketErrorHandler: (error) ->
        console.log "%c[Socket] SocketModel -> _socketErrorHandler", debug.style, error

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_disconnectHandler
      #  * Socket サーバーとの接続が切断された時に実行される
      #  */
      # ------------------------------------------------------------
      _disconnectHandler: () ->
        console.log "%c[Socket] SocketModel -> _disconnectHandler", debug.style
        # 接続状態を変更
        @set "isConnected", false
        # 接続ユーザーを空にする
        @set "users", []

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_reconnectHandler
      #  * @param {number} reconnection - 再接続試行回数 
      #  */
      # ------------------------------------------------------------
      _reconnectHandler: (reconnection) ->
        console.log "%c[Socket] SocketModel -> _reconnectHandler", debug.style, reconnection

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_reconnectAttemptHandler
      #  * 再接続をする際に実行される
      #  */
      # ------------------------------------------------------------
      _reconnectAttemptHandler: () ->
        console.log "%c[Socket] SocketModel -> _reconnectAttemptHandler", debug.style

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_reconnectingHandler
      #  * @param {number} reconnection - 再接続試行回数 
      #  */
      # ------------------------------------------------------------
      _reconnectingHandler: (reconnection) ->
        console.log "%c[Socket] SocketModel -> _reconnectingHandler", debug.style, reconnection

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_socketErrorHandler
      #  * @param {Object} error - エラーデータ
      #  * 再接続にエラーが発生した時に実行される
      #  */
      # ------------------------------------------------------------
      _reconnectErrorHandler: (error) ->
        console.log "%c[Socket] SocketModel -> _reconnectErrorHandler", debug.style, error

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_reconnectFailedHandler
      #  */
      # ------------------------------------------------------------
      _reconnectFailedHandler: () ->
        console.log "%c[Socket] SocketModel -> _reconnectFailedHandler", debug.style

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveCheckInHandler
      #  * @param {Object} data
      #  * @param {[string]} data.users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # ------------------------------------------------------------
      _receiveCheckInHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveCheckInHandler", debug.style, data
        # 自身のsocket.id を除外する
        data.users = _.without(data.users, @socket.id)
        
        @set "users", data.users 
        # socketCheckIn イベントを発火する | connect がlisten
        App.vent.trigger "socketCheckIn", data.users

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveCheckOutHandler
      #  * @param {string} user - 同じRoom に所属していたユーザーのSocket ID
      #  */
      # ------------------------------------------------------------
      _receiveCheckOutHandler: (user) ->
        console.log "%c[Socket] SocketModel -> _receiveCheckOutHandler", debug.style, user

        # socketCheckOut イベントを発火する | connect がlisten
        App.vent.trigger "socketCheckOut", user

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveUpdatePointerHandler
      #  * @param {Object} data
      #  * @prop {string} socketId - 発信元のsocket.id
      #  * @prop {number} x - 発信者のポインターのx座標
      #  * @prop {number} y - 発信者のポインターのy座標
      #  */
      # ------------------------------------------------------------
      _receiveUpdatePointerHandler: (data) ->
        console.log "%c[Socket] Socket -> _receiveUpdatePointerHandler", debug.style, data

        # socketUpdatePointer イベントを発火する | connect がlisten
        App.vent.trigger "socketUpdatePointer", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_changeIsConnectedHandler
      #  * WebSocket サーバーへの接続状態が変わると呼び出される
      #  */
      # ------------------------------------------------------------
      _changeIsConnectedHandler: (socketModel, isConnected) ->
        console.log "%c[Socket] SocketModel -> _changeIsConnectedHandler", debug.style, socketModel, isConnected

        if isConnected
          # 接続がされている時
          @_join()
        



    # ============================================================
    SocketModule.addInitializer (options) ->
      console.log "%c[Socket] addInitializer", debug.style, options

      @models = 
        socket: new SocketModel()

      # ============================================================
      # COMMANDS

      # ============================================================
      # REQUEST RESPONSE
      App.reqres.setHandler "socketGetUsers", () =>
        console.log "%c[Socket] Request Response | socketGetUsers", debug.style
        return @models.socket.get "users"


    # ============================================================
    SocketModule.addFinalizer (options) ->
      console.log "%c[Socket] addFinalizer", debug.style, options




















