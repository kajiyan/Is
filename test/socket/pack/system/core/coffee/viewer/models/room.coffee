# ============================================================
# ROOM
module.exports = (sn, $, _) ->
  class Room extends Backbone.Model
    # ------------------------------------------------------------
    constructor: () ->
      console.log "ROOM -> Constructor"

      # クラスの継承
      super

    # ------------------------------------------------------------
    initialize: () ->
      console.log "ROOM -> initialize"


    # ------------------------------------------------------------
    sync: (method, model, options) ->
      console.log "[model] ROOM -> sync method:#{method}"
      console.log method, model, options

      switch method
        when "create"
          break
        when "update"
          # localStorage.setItem('roomId', model.id);
          model.trigger("decide", model.id);
          break
        when "read"
          console.log(document.body.getAttribute("data-roomId"));
          model.set("id", document.body.getAttribute("data-roomId") || localStorage.getItem("roomId"))
          break
        when "delete"
          # localStorage.removeItem('roomId');
          break
        else
          break