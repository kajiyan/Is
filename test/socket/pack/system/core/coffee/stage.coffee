# ============================================================
# Stage
module.exports = (sn) ->
  class Stage extends TypeEvent
    constructor: () ->
      super
      
      console.log "Stage -> constructor"

      @$window = $(window)
      @$html = $("html")
      @$body = $("body")
      @$els = {}
      @controlEnabled = false

      @windowHeight = @$window.height()

      @

    setup: (skip = false) ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Stage -> setup"
          defer.resolve()

        # コントロールできる状態に
        @controlEnabled = true

        # オブジェクトを取得
        @_getElements()

        # イベント関係の設定
        @_events()

        # カーニングを設定
        # @$els.textQuantize
        #   .quantize()
        #   .then =>
        #     @$els.textQuantize.removeClass "is-invisibility"
        #     onDone()

        # windowLeft = window.screenLeft or window.screenX or 0
        # windowTop = window.screenTop or window.screenY or 0

        # alert windowLeft, windowTop

        # TweenMax.to ".historys-item", 6, 
        #   elay: 1.0
        #   ease: "Linear"
        #   repeat: 3 #アニメーションを指定した回数繰り返す。-1とすると無限に繰り返されます。
        #   x: sn.tf.random(0, 600)
        #   backgroundColor: "#0000ff"
        #   opacity: 0.3
        #   rotation: 360
        #   yoyo: true # trueとすると行って帰ってくるアニメーションになります。返ってくる動作も繰り返し回数がカウントされます。yoyoをtrueにしても、repeatが指定されていなければ動かないので注意が必要です。
        #   onComplete: -> # 処理完了後に呼ばれる関数を指定できます。
        #   onStart: -> # 処理開始前に呼ばれる関数を指定できます。
        #   onUpdate: -> # 処理実行中に呼ばれる関数を指定できます。

         # TweenMax.staggerFromTo ".historys-item"
         #  , 6
         #  , {}
         #  , 
         #    rotationX:180
         #    scaleX: 2.0
         #    z:-300
         #    transformPerspective:500
         #    delay: 1.0
         #    ease: "Linear"
         #    repeat: 3 #アニメーションを指定した回数繰り返す。-1とすると無限に繰り返されます。
         #    # x: sn.tf.random(0, 600)
         #    backgroundColor: "#0000ff"
         #    opacity: 0.3
         #    # rotation: 360
         #    yoyo: true # trueとすると行って帰ってくるアニメーションになります。返ってくる動作も繰り返し回数がカウントされます。yoyoをtrueにしても、repeatが指定されていなければ動かないので注意が必要です。
         #    onComplete: -> # 処理完了後に呼ばれる関数を指定できます。
         #    onStart: -> # 処理開始前に呼ばれる関数を指定できます。
         #    onUpdate: -> # 処理実行中に呼ばれる関数を指定できます。
         #  , 0.2

        # # コントロールできる状態に
        # @controlEnabled = true

        # ソーシャルボタン群のセットアップ
        # @_setShare()


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
    windowScroll: ( top ) ->
      # if top > (@windowHeight * 0.75)
        # @animate.fadeOut @$els.siteHeader, 200
        # alert ""
      # @windowHeight
   
    # --------------------------------------------------------------
    windowResized: (width, height) ->
      @windowHeight = height


    # --------------------------------------------------------------
    exit: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Page -> exit"
          defer.resolve()

        # コントロールできない状態に
        @controlEnabled = false

        onDone()
      .promise()

    # --------------------------------------------------------------
    _events: () ->
      console.log "Stage -> events"

      @$els.siteIndexAfford.on
        "touchstart mousedown MSPointerDown pointerdown": (e) =>
          e.preventDefault()
          @animate.indexIn @$els.siteMenu, 200

      @$els.sideMenuClose.on
        "touchstart mousedown MSPointerDown pointerdown": (e) =>
          e.preventDefault()
          @animate.indexOut @$els.siteMenu, 200

    # --------------------------------------------------------------
    # _setShare: () ->
    #   $.socialthings.twitter.applyWidgets()
    #   $.socialthings.facebook.options.locale = "ja_JP"
    #   $.socialthings.facebook.loadJS()

    # --------------------------------------------------------------
    _getElements: () ->
      @$els = {}
      
      @$els.textQuantize = $(".js-text-quantize")

      @$els.siteHeader = $("#js-site-header")

      @$els.siteIndexAfford = $(".js-site-index-afford")
      @$els.siteMenu = $("#js-side-menu")
      @$els.sideMenuClose = $("#js-side-menu-close")


      # カーニングの対象
      # @$els.textQuantize = $(".js-text-quantize")

      return @$els

    # --------------------------------------------------------------
    animate: do ->
      result =
        indexIn: ( $el, direction ) =>

          return $.Deferred (defer) =>
            onDone = =>
              defer.resolve()

            to = "opacity": 1.0
            d  = direction

            if sn.transitionEnabled
              e = "ease"
              $el
                .removeClass "is-hidden"
                .stop()
                .transition to, d, e, => onDone()
            else
              e = "swing"
              $el
                .removeClass "is-hidden"
                .stop()
                .animate to, d, e, => onDone()

          .promise()

        indexOut: ( $el, direction ) =>
          return $.Deferred (defer) =>
            onDone = =>
              $el.addClass "is-hidden"
              defer.resolve()

            to = "opacity": 0.0
            d  = direction

            if sn.transitionEnabled
              e = "ease"
              $el
                .stop()
                .transition to, d, e, => onDone()
            else
              e = "swing"
              $el
                .stop()
                .animate to, d, e, => onDone()

          .promise()

        fadeIn: ( $el, direction ) =>
          return $.Deferred (defer) =>
            onDone = =>
              defer.resolve()

            to = "opacity": 1.0
            d  = direction

            if sn.transitionEnabled
              e = "ease"
              $el
                .stop()
                .transition to, d, e, => onDone()
            else
              e = "swing"
              $el
                .stop()
                .animate to, d, e, => onDone()
          .promise()

        fadeOut: ( $el, direction ) =>
          return $.Deferred (defer) =>
            onDone = =>
              defer.resolve()

            to = "opacity": 0.0
            d  = direction

            if sn.transitionEnabled
              e = "ease"
              $el
                .stop()
                .transition to, d, e, => onDone()
            else
              e = "swing"
              $el
                .stop()
                .animate to, d, e, => onDone()
          .promise()

      return result


  return instance = new Stage()










