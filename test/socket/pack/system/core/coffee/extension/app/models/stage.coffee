# ============================================================
# Stage
module.exports = (sn, $, _) ->
	class Stage extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      isPopupOpen: false





    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Stage -> Constructor"
      super





    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> initialize"

      # popup の開閉状態が変わった時のイベントリスナー
      @on "change:isPopupOpen", @_changePopupOpenHandler.bind( @ )

    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[Model] Stage -> setup"
          defer.resolve()

        @_setEvent()

        onDone()
      .promise()

    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Stage -> _setEvent"





    # ------------------------------------------------------------
    # /**
    #  * @_changePopupOpenHandler
    #  */
    # ------------------------------------------------------------
    _changePopupOpenHandler: () ->
      console.log "[Model] Stage -> _changePopupOpenHandler"
      # @set "isPopupOpen", 








