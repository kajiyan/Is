# ============================================================
# Socket
module.exports = (sn, $, _) ->
	class Socket extends Backbone.Model
    # ------------------------------------------------------------
    defaults:
      isConnected: false
		
    # ------------------------------------------------------------
    # /**
    #  * WebSocket 通信のデータを管理するモデルクラス
    #  * Socket 接続を確立する
    #  * @constructor
    #  * @extends Backbone.Model
    #  */
    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Socket -> Constructor"
      super

      @socket = {}





    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Socket -> initialize"

      # WebSocket の接続状態が変わったら実行される
      @on "change:isConnected", @_changeIsConnectedHandler.bind(@)


      for key, model of sn.bb.models
        # popup の開閉状態が変わったら実行される
        @listenTo model, "change:isPopupOpen", @_changeIsPopupOpenHandler.bind( @ )




    # ------------------------------------------------------------
    setup: () ->
      console.log "[Model] Socket -> setup"
      return $.Deferred (defer) =>
        onDone = =>
          defer.resolve()

        # TEST 本来はpopupの状態に依存する
        @connect()

        onDone()
      .promise()





    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Socket -> _setEvent"

      @listenTo sn.bb.models.connect, "pointerMove", @_sendPointerMove

      # WebSocket が接続された時
      @socket.on "connect", @_connectHandler.bind(@)
      @socket.on "error", @_socketErrorHandler.bind(@)
      # WebSocket の接続が解除された時
      @socket.on "disconnect", @_disconnectHandler.bind(@)
      @socket.on "reconnect", @_reconnectHandler.bind(@)
      @socket.on "reconnect_attempt", @_reconnectAttemptHandler.bind(@)
      @socket.on "reconnecting", @_reconnectingHandler.bind(@)
      @socket.on "reconnect_error", @_reconnectErrorHandler.bind(@)
      @socket.on "reconnect_failed", @_reconnectFailedHandler.bind(@)

      # 同じRoom に所属するユーザーのSocket ID の配列を受信する
      @socket.on "checkIn", @_receiveCheckInHandler.bind(@)

      @socket.on "updatePointer", (data) -> console.log data


    
    # ------------------------------------------------------------
    connect: ->
      console.log "[Model] Socket -> connect"

      @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");
      
      @_setEvent()


    # ------------------------------------------------------------
    join: () ->
      console.log "[Model] Socket -> join"

      # @socket.emit "join", { roomId: "000000" }, (e) -> console.log e
      @socket.emit "join"

    # ------------------------------------------------------------
    _sendPointerMove: (pointerPosition) ->
      console.log "[Model] Socket -> pointerMove", pointerPosition

      @socket.emit "pointerMove", pointerPosition

    # ------------------------------------------------------------
    # /**
    #  * _changeIsPopupOpenHandler
    #  * 
    #  * ポップアップの開閉状態が変更された時に実行される
    #  */
    # ------------------------------------------------------------
    _changeIsPopupOpenHandler: ( model, isPopupOpen ) ->
      console.log "[Model] Socket -> _changeIsPopupOpenHandler"

      if isPopupOpen and not @socket.connected
        # ポップアップが展開され、かつWebSocket サーバーに接続されていない時
        @connect()
      else if not isPopupOpen and @socket.connected
        # ポップアップが閉じられた時にWebSocket サーバーに接続されている時
        @socket.disconnect()


    # ------------------------------------------------------------
    # /**
    #  * _changeIsConnectedHandler
    #  * 
    #  * WebSocket サーバーへの接続状態が変わると呼び出される
    #  */
    # ------------------------------------------------------------
    _changeIsConnectedHandler: ( model, isConnected ) ->
      console.log "[Model] Socket -> _changeIsConnectedHandler", model, isConnected

      if isConnected
        # 接続がされている時
        @join()
      # # else


    # ------------------------------------------------------------
    # /**
    #  * _connectHandler
    #  * Socket サーバーと接続された時に実行される
    #  */
    # ------------------------------------------------------------
    _connectHandler: () ->
      console.log "[Model] Socket -> _connectHandler"

      console.log(@socket.id);

      # 接続状態を変更
      @set "isConnected", true
      # @socket.disconnect();

    # ------------------------------------------------------------
    # /**
    #  * _socketErrorHandler
    #  * @param {Object} error - エラーデータ
    #  * socket 通信にエラーが発生した時に実行される
    #  */
    # ------------------------------------------------------------
    _socketErrorHandler: ( error ) ->
      console.log "[Model] Socket -> _socketErrorHandler", error

    # ------------------------------------------------------------
    # /**
    #  * _disconnectHandler
    #  * Socket サーバーとの接続が切断された時に実行される
    #  */
    # ------------------------------------------------------------
    _disconnectHandler: () ->
      console.log "[Model] Socket -> _disconnectHandler"
      # 接続状態を変更
      @set "isConnected", false

    # ------------------------------------------------------------
    # /**
    #  * _reconnectHandler
    #  * @param {number} reconnection - 再接続試行回数 
    #  */
    # ------------------------------------------------------------
    _reconnectHandler: ( reconnection ) ->
      console.log "[Model] Socket -> _reconnectHandler", reconnection

    # ------------------------------------------------------------
    # /**
    #  * _reconnectAttemptHandler
    #  * @param {number} reconnection - 再接続試行回数 
    #  * 再接続をする際に実行される
    #  */
    # ------------------------------------------------------------
    _reconnectAttemptHandler: () ->
      console.log "[Model] Socket -> _reconnectAttemptHandler"

    # ------------------------------------------------------------
    # /**
    #  * _reconnectingHandler
    #  * @param {number} reconnectingion - 再接続試行回数 
    #  */
    # ------------------------------------------------------------
    _reconnectingHandler: ( reconnection ) ->
      console.log "[Model] Socket -> _reconnectingHandler", reconnection

    # ------------------------------------------------------------
    # /**
    #  * _socketErrorHandler
    #  * @param {Object} error - エラーデータ
    #  * 再接続にエラーが発生した時に実行される
    #  */
    # ------------------------------------------------------------
    _reconnectErrorHandler: ( error ) ->
      console.log "[Model] Socket -> _reconnectErrorHandler", error

    # ------------------------------------------------------------
    # /**
    #  * _reconnectFailedHandler
    #  */
    # ------------------------------------------------------------
    _reconnectFailedHandler: () ->
      console.log "[Model] Socket -> _reconnectErrorHandler"

    # ------------------------------------------------------------
    # /**
    #  * _receiveCheckInHandler
    #  * @param {Object} data
    #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
    #  */
    # ------------------------------------------------------------
    _receiveCheckInHandler: (data) ->
      console.log "[Model] Socket -> _receiveCheckInHandler", data

      # checkIn イベントを発火する
      # [model] connect がlisten
      @trigger "socketCheckIn", data





















