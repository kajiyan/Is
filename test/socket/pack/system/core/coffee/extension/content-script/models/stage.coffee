# ============================================================
# Connect
module.exports = (sn, $, _) ->
	class Connect extends Backbone.Model
    # ------------------------------------------------------------
    defaults: {}
		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Connect -> Constructor"
      super

    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Connect -> initialize"

      # @listenTo sn.bb.models.stage, "change:pointerPosition", -> console.log "change:pointerPosition"

      # 選択されているタブが変更されて時変わった時
      # @on "change:selsectTabId", @_changeSelsectTabIdHandler

      # ブラウザアクションが始まった時に呼び出される
      # @on "change:isBrowserAction", @_changeBrowserActionHandler


    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[Model] Connect -> setup"
          defer.resolve()

        @_setEvent()

        # for key, model of sn.bb.models
        #   @listenTo model, "popupIn", @_popupInHandler
        #   @listenTo model, "popupOut", @_popupOutHandler

        onDone()
      .promise()

    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Connect -> _setEvent"

      # @listenTo sn.bb.models.stage, "change:pointerPosition", -> console.log "change:pointerPosition"

      










