# ============================================================
# Stage
# 
# EVENT
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

        window.onload = () -> alert ""

        # App.vent.on "stagePointerMove", (e) -> console.log e
        # App.vent.off "stagePointerMove"

      # ------------------------------------------------------------
      el: window

      # ------------------------------------------------------------
      events:
        "scroll": "_windowScrollHandler"
        "resize": "_windowResizeHandler"
        "pointermove": "_pointerMoveHandler"


      _windowScrollHandler: (e) ->
        console.log "%c[Stage] StageItemView -> _windowScrollHandler", debug.style


      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_windowResizeHandler
      #  */
      # --------------------------------------------------------------
      _windowResizeHandler: (e) ->
        console.log "%c[Stage] StageItemView -> _windowResizeHandler", debug.style

      # --------------------------------------------------------------
      # /**
      #  * StageItemView#_pointerMoveHandler
      #  * @el でpointerMove イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - pointermoveイベントのイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _pointerMoveHandler: (e) ->
        console.log "%c[Stage] StageItemView -> _pointerMoveHandler", debug.style

        App.vent.trigger "stagePointerMove",
          "x": e.clientX
          "y": e.clientY

        # @model.set "pointerPosition",
        #   "x": e.clientX
        #   "y": e.clientY
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










