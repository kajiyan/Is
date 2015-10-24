# ============================================================
# Socket
# 
# EVENT
#   - socketConnecteded
#   - socketDisconnect
#   - socketJointed
#   - socketAddUser
#   - socketCheckIn
#   - socketCheckOut
#   - socketUpdatePointer
#   - socketUpdateLandscape
#   - socketResponseMemory
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
      #  * @prop {Object} residents - 同じRoomに所属するユーザーの初期化に必要な値が入った配列
      #  * @prop {boolean} extensionState.isRoomJoin - room 入室状態
      #  */
      # ------------------------------------------------------------
      defaults:
        isRun: false
        isConnected: false
        isRoomJoin: false
        residents: []

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
        # ユーザーの初期値が揃った時のイベントリスナー
        App.vent.on "connectInitializeUser", @_initializeUserHandler.bind @
        # 新規ユーザーに通知する値が揃った時のイベントリスナー
        App.vent.on "connectInitializeResident", @_initializeResidentHandler.bind @
        # リンクに変化があった時のイベントリスナー
        App.vent.on "connectChangeLocation", @_changeLocationHandler.bind @
        # window のサイズに変化があった時のイベントリスナー
        App.vent.on "connectWindowResize", @_windowResizeHandler.bind @
        # ポインターの座標に変化があった時のイベントリスナー
        App.vent.on "connectPointerMove", @_pointerMoveHandler.bind @
        # スクリーンショットが撮影された時のイベントリスナー
        App.vent.on "connectUpdateLandscape", @_updateLandscapeHandler.bind @
        # content scriptからポインターの軌跡データが用意された通知を受け取った時のイベントリスナー
        App.vent.on "connectAddMemory", @_addMemoryHandler.bind @
        # content scriptからMemoryの取得依頼を受信した時のイベントリスナー
        App.vent.on "connectGetMemory", @_getMemoryHandler.bind @
        # WebSocket の接続状態が変わった時に実行される
        @listenTo @, "change:isConnected", @_changeIsConnectedHandler.bind @

      # --------------------------------------------------------------
      # /**
      #  * SocketModel#_connect
      #  * webSocket サーバーに接続し、socket.io のイベントリスナーを登録する
      #  */
      # --------------------------------------------------------------
      _connect: () ->
        console.log "%c[Socket] SocketModel -> _connect", debug.style
        
        if SETTING.MODE is "PRODUCTION"
          @socket = io.connect("#{SETTING.PROTOCOL}://#{SETTING.PRODUCTION_HOST}:#{SETTING.PORT}/extension")
          # @socket = io.connect("#{SETTING.PROTOCOL}://#{SETTING.PRODUCTION_HOST}:#{ SETTING.PORT + (~~(Math.random() * 4)) }/extension")
        else
          @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");
          # @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");

        # DEBUG
        # @socket = io.connect("#{SETTING.PROTOCOL}://localhost:8001/extension");

        # @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");
        # @socket = io("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");

        @socket.on "connect", @_connectHandler.bind(@) # WebSocket が接続された時
        @socket.on "error", @_socketErrorHandler.bind(@)
        @socket.on "disconnect", @_disconnectHandler.bind(@) # WebSocket の接続が解除された時
        @socket.on "reconnect", @_reconnectHandler.bind(@)
        @socket.on "reconnect_attempt", @_reconnectAttemptHandler.bind(@)
        @socket.on "reconnecting", @_reconnectingHandler.bind(@)
        @socket.on "reconnect_error", @_reconnectErrorHandler.bind(@)
        @socket.on "reconnect_failed", @_reconnectFailedHandler.bind(@)

        # 同じRoom に所属するユーザーのSocket ID の配列を受信する
        # @socket.on "checkIn", @_receiveCheckInHandler.bind(@)

        @socket.on "addUser", @_receiveAddUserHandler.bind(@)
        # 同じRoom に所属するユーザーの初期化に必要なデータを受信する
        @socket.on "addResident", @_receiveAddResidentHandler.bind(@)
        # 同じRoom に所属していたユーザーのSocketIDを受信する
        @socket.on "checkOut", @_receiveCheckOutHandler.bind(@)
        # 同じRoom に所属するユーザーの閲覧しているURLを受信する
        @socket.on "updateLocation", @_receiveUpdateLocationHandler.bind(@)
        # 同じRoom に所属するユーザーのwindowサイズの変化を受信する
        @socket.on "updateWindowSize", @_receiveWindowSizeHandler.bind(@)
        # 同じRoom に所属するユーザーのポインター座標を受信する
        @socket.on "updatePointer", @_receiveUpdatePointerHandler.bind(@)
        # 同じRoom に所属するユーザーのスクリーンショットを受信する
        @socket.on "updateLandscape", @_receiveUpdateLandscapeHandler.bind(@)

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_disconnectHandler
      #  * Socket サーバーとの接続が切断された時に実行される
      #  * socketDisconnectイベントを発火させる
      #  */
      # ------------------------------------------------------------
      _disconnectHandler: () ->
        console.log "%c[Socket] SocketModel -> _disconnectHandler", debug.style
        
        @set 
          "isConnected": false # 接続状態を切断状態へ変更
          "isRoomJoin": false  # 接続状態を退室状態へ変更
          "residents": []      # 接続ユーザーを空にする
        App.vent.trigger "socketDisconnect"

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_join
      #  * socket.io のroom へjoin する
      #  */
      # ------------------------------------------------------------
      _join: () ->
        console.log "%c[Socket] SocketModel -> join", debug.style

        data =
          roomId: App.reqres.request "stageGetRoomId"

        @socket.emit "join", data, (data) =>
          console.log "%c[Socket] SocketModel -> jointed", debug.style, data
          # joinできなかったらソケットを切断する

          if data.status is "success"
            # 接続状態を入室状態へ変更
            @set "isRoomJoin", true
          else if data.status is "error"
            App.reqres.request "stageStopApp"
            @socket.disconnect()
            @set "isRoomJoin", false
          
          # socketJointed イベントを発火する
          # connect がイベントを購読している
          App.vent.trigger "socketJointed", data
          
      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_initializeUserHandler
      #  * 接続時の初期値をsocket サーバーに送信する
      #  * @param {Object}
      #  * @prop {number} position.x - 接続ユーザーのポインター x座標
      #  * @prop {number} position.y - 接続ユーザーのポインター y座標
      #  * @prop {number} window.width - 接続ユーザーのwindow の幅
      #  * @prop {number} window.height - 接続ユーザーのwindow の高さ
      #  * @prop {string} link - 接続ユーザーが閲覧していたページのURL
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _initializeUserHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _initializeUserHandler", debug.style, data
        @socket.emit "initializeUser", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_initializeResidentHandler
      #  * Roomにjoinした新規ユーザーに対してloverの初期化に必要な値をsoketサーバーに発信する
      #  * @prop {string} toSoketId - 送信先のsocketID
      #  * @prop {number} position.x - ポインターx座標
      #  * @prop {number} position.y - ポインターy座標
      #  * @prop {number} window.width - windowの幅
      #  * @prop {number} window.height - windowの高さ
      #  * @prop {string} link - 閲覧しているページのURL
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _initializeResidentHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _initializeResidentHandler", debug.style, data
        @socket.emit "initializeResident", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_changeLocationHandler
      #  * @param {Object} data
      #  * @prop {string} link - 接続ユーザーの閲覧しているURL
      #  */
      # ------------------------------------------------------------
      _changeLocationHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _changeLocationHandler", debug.style, data
        if @get "isConnected"
          @socket.emit "changeLocation", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_windowResizeHandler
      #  * windowサイズに変化があった時のイベントハンドラー
      #  * @param {Object}　windowSize
      #  * @prop {number} windowSize.width - 接続ユーザーのwindowの幅
      #  * @prop {number} windowSize.height - 接続ユーザーのwindowの高さ
      #  */
      # ------------------------------------------------------------
      _windowResizeHandler: (windowSize) ->
        console.log "%c[Socket] SocketModel -> _windowResizeHandler", debug.style, windowSize
        @socket.emit "windowResize", windowSize

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_pointerMoveHandler
      #  * ポインターの座標に変化があった時のイベントハンドラー
      #  * @param {Object}　position
      #  * @prop {number} position.x - ポインターのx座標
      #  * @prop {number} position.y - ポインターのy座標
      #  */
      # ------------------------------------------------------------
      _pointerMoveHandler: (position) ->
        # console.log "%c[Socket] SocketModel -> _pointerMoveHandler", debug.style, position
        @socket.emit "pointerMove", position

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_updateLandscapeHandler
      #  * @param {Object} data
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _updateLandscapeHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _updateLandscapeHandler", debug.style, data
        
        if @get "isConnected"
          @socket.emit "shootLandscape", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_addMemoryHandler
      #  * content scriptからポインターの軌跡データが用意された通知を受け取った時のイベントハンドラー
      #  * @param {Object} data
      #  * @prop {string} link - 接続ユーザーの閲覧しているURL
      #  * @param {Object} window - 発信者のwindowのサイズ
      #  * @prop {number} window.width - 発信者のwindowの幅
      #  * @prop {number} window.height - 発信者のwindowの高さ
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  * @param {[Object]} positions - 発信者のポインター軌跡の配列
      #  * @prop {number} positions[0].x - 発信者のポインターのx座標の軌跡
      #  * @prop {number} positions[0].y - 発信者のポインターのy座標の軌跡
      #  */
      # ------------------------------------------------------------      
      _addMemoryHandler: (data) ->
        console.log "%c[Socket] Socket -> _addMemoryHandler", debug.style, data

        if @get "isConnected"
          @socket.emit "addMemory", data, (status) ->
            App.vent.trigger "socketAddedMemory", status

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_getMemoryHandler
      #  * @param {Object} data
      #  * @prop {number} limit - 取得数
      #  */
      # ------------------------------------------------------------      
      _getMemoryHandler: (data) ->
        console.log "%c[Socket] Socket -> _getMemoryHandler", debug.style, data

        if @get "isConnected"
          @socket.emit "getMemory", data, (memorys) ->
            console.log memorys
            App.vent.trigger "socketResponseMemory", memorys

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
        App.vent.trigger "socketConnected", true

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
      #  * SocketModel#_toggleIsRunHandler
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
      #  * SocketModel#_receiveAddUserHandler
      #  * 所属するroom に新たなユーザーが入室した時に呼び出される
      #  * socketAddUser イベントを発火する
      #  * @param {Object} data
      #  * @prop {string} id - 発信元のsocket.id
      #  * @prop {number} position.x - 接続ユーザーのポインター x座標
      #  * @prop {number} position.y - 接続ユーザーのポインター y座標
      #  * @prop {number} window.width - 接続ユーザーのwindow の幅
      #  * @prop {number} window.height - 接続ユーザーのwindow の高さ
      #  * @prop {string} link - 接続ユーザーが閲覧していたページのURL
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _receiveAddUserHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveAddUserHandler", debug.style, data
        App.vent.trigger "socketAddUser", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveAddResidentHandler
      #  * 同じRoomに所属するユーザーの初期化に必要なデータを受信したときのイベントハンドラー
      #  * ユーザー情報を配列に保存し、socketAddResidentイベントを発火させる
      #  * @param {Object} data
      #  * @prop {string} id - 接続済ユーザーのsocket.id
      #  * @prop {number} position.x - 接続済ユーザーのポインター x座標
      #  * @prop {number} position.y - 接続済ユーザーのポインター y座標
      #  * @prop {number} window.width - 接続済ユーザーのwindow の幅
      #  * @prop {number} window.height - 接続済ユーザーのwindow の高さ
      #  * @prop {string} link - 接続済ユーザーが閲覧していたページのURL
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _receiveAddResidentHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveAddResidentHandler", debug.style, data
        
        residents = @get "residents"

        # residentsが空であれば重複をチェックせずdataを追加する
        if residents.length is 0
          residents.push data
          @set "residents", residents
          App.vent.trigger "socketAddResident", data
          return

        # 表示リストに追加されていないResidentがあるか調べる
        for resident, index in residents
          if _.indexOf(data.id, resident.id) is -1
            residents.push data
            @set "residents", residents
            App.vent.trigger "socketAddResident", data

        # residents = @get "residents"
        # residents.push data
        # @set "residents", residents


      # # ------------------------------------------------------------
      # # /**
      # #  * SocketModel#_receiveCheckInHandler
      # #  * @param {Object} data
      # #  * @param {[string]} data.users - 同じRoom に所属するユーザーのSocket ID の配列
      # #  */
      # # ------------------------------------------------------------
      # _receiveCheckInHandler: (data) ->
      #   console.log "%c[Socket] SocketModel -> _receiveCheckInHandler", debug.style, data
      #   # 自身のsocket.id を除外する
      #   data.users = _.without(data.users, @socket.id)
        
      #   @set "users", data.users 
      #   # socketCheckIn イベントを発火する | connect がlisten
      #   App.vent.trigger "socketCheckIn", data.users

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveCheckOutHandler
      #  * @param {Object} data
      #  * @prop {string} id - 同じRoomに所属していたユーザーのSocketID
      #  */
      # ------------------------------------------------------------
      _receiveCheckOutHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveCheckOutHandler", debug.style, data
        # socketCheckOut イベントを発火する | connect がlisten
        App.vent.trigger "socketCheckOut", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveWindowSizeHandler
      #  * @param {Object} data
      #  * @prop {string} id - 発信者のsocket.id
      #  * @prop {string} link - 接続ユーザーの閲覧しているURL
      #  */
      # ------------------------------------------------------------
      _receiveUpdateLocationHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveUpdateLocationHandler", debug.style, data
        App.vent.trigger "socketUpdateLocation", data        

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveWindowSizeHandler
      #  * @param {Object} data
      #  * @prop {string} id - 発信者のsocket.id
      #  * @prop {number} window.width - 発信者のwindowの幅
      #  * @prop {number} window.height - 発信者のwindowの高さ
      #  */
      # ------------------------------------------------------------
      _receiveWindowSizeHandler: (data) ->
        console.log "%c[Socket] SocketModel -> _receiveWindowSizeHandler", debug.style, data
        App.vent.trigger "socketUpdateWindowSize", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveUpdatePointerHandler
      #  * @param {Object} data
      #  * @prop {string} id - 発信者のsocket.id
      #  * @prop {number} position.x - 発信者のポインターのx座標
      #  * @prop {number} position.y - 発信者のポインターのy座標
      #  */
      # ------------------------------------------------------------
      _receiveUpdatePointerHandler: (data) ->
        # console.log "%c[Socket] Socket -> _receiveUpdatePointerHandler", debug.style, data
        # socketUpdatePointer イベントを発火する | connect がlisten
        App.vent.trigger "socketUpdatePointer", data

      # ------------------------------------------------------------
      # /**
      #  * SocketModel#_receiveUpdateLandscapeHandler
      #  * socketUpdateLandscape イベントを発火する | connect がlisten
      #  * @param {Object} data
      #  * @prop {string} socketId - 発信元のsocket.id
      #  * @prop {number} devicePixelRatio - 発信元のデバイスピクセル比
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # ------------------------------------------------------------
      _receiveUpdateLandscapeHandler: (data) ->
        console.log "%c[Socket] Socket -> _receiveUpdateLandscapeHandler", debug.style, data

        App.vent.trigger "socketUpdateLandscape", data

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
      App.reqres.setHandler "socketGetIsConnected", () =>
        console.log "%c[Socket] Request Response | socketGetIsConnected", debug.style
        return @models.socket.get "isConnected"

      App.reqres.setHandler "socketGetIsRoomJoin", () =>
        console.log "%c[Socket] Request Response | socketGetIsRoomJoin", debug.style
        return @models.socket.get "isRoomJoin"

      App.reqres.setHandler "socketGetResidents", () =>
        console.log "%c[Socket] Request Response | socketGetResidents", debug.style
        return @models.socket.get "residents"


    # ============================================================
    SocketModule.addFinalizer (options) ->
      console.log "%c[Socket] addFinalizer", debug.style, options




















