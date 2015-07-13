# ============================================================
# DeviceSensor
module.exports = (sn, $, _) ->
	class DeviceSensor extends Backbone.Model

		# ------------------------------------------------------------
    constructor: () ->
      console.log "DeviceSensor -> Constructor"

      super

		# ------------------------------------------------------------
    initialize: () ->
      console.log "DeviceSensor -> initialize"


    # ------------------------------------------------------------
    setup: () ->
      console.log "DeviceSensor -> Setup"

      @_events()


    # ------------------------------------------------------------
    _events: () ->
      console.log "DeviceSensor -> _events"

      # 画像が選択されたときのイベントリスナー
      @listenTo sn.__client__.models.image, "select", @_selectHandler
      @listenTo sn.__client__.models.image, "post", @_postHandler
      
      @listenTo sn.__client__.models.devicemotion, "devicemotion", @_devicemotionHandler


    # ------------------------------------------------------------
    _selectHandler: () ->
      console.log "DeviceSensor -> _selectHandler"

      sn.__client__.models.devicemotion.start()


    # ------------------------------------------------------------
    _postHandler: () ->
      console.log "DeviceSensor -> _postHandler"

      sn.__client__.models.devicemotion.set "throwable", true


    # ------------------------------------------------------------
    _devicemotionHandler: () ->
      console.log "DeviceSensor -> _devicemotionHandler"

      setTimeout =>
        # listenFrom Image View
        @trigger "throw", @
      , 200