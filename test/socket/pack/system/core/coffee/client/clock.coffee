# ============================================================
# Clock
module.exports = ( sn ) ->
  class Clock extends TypeEvent
    constructor: () ->
      super
      
      console.log "Clock -> constructor"

      @$els = {}
      @controlEnabled = false

      @now = 0
      @monthLabel = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
      @weekLabel  = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
      @timesOfDay = "" # 整形済み時刻

      @

    setup: (skip = false) ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Clock -> setup"
          defer.resolve()

        # コントロールできる状態に
        @controlEnabled = true

        # オブジェクトを取得
        @_getElements()

        # イベント関係の設定
        @_events()


        onDone()
      .promise()

    # --------------------------------------------------------------
    update: ->
      date = new Date()

      if @now isnt date.getSeconds()
        @now = date.getSeconds()

        y = date.getFullYear()
        mon = date.getMonth()
        hours = if date.getHours() < 10 then "0" + date.getHours() else date.getHours()
        min = if date.getMinutes() < 10 then "0" + date.getMinutes() else date.getMinutes()
        s = if date.getSeconds() < 10 then "0" + date.getSeconds() else date.getSeconds()
        d = if date.getDate() < 10 then "0" + date.getDate() else date.getDate()
        w = date.getDay()

        @timesOfDay = d + " " + @monthLabel[mon] + " " +  y  + " at " + hours + ":" + min + ":" + s
        # console.log @timesOfDay 
        # h.toDate.obj.root.text('To: ' +  d + ' ' + h.toDate.state.monthLabel[mon] + ' ' +  y  + ' at ' + hours + ':' + min + ':' + s);

    # --------------------------------------------------------------
    draw: ->
      @$els.coverClock.text @timesOfDay
   
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
    windowResized: (width, height) ->

    # --------------------------------------------------------------
    animate: ->

    # --------------------------------------------------------------
    exit: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Clock -> exit"
          defer.resolve()

        # コントロールできない状態に
        @controlEnabled = false

        onDone()
      .promise()

    # --------------------------------------------------------------
    _events: () ->
      console.log "Clock -> events"


    # --------------------------------------------------------------
    _getElements: () ->
      @$els = {}

      @$els.coverClock = $("#js-cover-clock")

      return @$els

    # --------------------------------------------------------------
    animate: do ->
      result = {}
      return result


  return instance = new Clock()










