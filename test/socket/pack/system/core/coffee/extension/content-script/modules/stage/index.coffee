# ============================================================
# Stage
# 
# EVENT
#   - stageWindowScroll
#   - stageWindowResize
#   - stageInitializeUser
#   - stagePointerMove
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: Magenta; color: #ffffff;"


  App.module "StageModule", (StageModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Stage] StageModule", debug.style

    @models = {}
    @views = {}

    # ============================================================
    # Controller

    # ============================================================
    # View
    StageItemView = Backbone.Marionette.ItemView.extend(
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] StageItemView -> initialize", debug.style

        # エクステンションの起動状態に変化があった時のイベントリスナー
        App.vent.on "connectChangeIsRun", @_changeIsRunHandler.bind @
        # background scriptの socket.ioが特定のRoomへの入室が完了した時のイベントリスナー
        App.vent.on "connectJointed", @_jointedHandler.bind @
        # background scriptの socket.io がaddUser を受信した時のイベントリスナー
        # room にjoin した新規ユーザーに送信する情報を取得する
        App.vent.on "connectInitializeResident", @_initializeResidentHandler.bind @


        @model.set "window",
          width: @$el.width()
          height: @$el.height()


        @_scrollTop = @$el.scrollTop()
        # stageWindowScroll イベントを発火させる間隔
        @_scrollInterval = 100

        # Debounce Method
        # derayTime = 400
        # --------------------------------------------------------------
        # /**
        #  * StageItemView#_windowScrollDebounce
        #  * StageItemView#_windowScrollHandler 内で呼び出される
        #  * stageWindowScroll イベントを発火させる
        #  */
        # --------------------------------------------------------------
        @_windowScrollDebounce = _.debounce (e) =>
          console.log "%c[Stage] StageItemView -> _windowScrollDebounce", debug.style, e
          
          if @_scrollInterval < Math.abs(@_scrollTop - @$el.scrollTop())
            @_scrollTop = @$el.scrollTop()
            App.vent.trigger "stageWindowScroll"
        , 500

        # --------------------------------------------------------------
        # /**
        #  * StageItemView#_windowResizeDebounce
        #  * StageItemView#_windowResizeHandler 内で呼び出される
        #  * stageWindowResize イベントを発火させる
        #  */
        # --------------------------------------------------------------
        @_windowResizeDebounce = _.debounce (e) =>
          console.log "%c[Stage] StageItemView -> _windowResizeDebounce", debug.style, e

          windowSize =
            width: @$el.width()
            height: @$el.height()

          @model.set "window", windowSize
          App.vent.trigger "stageWindowResize", windowSize
        , 500

      # ------------------------------------------------------------
      el: window

      # ------------------------------------------------------------
      events: 
        scroll: "_windowScrollHandler"
        resize: "_windowResizeHandler"
        pointermove: "_pointerMoveHandler"

      # --------------------------------------------------------------
      setup: () ->
        console.log "%c[Stage] StageItemView -> setup", debug.style

        # App.vent.trigger "stageSetup",
        #   width: @$el.width()
        #   height: @$el.height()
        #   devicePixelRatio: window.devicePixelRatio


      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_windowScrollHandler
      #  * @el でwindowScroll イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - windowScroll のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _windowScrollHandler: (e) ->
        # console.log "%c[Stage] StageItemView -> _windowScrollHandler", debug.style
        @_windowScrollDebounce(e)

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_windowResizeHandler
      #  * @el でwindowResize イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - windowResize のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _windowResizeHandler: (e) ->
        # console.log "%c[Stage] StageItemView -> _windowResizeHandler", debug.style
        @_windowResizeDebounce(e)

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_pointerMoveHandler
      #  * @el でpointerMove イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - pointermove のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _pointerMoveHandler: (e) ->
        # console.log "%c[Stage] StageItemView -> _pointerMoveHandler", debug.style
        
        position =
          x: e.clientX
          y: e.clientY

        @model.set "position", position
        App.vent.trigger "stagePointerMove", position


      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_changeIsRunHandler
      #  * エクステンションの起動状態が変わった時に呼ばれるイベントハンドラー
      #  * 起動状態であればstageSetup イベントを発火させる
      #  * @param {boolean} isRun - エクステンションの起動状態
      #  */
      # --------------------------------------------------------------
      _changeIsRunHandler: (isRun) ->
        console.log "%c[Stage] StageItemView -> _changeIsRunHandler", debug.style, isRun
        
        # if isRun
          # @setup()

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_jointedHandler
      #  * background scriptの socket.ioが特定のRoomへの入室が完了した時のイベントハンドラー
      #  * lover を初期化するのに必要な値のイベントオブジェクトを持つ、
      #  * stageInitializeUser イベントを発火させる
      #  */
      # --------------------------------------------------------------
      _jointedHandler: () ->
        console.log "%c[Stage] StageItemView -> _jointedHandler", debug.style

        App.vent.trigger "stageInitializeUser",
          position: @model.get "position"
          window: @model.get "window"
      
      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_initializeResidentHandler
      #  * background scriptの socket.io がaddUser を受信した時のイベントハンドラー
      #  * room にjoin した新規ユーザーに送信するイベントオブジェクトを持つ、
      #  * stageInitializeSpace イベントを発火させる
      #  * @param {Object} data
      #  * @prop {string} toSocketId
      #  */
      # --------------------------------------------------------------
      _initializeResidentHandler: (data) ->
        console.log "%c[Stage] StageItemView -> _initializeResidentHandler", debug.style
        
        App.vent.trigger "stageInitializeResident",
          toSocketId: data.toSocketId
          position: @model.get "position"
          window: @model.get "window"
    )



    # ============================================================
    # Model
    StageModel = Backbone.Model.extend
      # /** 
      #  * @type {Object}
      #  * @prop {number} position.x - ポインター x座標
      #  * @prop {number} position.y - ポインター y座標
      #  * @prop {number} width - window の幅
      #  * @prop {number} height - window の高さ
      #  */
      defaults:
        position:
          x: 0
          y: 0
        window:
          width: 0
          height: 0

      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] StageModel -> initialize", debug.style


    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      @models = 
        stage: new StageModel()

      @views =
        stage: new StageItemView(
          model: @models.stage
        )

    # ============================================================
    StageModule.addFinalizer () ->
      console.log "%c[Stage] addFinalizer", debug.style










