# ============================================================
# Extention Background Stage Model
module.exports = (sn, $, _) ->
  class Stage extends Backbone.Model
    # ------------------------------------------------------------
    defaults: {}

    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Stage -> constructor"
      super


    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> Initialize"


    # ------------------------------------------------------------
    setup: () ->


    # # ------------------------------------------------------------
    # # modelにはSocket model, dataにはセットされた値が入る
    # _changeReadTextHandler: ( model, data ) ->
    #   console.log "Visual -> _changeReadTextHandler"

    #   @set "readText", data

    #   @trigger "changeText", @, data


    # # ------------------------------------------------------------
    # # modelにはSocket model, dataにはセットされた値が入る
    # _changeReadLightValueHandler: ( model, data ) ->
    #   console.log "Visual -> _changeReadLightValueHandler"

    #   @set "readLightValue", data

    #   @trigger "changeLightValue", @, data