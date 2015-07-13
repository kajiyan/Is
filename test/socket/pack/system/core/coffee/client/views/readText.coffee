# ============================================================
# readText
module.exports = (sn, $, _) ->
  class ReadText extends Backbone.View
    # ------------------------------------------------------------
    constructor: () ->
      console.log "View | ReadText -> Constructor"

      super
    

    # ------------------------------------------------------------
    el: "#js-read-text"


    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | ReadText -> initialize"

      @model = sn.__client__.models.visual
      
      @listenTo @model, "changeText", @_readTextHandler


    # ------------------------------------------------------------
    _readTextHandler: ( model ) ->
      @$el.text @model.get "readText"