# ============================================================
# Stage
module.exports = (sn) ->
  class Stage extends TypeEvent
    constructor: () ->
      super
      
      console.log "Common -> Stage -> constructor"

      @$window = $(window)
      @$html = $("html")
      @$body = $("body")
      @$els = {}

      @controlEnabled = false
      @windowResizedEnabled = false

      @

    setup: (skip = false) ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Common -> Stage -> setup"
          defer.resolve()

        # コントロールできる状態に
        @controlEnabled = true

        # オブジェクトを取得
        @_getElements()

        # イベント関係のの設定
        @_events()

        onDone()
      .promise()

    # --------------------------------------------------------------
    update: ->

    # --------------------------------------------------------------
    draw: ->
   
    # --------------------------------------------------------------
    hover: ->
   
    # --------------------------------------------------------------
    keyPressed: (key) ->
   
    # --------------------------------------------------------------
    keyReleased: (key) ->
   
    # --------------------------------------------------------------
    click: ->
   
    # --------------------------------------------------------------
    pointerDown: ->

    # --------------------------------------------------------------
    pointerEnter: ->

    # --------------------------------------------------------------
    pointerLeave: ->

    # --------------------------------------------------------------
    pointerMoved: ->

    # --------------------------------------------------------------
    pointerOut: ->

    # --------------------------------------------------------------
    pointerOver: ->

    # --------------------------------------------------------------
    pointerUp: ->
    
    # --------------------------------------------------------------
    windowScroll: (top) ->
   
    # --------------------------------------------------------------
    setWindowResizedEnabled: (bool) ->
      @windowResizedEnabled = bool

    # --------------------------------------------------------------
    getWindowResizedEnabled: ->
      return @windowResizedEnabled

    # --------------------------------------------------------------
    windowResized: ($el) ->
      if @windowResizedEnabled
        unless $el?
          # エレメントが設定されていなければ
          $el = @$html

        return $.Deferred (defer) =>
          onDone = =>
            console.log "Common -> Stage -> windowResized"
            defer.resolve()

          if @$body.width() > SETTING.CONSTANT.BASE_WIDTH
            fontSize = "62.5%"
          else
            fontSize = (@$body.width() / SETTING.CONSTANT.BASE_WIDTH * 62.5) + "%"
            
          $el.css "fontSize": fontSize

          onDone()
        .promise()

    # --------------------------------------------------------------
    exit: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Common -> Stage -> exit"
          defer.resolve()

        # コントロールできない状態に
        @controlEnabled = false

        onDone()
      .promise()

    # --------------------------------------------------------------
    _events: () ->
      console.log "Common -> Stage -> events"

    # --------------------------------------------------------------
    _getElements: () ->
      @$els = {}

      return @$els

    # --------------------------------------------------------------
    animate: do ->
      result = {}
      return result

  return instance = new Stage()



















