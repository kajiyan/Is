# ============================================================
# Header
module.exports = (sn) ->
  class Header extends TypeEvent
    constructor: () ->
      super
      
      console.log "Common -> Header -> constructor"

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
          console.log "Common -> Header -> setup"
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
    windowResized: ($el) ->

    # --------------------------------------------------------------
    exit: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Common -> Header -> exit"
          defer.resolve()

        # コントロールできない状態に
        @controlEnabled = false

        onDone()
      .promise()

    # --------------------------------------------------------------
    _events: () ->
      console.log "Common -> Header -> events"

    # --------------------------------------------------------------
    _getElements: () ->
      @$els = {}

      return @$els

    # --------------------------------------------------------------
    animate: do ->
      result = {}
          
      return result


  return instance = new Header()



















