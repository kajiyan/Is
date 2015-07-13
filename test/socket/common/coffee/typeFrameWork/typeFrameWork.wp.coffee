module.exports = (window=window, document=document, $=jQuery) ->
  # ============================================================
  # IMPORT MODULE
  # ============================================================
  require("./typeImport.wp")(window, document, $)

  $window   = $(window)
  $document = $(document)

  sn = $.TypeFrameWork = {}
  
  # ------------------------------------------------------------
  # detect / normalize event names
  sn.support = {}
  sn.ua      = {}

  sn.support.addEventListener = "addEventListener" of document
  sn.support.toucheEvent = "ontouchend" of document


  # ------------------------------------------------------------
  # CONSTANT
  # ------------------------------------------------------------
  FLT_EPSILON = 0.0000001192092896
  
  KEY_CHARS     = []
  KEY_CHARS[27] = "Esc"
  KEY_CHARS[8]  = "BackSpace"
  KEY_CHARS[9]  = "Tab"
  KEY_CHARS[32] = "Space"
  KEY_CHARS[45] = "Insert"
  KEY_CHARS[46] = "Delete"
  KEY_CHARS[35] = "End"
  KEY_CHARS[36] = "Home"
  KEY_CHARS[33] = "PageUp"
  KEY_CHARS[34] = "PageDown"
  KEY_CHARS[38] = "up"
  KEY_CHARS[40] = "down"
  KEY_CHARS[37] = "left"
  KEY_CHARS[39] = "right"
 
  # ============================================================
  # typeFrameWork
  # ============================================================
  class sn.TypeFrameWork extends TypeEvent    
    defaults:
      frameRate: 60.0
      resizeInterval: 200
 
    #--------------------------------------------------------------
    constructor: (options) ->
      @options = $.extend {}, @defaults, options

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

      @updateProcess = null
      @oldFrame = null
      @startTime = window.getTime()

      @els = []

      @_keyPressed = ->
      @_keyReleased = ->
      @_windowResized = ->
      @_windowScroll = ->
      @_orientationChange = $.noop
      @_fullScreenChange = ->

      $document.on "keydown", @keyPressedProcess
      $document.on "keyup", @keyReleasedProcess

      # resize event timer
      @resizeTimer = null;
      $window.on "resize", @windowResizedProcess

      # window scroll event
      $window.on "scroll", @windowScrollProcess

      # randscape change event
      if typeof window.onorientationchange is "object"
        $window.on "orientationchange", @orientationChangeProcess

      # fullscreen change event
      $window.on "fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenchange", @fullScreenChangeProcess

      if sn.support.addEventListener
        window.addEventListener "devicemotion", @devicemotionProcess


    #--------------------------------------------------------------
    setup: (method = ->) ->
      method()
      return


    #--------------------------------------------------------------
    update: (method = ->) ->
      @lastTime = window.getTime()

      currentFrame = Math.floor( (@lastTime-@startTime) / (1000.0/@options.frameRate) % 2 )

      if currentFrame isnt @oldFrame
        method()
        if @_draw?
          @_draw()

      @oldFrame = currentFrame

      @updateProcess = window.requestAnimationFrame( => @update method, @options.frameRate )

      return

    #--------------------------------------------------------------
    draw: (method = ->) ->
      @_draw = method
      return


    #--------------------------------------------------------------
    keyPressed: (method = $.noop) ->
      @_keyPressed = method
      return

    keyPressedProcess: (e) =>
      key = @_keyProcess(e)
      @_keyPressed key
      return

    keyPressedOn: () ->
      $document.on "keydown", @keyPressedProcess
      return

    keyPressedOff: () ->
      $document.off "keydown"
      return


    #--------------------------------------------------------------
    keyReleased: (method = $.noop) ->
      @_keyReleased = method
      return

    keyReleasedProcess: (e) =>
      key = @_keyProcess(e)
      @_keyReleased key
      return

    keyReleasedOn: () ->
      $document.on "keyup", @keyReleasedProcess
      return

    keyReleasedOff: () ->
      $document.off "keyup"
      return

    #--------------------------------------------------------------
    _keyProcess: (e) =>
      if e isnt null
        keyCode = e.which
        ctrl = if(typeof e.modifiers is 'undefined') then e.ctrlKey else e.modifiers & Event.CONTROL_MASK
        shift = if(typeof e.modifiers is 'undefined') then e.shiftKey else e.modifiers & Event.SHIFT_MASK
        # e.preventDefault()
        # e.stopPropagation()
      else
        keyCode = event.keyCode
        ctrl = event.ctrlKey
        shift = event.shiftKey
        event.returnValue = false
        event.cancelBubble = true

      keyChar = KEY_CHARS[keyCode]

      if !(keyChar?)
        keyChar = String.fromCharCode(keyCode).toUpperCase()

      result =
        "keyCode": keyCode
        "keyChar": keyChar
        "ctrl": ctrl
        "shift": shift

      return result
 
    #--------------------------------------------------------------
    hover: (method = ->) ->
      method.apply()
      return
 
 
    #--------------------------------------------------------------
    setHover: (el, enter, leave) ->
      if not el?
        $.error("Some error TypeFrameWorksetHover() object.");

      if not enter?
        enter = ->

      if not leave?
        leave = ->

      if @type(enter) isnt "function" and @type(leave) isnt "function"
        $.error("Some error TypeFrameWork hover() object.");

      # イベントを定義するオブジェクトを格納
      @els.push el
      el.on
        "mouseenter": (e) -> enter(e, this)
        "mouseleave": (e) -> leave(e, this)

      return
 
    #--------------------------------------------------------------
    _pointXY: (e, options) ->
      defaults =
        translate: "page"
      
      options = $.extend {}, defaults, options

      original = e.originalEvent

      if original.changedTouches
        _x = (0.5 + original.changedTouches[0]["#{options.translate}X"]) << 0
        _y = (0.5 + original.changedTouches[0]["#{options.translate}Y"]) << 0
      else
        _x = e["#{options.translate}X"] or original["#{options.translate}X"]
        _y = e["#{options.translate}Y"] or original["#{options.translate}Y"]

      pointData =
        x: _x
        y: _y
      return pointData

    _onPointerStyle: ($el) ->
      if sn.support.toucheEvent
        $el.css
          "-ms-touch-action" : "none"
          "touch-action"     : "none"

    _offPointerStyle: ($el) ->
      if sn.support.toucheEvent
        $el.css
          "-ms-touch-action" : ""
          "touch-action"     : ""


    #--------------------------------------------------------------
    pointerDown: (method = ->) ->
      method()
      return

    onPointerDown: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork pointerDown() object.")

      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork pointerDown() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "touchstart mousedown MSPointerDown pointerdown": (e) =>
          e.preventDefault()
          pointData = @_pointXY(e)
          options.method pointData
      return

    offPointerDown: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerDown() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "touchstart mousedown MSPointerDown pointerdown"


    #--------------------------------------------------------------
    pointerEnter: (method = ->) ->
      method()
      return

    onPointerEnter: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointerEnter() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerEnter() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mouseenter touchenter MSPointerEnter pointerenter": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerEnter: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerEnter() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mouseenter touchenter MSPointerEnter pointerenter"


    #--------------------------------------------------------------
    pointerLeave: (method = ->) ->
      method()
      return

    onPointerLeave: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointereLeave() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointereLeave() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mouseleave touchleave MSPointeLeave pointeLeave": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerLeave: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointereRleave() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mouseleave touchleave MSPointeRleave pointerleave"


    #--------------------------------------------------------------
    pointerMoved: (method = ->) ->
      method()
      return

    onPointerMoved: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointerMoved() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mousemove touchmove MSPointerMove pointermove": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerMoved: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mousemove touchmove MSPointerMove pointemove"


    #--------------------------------------------------------------
    pointerOut: (method = ->) ->
      method()
      return

    onPointerOut: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointerMoved() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mouseout pointerout": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerOut: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mouseout pointerout"


    #--------------------------------------------------------------
    pointerOver: (method = ->) ->
      method()
      return

    onPointerOver: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointerMoved() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mouseover MSPointerOver pointerover": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerOver: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mouseover MSPointerOver pointerover"


    #--------------------------------------------------------------
    pointerUp: (method = ->) ->
      method()
      return

    onPointerUp: (options) ->
      defaults =
        $el: null
        method: null
        translate: "page"
      options = $.extend {}, defaults, options

      if not options.$el? and not options.method?
        $.error("Some error TypeFrameWork PointerMoved() object.")
 
      if @type(options.$el) isnt "object" and
        @type(options.method) isnt "function" and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @els.push options.$el

      @_onPointerStyle(options.$el)
      options.$el.on
        "mouseup touchend touchcancel MSPointerUp pointerup MSPointerCancel pointercancel": (e) =>
          pointData = @_pointXY e, translate: options.translate
          options.method(pointData)
      return

    offPointerUp: (options) ->
      defaults =
        $el: null
      options = $.extend {}, defaults, options

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerMoved() object.")

      @_offPointerStyle(options.$el)
      options.$el.off "mouseup touchend touchcancel MSPointerUp MSPointerCancel pointercancel"


    #--------------------------------------------------------------
    pointerWheel: (method = ->) ->
      @_pointerWheel = method
      return

    onPointerWheel: (options) ->
      defaults =
        $el: null
        method: () ->
      options = $.extend {}, defaults, options

      if "onwheel" of document
        eventName = "wheel"
      else if "onmousewheel" of document
        eventName = "mousewheel"
      else
        eventName = "DOMMouseScroll"

      if not options.$el? and
        options.$el.jquery.length isnt 0
          $.error("Some error TypeFrameWork PointerWheel() object.")

      options.$el.on eventName, (e) =>
        delta = 0

        if e.originalEvent.deltaY
          delta = -(e.originalEvent.deltaY)
        else if e.originalEvent.wheelDelta
          delta = e.originalEvent.wheelDelta
        else
          delta = -(e.originalEvent.detail)

        if delta < 0
          e.preventDefault()
          result =
            "direction": "down"
            "delta": delta
          options.method(result)
        else if delta > 0
          e.preventDefault()
          result =
            "direction": "up"
            "delta": delta
          options.method(result)


    #--------------------------------------------------------------
    click: (method = ->) ->
      method()
      return

    setClick: (el, method) ->
      if not el? and not method?
        $.error("Some error TypeFrameWork mousePressed() object.");

      if @type(el) isnt "object" and @type(method) isnt "function"
        $.error("Some error TypeFrameWork mousePressed() object.");

      @els.push el
      el.on
        "click": (e) -> method(e, this)
 
      return
 
 
    #--------------------------------------------------------------
    windowResized: (method) ->
      @_windowResized = method
      return
 
    windowResizedProcess: =>
      clearTimeout(@resizeTimer)
 
      @resizeTimer = setTimeout =>
        w = $window.width()
        h = $window.height()
        @_windowResized w, h
      , @options.resizeInterval
      return
 
    #--------------------------------------------------------------
    windowScroll: (method) ->
      @_windowScroll = method
      return
 
    windowScrollProcess: =>
      top = $window.scrollTop()
      @_windowScroll top
      return
 
    #--------------------------------------------------------------
    _checkLandScape: ->
      userAgent = navigator.userAgent
      if window.orientation? and
        userAgent.indexOf("iPhone") isnt -1 or
        userAgent.indexOf("iPad") isnt -1 or
        userAgent.indexOf("iPod") isnt -1 or
        userAgent.indexOf("Android") isnt -1
          orientation = window.orientation
          if orientation is 0
            return "portrait"
          else
            return "landscape"
      else
        return false
 
    orientationChange: (method = $.noop) ->
      @_orientationChange = method
      return
 
    orientationChangeProcess: =>
      @_orientationChange @_checkLandScape()
      return
 
 
    #--------------------------------------------------------------
    exit: (callback) ->
      $window.off()
 
      for els in @els
        els.off()
 
      if @updateProcess?
        cancelAnimationFrame @updateProcess
        @updateProcess = false
 
      if @type(callback) is "function"
        callback()
      else
        $.error "Some error TypeFrameWork exit() callback function."
 
      return null
 
 
    #--------------------------------------------------------------
    fullScreen: (support = false, el = document) ->
      if not support
        if (el.fullScreenElement and el.fullScreenElement not null) or (!el.mozFullScreen and !el.webkitIsFullScreen)
          if el.documentElement.requestFullScreen
            el.documentElement.requestFullScreen()
          else if el.documentElement.webkitRequestFullScreen
            el.documentElement.webkitRequestFullScreen()
          else if el.documentElement.mozRequestFullScreen
            el.documentElement.mozRequestFullScreen()
          else if el.msRequestFullscreen
            el.msRequestFullscreen()
          else
            return false
 
        return true
      else
        if el.requestFullscreen or el.webkitRequestFullscreen or el.mozRequestFullScreen or el.msRequestFullscreen
          return true
        else
          return false
 
 
    #--------------------------------------------------------------
    exitFullScreen: (el = document) ->
      if el.exitFullscreen
        el.exitFullscreen()
      else if el.webkitCancelFullScreen
        el.webkitCancelFullScreen()
      else if el.mozCancelFullScreen
        el.mozCancelFullScreen()
      else if el.msExitFullscreen
        el.msExitFullscreen()
      else if el.cancelFullScreen
        el.cancelFullScreen()
      else
        return false
 
      return true
 
 
    #--------------------------------------------------------------
    isFullScreen: (el = document) ->
      if el.fullscreen or el.webkitIsFullScreen or el.mozFullScreen or el.msFullScreen
        return true
      else
        return false
 
 
    #--------------------------------------------------------------
    fullScreenChange: (method = ->) ->
      @_fullScreenChange = method
      return
 
    fullScreenChangeProcess: =>
      @_fullScreenChange @isFullScreen()
      return
 
 
    #--------------------------------------------------------------
    devicemotionProcess: (e) =>
      e.preventDefault()
 
      acceleration = e.acceleration
      accelerationIncludingGravity = e.accelerationIncludingGravity
      rotationRate = e.rotationRate
 
      @accelerationX = acceleration.x
      @accelerationY = acceleration.y
      @accelerationZ = acceleration.z
 
      @gravityX = accelerationIncludingGravity.x
      @gravityY = accelerationIncludingGravity.y
      @gravityZ = accelerationIncludingGravity.z
 
      @rotationA = rotationRate.alpha
      @rotationB = rotationRate.beta
      @rotationG = rotationRate.gamma
      return
 
    #--------------------------------------------------------------
    type: (obj) ->
      if obj == undefined or obj == null
        return String obj
      classToType = {
        '[object Boolean]': 'boolean',
        '[object Number]': 'number',
        '[object String]': 'string',
        '[object Function]': 'function',
        '[object Array]': 'array',
        '[object Date]': 'date',
        '[object RegExp]': 'regexp',
        '[object Object]': 'object'
      }
      return classToType[Object.prototype.toString.call(obj)]
 
 
    #--------------------------------------------------------------
    # Math Helper
    #--------------------------------------------------------------
    vec2f: (x, y) ->
      return new sn.vec2f(x, y)
 
    random: (args...) ->
      len = args.length
 
      if len is 0
        num = Math.random()
      else if len is 1
        num = Math.floor( Math.random() * (args[0] + 1) )
      else if len is 2
        num = Math.floor( Math.random() * (args[1] + 1) )
      else
        $.error("Some error TypeFrameWork random() object.");
 
      return num
 
    valueMap: (value, inputMin, inputMax, outputMin, outputMax, clamp) ->
      FLT_EPSILON = 0.0000001192092896
 
      if Math.abs(inputMin - inputMax) < FLT_EPSILON
        $.error "valueMap avoiding possible divide by zero, check inputMin and inputMax: #{inputMin} #{inputMax}"
        return outputMin
      else
        outVal = ((value - inputMin) / (inputMax - inputMin) * (outputMax - outputMin) + outputMin)
 
        if clamp is true
          if outputMax < outputMin
            if outVal < outputMax
              outVal = outputMax
            else if outVal > outputMin
              outVal = outputMin
          else
            if outVal > outputMax
              outVal = outputMax
            else if outVal < outputMin
              outVal = outputMin
 
        return outVal
 
    #--------------------------------------------------------------
    # Path Helper
    #--------------------------------------------------------------
    setPath: (options) ->
      defaults =
        host:           window.location.href
        asset_dir:      "assets"
        css_dir:        "css"
        script_dir:     "script"
        image_dir:      "images"
        fonts_dir:      "fonts"
        pc_dir:         "pc"
        tablet_dir:     "tablet"
        sp_dir:         "sp"
        relative:       "relative"
        deviceIsParent: true
        strictSlash:    false
        root:           null
 
      @_path = $.extend {}, defaults, options
      return
 
    get_host_path: ->
      return @_path.host
 
    get_css_path: (rule, device) ->
      if rule is @_path.relative
        func = @_get_relative_path
       else
        func = @_get_root_path
      return func @_path.css_dir, device
 
    get_script_path: (rule, device) ->
      if rule is @_path.relative
        func = @_get_relative_path
       else
        func = @_get_root_path
      return func @_path.script_dir, device
 
    get_image_path: (rule, device) ->
      if rule is @_path.relative
        func = @_get_relative_path
       else
        func = @_get_root_path
      return func @_path.image_dir, device
 
    get_fonts_path: (rule, device) ->
      if rule is @_path.relative
        func = @_get_relative_path
       else
        func = @_get_root_path
      return func @_path.fonts_dir, device
 
    _get_relative_path: (asset, device) =>
      fragment = window.location.pathname
      if @_path.root?
        fragment = fragment.replace(@_path.root, "")
 
      level = fragment.split('/').length - 1
      result = @_get_path asset, device
 
      i = 0
 
      while i < level
        result = "../" + result
        i++
 
      if asset.strictSlash
        result + "/"
 
      result
 
    _get_root_path: (asset, device) =>
      result = "/" + @_get_path asset, device
      if asset.strictSlash
        result + "/"
 
      result
 
    _get_path: (asset, device) ->
      targetDev = ""
      targetAsset = ""
      switch device
        when @_path.pc_dir then targetDev = @_path.pc_dir
        when @_path.tablet_dir then targetDev = @_path.tablet_dir
        when @_path.sp_dir then targetDev = @_path.sp_dir
        else targetDev = ""
 
      switch asset
        when @_path.css_dir then targetAsset = @_path.css_dir;
        when @_path.image_dir then targetAsset = @_path.image_dir;
        when @_path.script_dir then targetAsset = @_path.script_dir;
        when @_path.data_dir then targetAsset = asset.data_DIR;
        else throw new Error('asset type fail');
 
      if targetDev? and targetDev isnt ""
        if @_path.asset_dir is ""
          result = if @_path.deviceIsParent then [targetDev, targetAsset] else [targetAsset, targetDev]
        else
          result = if @_path.deviceIsParent then [@_path.asset_dir, targetDev, targetAsset] else [@_path.asset_dir, targetAsset, targetDev]
      else
        if @_path.asset_dir is ""
          result = [targetAsset]
        else
          result = [@_path.asset_dir, targetAsset]
 
      result = result.join("/")
      return result 
    #--------------------------------------------------------------
    # END Path Helper
    #--------------------------------------------------------------
    getFrameRate: () ->
      return @options.frameRate
 
    getResizeInterval: () ->
      return @options.resizeInterval
 
    getWindowWidth: () ->
      return $window.width()
 
    getWindowHeight: () ->
      return $window.height()
 
    getLandscape: () ->
      return @_checkLandScape()
    
    getElPx: ($el, propety) ->
      l = $el.css propety
      if l is "auto"
        l = 0
      else
        l = (l.replace /px/, '') * 1
      return l

    getLocation: (options) ->
      defaults =
        success: () ->
        error: () ->
        complete: () ->
      options = $.extend {}, defaults, options

      return $.Deferred (defer) =>
        if sn.support.geolocation
          startTime = new Date()
          watchID = navigator.geolocation.watchPosition (e) =>
            currentTime = new Date()

            diifTime = currentTime - startTime

            # 一定値以上の精度もしくは一定の時間を超えたら経度緯度を引数に関数を呼ぶ
            if e.coords.accuracy < 300 or diifTime > 5000
              navigator.geolocation.clearWatch(watchID)

              options.success(e.coords)
              defer.resolve(e.coords)
          , (error) =>
            options.error(error)
        else
          options.error()
          defer.reject()
      .promise().always( ->
        options.complete()
      )

    getBrowser: () ->
      result = {}
      dataBrowser = [
        { string: navigator.userAgent, subString: "Chrome",  identity: "Chrome" }
        { string: navigator.userAgent, subString: "MSIE",    identity: "Explorer" }
        { string: navigator.userAgent, subString: "Firefox", identity: "Firefox" }
        { string: navigator.userAgent, subString: "Safari",  identity: "Safari" }
        { string: navigator.userAgent, subString: "Opera",   identity: "Opera" }
      ]

      for i in [0...dataBrowser.length]
        dataString = dataBrowser[i].string
        versionSearchString = dataBrowser[i].subString

        if dataString.indexOf(dataBrowser[i].subString) isnt -1
          result.browser = dataBrowser[i].identity
          break
        else
          result.browser = "Other"

      index = dataString.indexOf(versionSearchString)
      if index is -1
        result.version = "Unknown"
      else
        result.version = parseFloat(dataString.substring(index + versionSearchString.length + 1))

      return result 
    #--------------------------------------------------------------
    # Cast Helper
    #--------------------------------------------------------------
    toRGB: (H, S, B) ->
      if S is 0
        _r = B * 255
        _g = B * 255
        _b = B * 255
      else
        h = if (H >= 0) then (H % 360 / 360) else (H % 360 / 360 + 1)
        _h = h * 6
        i = parseInt(_h)
        f = _h - i

        p = B * (1 - S)
        q = B * (1 - S * f)
        t = B * (1 - S * (1 - f))

        switch i
          when 0
            _r = B
            _g = t
            _b = p
          when 1
            _r = q
            _g = B
            _b = p
          when 2
            _r = p
            _g = B
            _b = t
          when 3
            _r = p
            _g = q
            _b = B
          when 4
            _r = t
            _g = p
            _b = B
          else
            _r = B
            _g = p
            _b = q

        _r = _r * 255
        _g = _g * 255
        _b = _b * 255
      rgb = 
        "R": _r
        "G": _g
        "B": _b
      return rgb

    toHSB: (R, G, B) ->
      r = R / 255
      g = G / 255
      b = B / 255
      max = Math.max(r, g, b)
      min = Math.min(r, g, b)
      brightness = max

      if max is min
        hue = 0
      else if r is max
        hue = 60 * ((g - b) / (max - min)) + 0
      else if g is max
        hue = 60 * ((b - r) / (max - min)) + 120
      else
        hue = 60 * ((r - g) / (max - min)) + 240

      if hue < 0 then hue = hue + 360

      saturation = if (brightness isnt 0) then ((max - min) / max) else 0

      hsv = 
        "H": hue
        "S": saturation
        "B": brightness
      return hsv
    #--------------------------------------------------------------
    # CSS Animate Helper
    #--------------------------------------------------------------
    cssTransition: (duration, easing) ->
      css = "#{duration}s #{easing}"
      return {
        "-webkit-transition" : css
        "-moz-transition"    : css
        "-o-transition"      : css
        "-ms-transition"     : css
        "transition"         : css
      }
 
    transitionProperty: (property = ["all"]) ->
      value = property.join(", ") 
      return {
        "-webkit-transition-property": "#{value}"
        "-moz-transition-property"   : "#{value}"
        "-o-transition-property"     : "#{value}"
        "-ms-transition"             : "#{value}"
        "transition-property"        : "#{value}"
      }
 
    transitionDuration: (duration) ->
      return {
        "-webkit-transition-duration" : "#{duration}s"
        "-moz-transition-duration"    : "#{duration}s"
        "-o-transition-duration"      : "#{duration}s"
        "-ms-transition-duration"     : "#{duration}s"
        "transition-duration"         : "#{duration}s"
      }
 
    transitionTimingFunction: (property) ->
      return {
        "-webkit-transition-timing-function" : "#{property}"
        "-moz-transition-timing-function"    : "#{property}"
        "-o-transition-timing-function"      : "#{property}"
        "-ms-transition-timing-function"     : "#{property}"
        "transition-timing-function"         : "#{property}"
      }
 
    transitionDelay: (delay) ->
      return {
        "-webkit-transition-delay" : "#{delay}s"
        "-moz-transition-delay"    : "#{delay}s"
        "-o-transition-delay"      : "#{delay}s"
        "-ms-transition-delay"     : "#{delay}s"
        "transition-delay"         : "#{delay}s"
      }
 
    cssScale: (scale) ->
      css3 = "scale(#{scale})"
      return {
        "-webkit-transform" : css3
        "-moz-transform"    : css3
        "-o-transform"      : css3
        "-ms-transform"     : css3
        "transform"         : css3
      }
 
    cssTranslate: (x,y,z) ->
      css3 = "translateX(#{x}px) translateY(#{y}px) translateZ(#{z}px)"
      return {
        "-webkit-transform" : css3
        "-moz-transform"    : css3
        "-o-transform"      : css3
        "-ms-transform"     : css3
        "transform"         : css3
      }
 
    cssRotation: (rx,ry,z) ->
      css3 = "translateZ(#{z}px) rotateX(#{rx}deg) rotateY(#{ry}deg)"
      return {
        "-webkit-transform" : css3
        "-moz-transform"    : css3
        "-o-transform"      : css3
        "-ms-transform"     : css3
        "transform"         : css3
      }
 
    css3DSet: (perspective,originX,originY) ->
      perspective = "#{perspective}px"
      style = "preserve-3d"
      orign = "#{originX} #{originY}"
      css = {
        "-webkit-perspective"   : perspective, 
        "-moz-perspective"      : perspective,
        "-o-perspective"        : perspective,
        "-ms-perspective"       : perspective,
        "perspective"           : perspective,
 
        "-webkit-transform-style"   : style,
        "-moz-transform-style"      : style,
        "-o-transform-style"        : style,
        "-ms-transform-style"       : style,
        "transform-style"           : style,
 
        "-webkit-perspective-origin"    : orign,
        "-moz-perspective-origin"       : orign,
        "-o-perspective-origin"         : orign,
        "-ms-perspective-origin"        : orign,
        "-transform-perspective-origin" : orign
      }
      return css
 
    css3PerspectiveOrigin: (originX,originY) ->
      orign = "#{originX} #{originY}"
      return  {
        "-webkit-perspective-origin"    : orign
        "-moz-perspective-origin"       : orign
        "-o-perspective-origin"         : orign
        "-ms-perspective-origin"        : orign
        "-transform-perspective-origin" : orign
      }
 
    cssTransformOrig: (x,y) ->
      css3 = "#{x} #{y}"
      return {
        "-webkit-transform-origin" : css3
        "-moz-transform-origin"    : css3
        "-o-transform-origin"      : css3
        "-ms-transform-origin"     : css3
        "transform-origin"         : css3
      }
 
  # ============================================================
  # bridge to plugin
  # ============================================================
  window.TypeFrameWork = $.TypeFrameWork = sn.TypeFrameWork
