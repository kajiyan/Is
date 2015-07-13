# ============================================================
# CONTEXT
module.exports = (sn, $, _) ->
  class Context extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      roomid: $("body").data("roomid")
    
    # ------------------------------------------------------------
    constructor: () ->
      console.log "Context -> Constructor"

      # クラスの継承
      super

      # Models
      # @mode = do ->
      #   Mode = require("./mode")
      #   return new Mode(sn)
      # @room = do ->
      #   Room = require("./room")
      #   return new Room(sn)

      # sn.__client__.models.socket = require("./socket")(sn, $, _)


    # ------------------------------------------------------------
    initialize: () ->
      console.log "Context -> Initialize"


    # ------------------------------------------------------------
    _events: () ->
      console.log "Context -> _events"

      @listenTo sn.__client__.models.socket, "change:connected", @_changeConnectedHandler
      @listenTo sn.__client__.models.socket, "failed", @_failedHandler


    # ------------------------------------------------------------
    setup: () ->
      console.log "Context -> Setup"

      # イベントリスナーの登録
      @_events()

      # Web Socket 接続
      sn.__client__.models.socket.connect()


    # ------------------------------------------------------------
    _changeConnectedHandler: (model, connected) ->
      console.log "Context -> _changeConnectedHandler"

      if connected
        console.log "connect"
      else
        console.log "disconnect"
        return

      sn.__client__.models.socket.join @get("roomid"), (err, roomid) ->
        if err
          console.log err
          return


    # ------------------------------------------------------------
    _failedHandler: (err) ->
      console.log "Context -> _failedHandler"

      console.log err


  # return Instance = new Context(sn, $, _)