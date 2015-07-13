# ============================================================
# FOOTER
module.exports = (sn, $, _) ->
  class Footer extends Backbone.View

    # ------------------------------------------------------------
    constructor: () ->
      console.log "Footer -> Constructor"

      super

    # ------------------------------------------------------------
    el: "#footer"

    # ------------------------------------------------------------
    events: 
      "click .btn-clear": "_clickClearHandler"

    # ------------------------------------------------------------
    initialize: () ->
      console.log "Footer -> initialize"
      @listenTo sn.__viewer__.models.room, 'decide', @_decideRoomHandler

    # ------------------------------------------------------------
    _clickClearHandler: () ->
      console.log "Footer -> _clickClearHandler"

      if not confirm "Clear all images ?"
        return false

      sn.__viewer__.models.trigger "clear"

		# ------------------------------------------------------------
    _decideRoomHandler: (id) ->
      console.log "Footer -> _decideRoomHandler"

      @$el
        .addClass "visible"
        .find ".footer-url-roomId"
        .text id