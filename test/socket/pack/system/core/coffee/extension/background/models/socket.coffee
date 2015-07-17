# ============================================================
# Socket
module.exports = (sn, $, _) ->
	class Socket extends Backbone.Model
    # ------------------------------------------------------------
    defaults: {}
		
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

      @socket = io.connect("#{SETTING.PROTOCOL}:#{SETTING.BASE_URL}extension");





    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Socket -> initialize"





    # ------------------------------------------------------------
    setup: () ->
      console.log "[Model] Socket -> setup"
      return $.Deferred (defer) =>
        onDone = =>
          defer.resolve()

        @_setEvent()

        # for key, model of sn.bb.models
        #   @listenTo model, "change:selsectTabId", @_setTabSocket

        onDone()
      .promise()





    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Socket -> _setEvent"

      @socket.on "connect", @_connectHandler.bind(@)
      # @socket.on "connect_error", @_connectErrorHandler.bind(@)
      # @socket.on "connect", @_connectHandler.bind(@)
      # @socket.on "connect", @_connectHandler.bind(@)
      # @socket.on "connect", @_connectHandler.bind(@)
      # @socket.on "connect", @_connectHandler.bind(@)

    _connectHandler: ( e ) ->
      console.log "[Model] Socket -> _connectHandler", e      









