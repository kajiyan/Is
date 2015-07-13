# ============================================================
# SOCKET
module.exports = (sn, $, _) ->
  class Socket extends Backbone.Model
    defaults:
      connected: false

    constructor: () ->
      console.log "SOCKET -> Constructor"

      # クラスの継承
      super

      @_setting = SETTING
      @_socket = null;


    # ------------------------------------------------------------
    initialize: () ->
      console.log "SOCKET -> initialize"


    # ------------------------------------------------------------
    connect: () ->
      console.log "SOCKET -> Connect"

      if @_socket
        return

      socket = io.connect "http://#{@_setting.HOST}:#{@_setting.PORT}/viewer"
      socket.on "connect", @_connectHandler.bind(@)
      socket.on "connecting", @_connectingHandler.bind(@)
      socket.on "connect_failed", @_connectFailedHandler.bind(@)
      socket.on "post", @_postHandler.bind(@)
      socket.on "trigger", @_triggerHandler.bind(@)
      socket.on "disconnect", @_disconnectHandler.bind(@)
      socket.on "reconnect", @_reconnectHandler.bind(@)
      socket.on "reconnect_failed", @_reconnectFailedHandler.bind(@)

      @_socket = socket


    # ------------------------------------------------------------
    join: (roomID, callback) ->
      console.log "SOCKET -> join"
      @_socket.emit "join", {id: roomID}, callback


    # ------------------------------------------------------------
    _connectHandler: () ->
      console.log "SOCKET -> _connectHandler"
      @set "connected", true


    # ------------------------------------------------------------
    _connectingHandler: () ->
      console.log "SOCKET -> _connectingHandler"


    # ------------------------------------------------------------
    _connectFailedHandler: () ->
      console.log "SOCKET -> _connectFailedHandler"

      @trigger "failed", new Error "Connection failed"


    # ------------------------------------------------------------
    _postHandler: (data) ->
      console.log "SOCKET -> _postHandler"

      @trigger "post", data


    # ------------------------------------------------------------
    _triggerHandler: (data) ->
      console.log "SOCKET -> _triggerHandler"
      console.log data

      # listen From | Collection Images
      @trigger "trigger", data.id


    # ------------------------------------------------------------
    _disconnectHandler: () ->
      console.log "SOCKET -> _disconnectHandler"

      @set "connected", false


    # ------------------------------------------------------------
    _reconnectHandler: () ->
      console.log "SOCKET -> _reconnectHandler"


    # ------------------------------------------------------------
    _reconnectFailedHandler: () ->
      console.log "SOCKET -> _reconnectFailedHandler"

      @trigger "failed", new Error "Reconnection failed"























# # ============================================================
# # SOCKET
# module.exports = class Socket extends Backbone.Model
#   # defaults:
#   #   test: false

#   constructor: (sn, $, Backbone, _) ->
#     console.log "SOCKET -> Constructor"

#     @_setting = sn.SETTING
#     @_socket = null;


#   # ------------------------------------------------------------
#   initialize: () ->
#     console.log "SOCKET - initialize"


#   # ------------------------------------------------------------
#   connect: () ->
#     console.log "SOCKET -> Connect"

#     if @_socket
#       return

#     socket = io.connect "http://#{@_setting.HOST}:#{@_setting.PORT}/viewer"
#     socket.on("connect", @_connectHandler.bind(@))
#     socket.on("connecting", @_connectingHandler.bind(@))
#     socket.on("connect_failed", @_connectFailedHandler.bind(@))
#     socket.on("post", @_postHandler.bind(@))
#     socket.on("trigger", @_triggerHandler.bind(@))
#     socket.on("disconnect", @_disconnectHandler.bind(@))
#     socket.on("reconnect", @_reconnectHandler.bind(@))
#     socket.on("reconnect_failed", @_reconnectFailedHandler.bind(@))
#     @_socket = socket


#   # ------------------------------------------------------------
#   join: () ->
#     console.log "SOCKET -> join"


#   # ------------------------------------------------------------
#   _connectHandler: () ->
#     console.log "SOCKET -> _connectHandler"

#     for a of @
#       console.log a

#     # console.log @get "test"
#     @set "test", true


#   # ------------------------------------------------------------
#   _connectingHandler: () ->
#     console.log "SOCKET -> _connectingHandler"


#   # ------------------------------------------------------------
#   _connectFailedHandler: () ->
#     console.log "SOCKET -> _connectFailedHandler"


#   # ------------------------------------------------------------
#   _postHandler: () ->
#     console.log "SOCKET -> _postHandler"


#   # ------------------------------------------------------------
#   _triggerHandler: () ->
#     console.log "SOCKET -> _triggerHandler"


#   # ------------------------------------------------------------
#   _disconnectHandler: () ->
#     console.log "SOCKET -> _disconnectHandler"


#   # ------------------------------------------------------------
#   _reconnectHandler: () ->
#     console.log "SOCKET -> _reconnectHandler"


#   # ------------------------------------------------------------
#   _reconnectFailedHandler: () ->
#     console.log "SOCKET -> _reconnectFailedHandler"





















