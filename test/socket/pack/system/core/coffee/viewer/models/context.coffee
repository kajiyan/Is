# ============================================================
# CONTEXT
module.exports = (sn, $, _) ->
  class Context extends Backbone.Model

    # ------------------------------------------------------------
    constructor: () ->
      console.log "CONTEXT -> Constructor"

      # クラスの継承
      super

      # Models
      # @mode = do ->
      #   Mode = require("./mode")
      #   return new Mode(sn)
      # sn.__viewer__.models.room = do ->
      #   Room = require("./room")
      #   return new Room(sn)
      # sn.__viewer__.models.socket = do ->
      #   Socket = require("./socket")
      #   return new Socket(sn)


    # ------------------------------------------------------------
    setup: () ->
      console.log "CONTEXT -> Setup"

      # イベントリスナーの登録
      @_events()

      sn.__viewer__.models.mode.reset()
      sn.__viewer__.models.room.fetch()
      sn.__viewer__.models.socket.connect()


    # ------------------------------------------------------------
    _events: () ->
      console.log "CONTEXT -> _events"

      @listenTo sn.__viewer__.models.socket, "change:connected", @_changeConnectedHandler
      @listenTo sn.__viewer__.models.socket, "failed", @_failedHandler


    # ------------------------------------------------------------
    run: () ->
      console.log "CONTEXT -> Run"

      # sn.__viewer__.models.mode.reset()
      # sn.__viewer__.models.room.fetch()
      # sn.__viewer__.models.socket.connect()


    # ------------------------------------------------------------
    _changeConnectedHandler: (model, connected) ->
      console.log "CONTEXT -> _changeConnectedHandler"

      if connected
        console.log "connect"
      else
        console.log "disconnect"
        return

      sn.__viewer__.models.socket.join sn.__viewer__.models.room.id, ((err, roomID) ->

        if err
          console.log err
          return

        sn.__viewer__.models.room.save "id": roomID
      ).bind(@)


    # ------------------------------------------------------------
    _failedHandler: (err) ->
      console.log "CONTEXT -> FailedHandler"
      console.log err