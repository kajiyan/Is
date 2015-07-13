# ============================================================
# IMAGE
module.exports = () ->
  class Image extends Backbone.Model
    # ------------------------------------------------------------
    defaults:
      positions:
        x: 0.5
        y: 0.5
      scale: 1.0

    # ------------------------------------------------------------
    constructor: () ->
      console.log "Image -> Constructor"

      super

    # ------------------------------------------------------------
    initialize: () ->
      console.log "Image -> initialize"