# ============================================================
# SOCKET
module.exports = (sn, $, _) ->
  class Socket extends Backbone.Model
    defaults:
      connected: false
      readText: ""
      readLightValue: ""

    # ------------------------------------------------------------
    constructor: (sn, $, Backbone, _) ->
      console.log "Socket -> Constructor"

      # クラスの継承
      super

      # @_setting = sn.SETTING
      # @_socket = null;


    # ------------------------------------------------------------
    initialize: () ->
      console.log "Socket -> initialize"

      @_setting = SETTING
      @_socket = null;

    # ------------------------------------------------------------
    setup: () ->
      console.log "Socket -> Setup"

      @_events()

    # ------------------------------------------------------------
    _events: () ->
      console.log "Socket -> _events"

      @listenTo sn.__client__.models.image, "resize", @_imageResizeHandler
      @listenTo sn.__client__.models.deviceSensor, "throw", @_devicesensorThrowHandler


    # ------------------------------------------------------------
    connect: () ->
      console.log "Socket -> connect"

      # 接続が確立されていたら何も処理しない
      if @_socket then return

      socket = io.connect "http://#{@_setting.HOST}:#{@_setting.PORT}/client"
      socket.on "connect", @_connectHandler.bind(@)
      socket.on "connecting", @_connectingHandler.bind(@)
      socket.on "connect_failed", @_connectFailedHandler.bind(@)
      socket.on "disconnect", @_disconnectHandler.bind(@)      
      socket.on "reconnect", @_reconnectHandler.bind(@)
      socket.on "reconnect_failed", @_reconnectFailedHandler.bind(@)

      # ローカルホストからの node.js を経由して受信する値
      socket.on "readText", @_readText.bind(@)
      socket.on "readLightValue", @_readLightValue.bind(@)

      @_socket = socket;


    # ------------------------------------------------------------ 
    _readText: ( data ) ->
      console.log "Socket -> _readText"
      @set "readText", data.text


    # ------------------------------------------------------------ 
    _readLightValue: ( data ) ->
      console.log "Socket -> _readLightValue: #{data.value}"
      @set "readLightValue", data.value


    # ------------------------------------------------------------
    join: (roomid, callback) ->
      console.log "Socket -> join"

      @_socket.emit("join", {'id': roomid}, callback)


    # ------------------------------------------------------------
    _imageResizeHandler: (model, data) ->
      console.log "Socket -> _imageResizeHandler"

      if not this._socket or not data then return

      width = model.get "width"
      height = model.get "height"

      @_socket.emit "post",
        data: data
        width: width
        height: height
        userInfo: ""
      , (err, id) ->
        sn.__client__.models.image.set "id", id


    # ------------------------------------------------------------
    _devicesensorThrowHandler: (model) ->
      console.log "Socket -> _devicesensorThrowHandler id: #{sn.__client__.models.image.id}"

      if not @_socket then return

      console.log sn.__client__.models.image.get "id"

      @_socket.emit "trigger", id: sn.__client__.models.image.get "id"

      # オリジナルはviewa image -> clearの中でモデルデータを削除している
      sn.__client__.models.image.clear()


    # ------------------------------------------------------------
    _connectHandler: () ->
      console.log "Socket -> _connectHandler"

      @set "connected", true


    # ------------------------------------------------------------
    _connectingHandler: () ->
      console.log "Socket -> _connectingHandler"


    # ------------------------------------------------------------
    _connectFailedHandler: () ->
      console.log "Socket -> _connectFailedHandler"

      @trigger "failed", new Error("Connection failed")


    # ------------------------------------------------------------
    _disconnectHandler: () ->
      console.log "Socket -> _disconnectHandler"

      @set "connected", false


    # ------------------------------------------------------------
    _reconnectHandler: () ->
      console.log "Socket -> _reconnectHandler"


    # ------------------------------------------------------------
    _reconnectFailedHandler: () ->
      console.log "Socket -> _reconnectFailedHandler"

      @trigger "failed", new Error("Reconnection failed")


  # return Instance = new Socket(sn, $, _)










