# ============================================================
# Memory
# ============================================================
module.exports = (App, sn, $, _, isElShadowRoot) ->
  debug = 
    style: "background-color: DarkGreen; color: #ffffff;"


  App.module "MemoryModule", (MemoryModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Memory] MemoryModule", debug.style

    @models = {}
    @views = {}

    # ============================================================
    # Controller

    # ============================================================
    # MODEL
    # ============================================================
    MemoryModel = Backbone.Model.extend
      # ------------------------------------------------------------
      defaults:
        url: ""
        link: ""
        window:
          width: 0
          height: 0
        landscape: ""
        positions: []
        createAt: ""



    # ============================================================
    # COLLECTION
    # ============================================================
    MemorysCollection = Backbone.Collection.extend
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Memory] MemorysCollection -> initialize", debug.style

      # --------------------------------------------------------------  
      model: MemoryModel



    # ============================================================
    # ITEM VIEW
    # ============================================================
    MemoryItemView = Backbone.Marionette.ItemView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Memory] MemoryItemView -> initialize", debug.style

        @_getTime = ->
          now = window.perfomance and (perfomance.now or perfomance.webkitNow or perfomance.mozNow or perfomance.msNow or perfomance.oNow)
          return ( now and now.cell perfomance ) or ( new Date().getTime() )

        @_frameRate = 24
        @_currentFrame = 0
        @_oldFrame = 0
        @_startTime = 0
        @_updateProcess = $.noop

        @_update =>

      # ------------------------------------------------------------
      tagName: "div"
      
      # ------------------------------------------------------------
      className: "memory"

      # ------------------------------------------------------------
      template: _.template(isElShadowRoot.querySelector("#memory-template").innerHTML)
    
      # ------------------------------------------------------------
      ui: 
        body: ".body"

      # ------------------------------------------------------------
      events:
        "click @ui.body": () -> console.log "%c[Memory] MemoryItemView -> click", debug.style

      # ------------------------------------------------------------
      _update: (process=$.noop) ->
        # console.log "%c[Memory] MemoryItemView -> _update", debug.style

        @_updateProcess = window.requestAnimationFrame =>
          @_update(process)
        ,
          @_frameRate

        @_currentFrame = Math.floor((@_getTime() - @_startTime) / (1000 / @_frameRate) % 2)
        
        if @_currentFrame isnt @_oldFrame then process()

        @_oldFrame = @_currentFrame

      # ------------------------------------------------------------
      onBeforeRender: () ->
        console.log "%c[Memory] MemoryItemView -> onBeforeRender", debug.style

      # ------------------------------------------------------------
      onDestroy: () ->
        console.log "%c[Memory] MemoryItemView -> onDestroy", debug.style



    # ============================================================
    # COLLECTION VIEW
    # ============================================================
    MemorysCollectionView = Backbone.Marionette.CollectionView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Memory] MemorysCollectionView -> initialize", debug.style
      
      # ------------------------------------------------------------
      tagName: "div"
    
      # ------------------------------------------------------------
      className: "memorys"

      # ------------------------------------------------------------
      childView: MemoryItemView

      # ------------------------------------------------------------
      childEvents: 
        onDestroy: ()->
          console.log "%c[Memory] MemorysCollectionView -> onDestroy", debug.style




    # ============================================================
    MemoryModule.addInitializer (options) ->
      console.log "%c[Memory] addInitializer", debug.style, options

      memorysCollection = new MemorysCollection([SETTING.CONFIG.MEMORY])

      memorysCollectionView = new MemorysCollectionView
        collection: memorysCollection

      App.content.currentView.memorys.show(memorysCollectionView)
      
      # ============================================================
      # COMMANDS

      # ============================================================
      # REQUEST RESPONSE

      # @models = 
      #   stage: new StageModel()

      # @views =
      #   stage: new StageItemView(
      #     model: @models.stage
      #   )

    # ============================================================
    MemoryModule.addFinalizer () ->
      console.log "%c[Memory] addFinalizer", debug.style






























