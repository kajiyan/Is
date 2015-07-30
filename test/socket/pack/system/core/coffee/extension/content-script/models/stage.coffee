# ============================================================
# Stage
module.exports = (sn, $, _) ->
	class Stage extends Backbone.Model
    # ------------------------------------------------------------
    defaults: {}
		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "%c[Model] Stage -> Constructor", "color: #619db9"
      super

    # ------------------------------------------------------------
    initialize: () ->
      console.log "%c[Model] Stage -> initialize", "color: #619db9"

      # @listenTo sn.bb.models.stage, "change:pointerPosition", -> console.log "change:pointerPosition"

      # 選択されているタブが変更されて時変わった時
      # @on "change:selsectTabId", @_changeSelsectTabIdHandler

      # ブラウザアクションが始まった時に呼び出される
      # @on "change:isBrowserAction", @_changeBrowserActionHandler


    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "%c[Model] Stage -> setup", "color: #619db9"
          defer.resolve()

        @_setEvent()

        # for key, model of sn.bb.models
        #   @listenTo model, "popupIn", @_popupInHandler
        #   @listenTo model, "popupOut", @_popupOutHandler

        onDone()
      .promise()

    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "%c[Model] Stage -> _setEvent", "color: #619db9"

      # @listenTo sn.bb.models.stage, "change:pointerPosition", -> console.log "change:pointerPosition"












