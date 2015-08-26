# ============================================================
# Stage
# 
# EVENT
#   - stageWindowScroll
#   - stageWindowResize
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

          App.vent.trigger "stageWindowResize",
            width: @$el.width()
            height: @$el.height()
        , 500

        # App.vent.on "stagePointerMove", (e) -> console.log e
        # App.vent.off "stagePointerMove"

      # ------------------------------------------------------------
      el: window

      # ------------------------------------------------------------
      events:
        "scroll": "_windowScrollHandler"
        "resize": "_windowResizeHandler"
        "pointermove": "_pointerMoveHandler"

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_windowScrollHandler
      #  * @el でwindowScroll イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - windowScroll のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _windowScrollHandler: (e) ->
        console.log "%c[Stage] StageItemView -> _windowScrollHandler", debug.style
        @_windowScrollDebounce(e)

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_windowResizeHandler
      #  * @el でwindowResize イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - windowResize のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _windowResizeHandler: (e) ->
        console.log "%c[Stage] StageItemView -> _windowResizeHandler", debug.style
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

        App.vent.trigger "stagePointerMove",
          "x": e.clientX
          "y": e.clientY
    )



    # ============================================================
    # Model
    StageModel = Backbone.Model.extend(
       # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] StageModel -> initialize", debug.style
    )



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










