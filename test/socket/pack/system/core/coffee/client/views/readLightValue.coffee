# ============================================================
# readLightValue
module.exports = (sn, $, _) ->
  class ReadLightValue extends Backbone.View
    # ------------------------------------------------------------
    constructor: () ->
      console.log "View | ReadLightValue -> Constructor"

      super
    

    # ------------------------------------------------------------
    el: "#js-read-light"


    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | ReadLightValue -> initialize"

      @model = sn.__client__.models.visual
      
      @listenTo @model, "changeLightValue", @_readLightValueHandler


    # ------------------------------------------------------------
    _readLightValueHandler: ( model ) ->
      console.log(sn.tf.valueMap);
      to = opacity: sn.tf.valueMap parseInt(@model.get("readLightValue")), 0, 255, 0, 1.0, false
      # alert @model.get "readLightValue"
      @$el.css to
      # @$el.text @model.get "readLightValue"