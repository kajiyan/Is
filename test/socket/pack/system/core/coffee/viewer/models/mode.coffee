# ============================================================
# MODE
module.exports = (sn, $, _) ->
  class Mode extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      mode: ""

    # ------------------------------------------------------------
    constructor: () ->
      console.log "MODE -> Constructor"

      # クラスの継承
      super

      @_config = SETTING.CONFIG.MODE

      @_refreshInterval = @_config.REFRESH_INTERVAL
      @_timerID = null

      # イベントリスナーの登録
      @_events()

    # ------------------------------------------------------------
    _events: ->
      console.log "MODE -> Events"

      @listenTo @, "change:mode", @_changeModeHandler

    # ------------------------------------------------------------
    toggle: ->
      console.log "MODE -> toggle"

      src = @get "mode"

      switch src
        when "layered"
          dst = "grid"
          break
        when "grid"
          dst = "layered"
          break
        else
          break

      @set "mode", dst


    # ------------------------------------------------------------
    reset: ->
      console.log "MODE -> reset"

      if @get "mode" is "layered"
        @_resetTimer()
        return
      
      @set "mode", "layered"


    # ------------------------------------------------------------
    _changeModeHandler: () ->
      console.log "MODE -> _changeModeHandler"

      @_resetTimer()


    # ------------------------------------------------------------
    _resetTimer: () ->
      console.log "MODE -> _resetTimer"

      if @_timerID
        clearTimeout @_timerID
        @_timerID = null

      @_timerID = setTimeout =>
        @toggle()
      , @_refreshInterval * 1000











