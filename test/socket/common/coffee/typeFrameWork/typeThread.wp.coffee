module.exports = (window=window, document=document, $=jQuery) ->
  require("./typeEvent.wp")(window)

  sn = $.TypeFrameWork = {}

  # ============================================================
  # typeThread
  # ============================================================
  class sn.TypeThread extends TypeEvent
    defaults:
      frameRate: 60
    #--------------------------------------------------------------
    constructor: (options) ->
      window.requestAnimationFrame = do ->
        return window.requestAnimationFrame or
          window.webkitRequestAnimationFrame or
          window.mozRequestAnimationFrame or
          window.oRequestAnimationFrame or
          window.msRequestAnimationFrame or
          (callback, fps) ->
            window.setTimeout callback, 1000 / fps
            return

      window.cancelAnimationFrame = do ->
        return window.cancelAnimationFrame or
          window.webkitCancelAnimationFrame or
          window.webkitCancelRequestAnimationFrame or
          window.mozCancelAnimationFrame or
          window.mozCancelRequestAnimationFrame or
          window.msCancelAnimationFrame or
          window.msCancelRequestAnimationFrame or
          window.oCancelAnimationFrame or
          window.oCancelRequestAnimationFrame or
          (id) ->
            window.clearTimeout id
            return
      
      window.getTime = ->
        now = window.perfomance and (perfomance.now or perfomance.webkitNow or perfomance.mozNow or perfomance.msNow or perfomance.oNow)
        return ( now and now.cell perfomance ) or ( new Date().getTime() )

      @options = $.extend {}, @defaults, options
      @updateProcess = $.noop
      @lastTime = null
      @startTime = null
      @oldFrame = null
      @stop = false
    #--------------------------------------------------------------
    setup: () ->
      @startTime = window.getTime()
    #--------------------------------------------------------------
    update: (method = $.noop) ->
      @updateProcess = window.requestAnimationFrame => @update method, @options.frameRate
 
      @lastTime = window.getTime()
 
      currentFrame = Math.floor( (@lastTime - @startTime) / (1000.0 / @options.frameRate) % 2 )
      if currentFrame isnt @oldFrame
        method()
        if @_draw?
          @_draw()
      @oldFrame = currentFrame
    #--------------------------------------------------------------
    draw: (method = $.noop) ->
      @_draw = method
      return
    #--------------------------------------------------------------
    break: () ->
      cancelAnimationFrame @updateProcess

  # ============================================================
  # bridge to plugin
  # ============================================================
  $.TypeThread = sn.TypeThread
