# ============================================================
# VISUAL
module.exports = (sn, $, _) ->
  class Visual extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      readText: ""
      readLightValue: 0
    
    # ------------------------------------------------------------
    constructor: () ->
      console.log "Visual -> constructor"

      super


    # ------------------------------------------------------------
    initialize: () ->
      console.log "Visual -> Initialize"


    # ------------------------------------------------------------
    _events: () ->
      console.log "Visual -> _events"

      # 読み上げのテキストが変わったか
      @listenTo sn.__client__.models.socket, "change:readText", @_changeReadTextHandler
      # 読み上げ用照明の明るさが変わったか
      @listenTo sn.__client__.models.socket, "change:readLightValue", @_changeReadLightValueHandler


    # ------------------------------------------------------------
    setup: () ->
      console.log "Visual -> Setup"

      # イベントリスナーの登録
      @_events()

      # Web Socket 接続
      sn.__client__.models.socket.connect()


    # ------------------------------------------------------------
    # modelにはSocket model, dataにはセットされた値が入る
    _changeReadTextHandler: ( model, data ) ->
      console.log "Visual -> _changeReadTextHandler"

      @set "readText", data

      @trigger "changeText", @, data


    # ------------------------------------------------------------
    # modelにはSocket model, dataにはセットされた値が入る
    _changeReadLightValueHandler: ( model, data ) ->
      console.log "Visual -> _changeReadLightValueHandler"

      @set "readLightValue", data

      @trigger "changeLightValue", @, data