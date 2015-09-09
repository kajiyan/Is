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

      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Memory] MemorysModel -> initialize", debug.style



    # ============================================================
    # COLLECTION
    # ============================================================
    MemorysCollection = Backbone.Collection.extend
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Memory] MemorysCollection -> initialize", debug.style
        App.vent.on "connectReceiveMemory", @_receiveMemoryHandler.bind @

      # --------------------------------------------------------------  
      model: MemoryModel

      # --------------------------------------------------------------
      # /**
      #  * MemorysCollection#_addUserHandler
      #  * @param {[Memory]} memorys - Memory Documentの配列
      #  */
      # --------------------------------------------------------------
      _receiveMemoryHandler: (memorys) ->
        console.log "%c[Memory] MemorysCollection -> _receiveMemoryHandler", debug.style, memorys
        for memory, i in memorys
          @add memory
          # console.log memory, i
        # @add data



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

        # @_update =>
        #   positions = @model.get "positions"
        #   @ui.body.css
        #     transform: "translate(#{positions[0].x}px, #{positions[0].y}px)"
        #   # positions.shift

      # ------------------------------------------------------------
      tagName: "div"
      
      # ------------------------------------------------------------
      className: "memory"

      # ------------------------------------------------------------
      template: _.template(isElShadowRoot.querySelector("#memory-template").innerHTML)
    
      # ------------------------------------------------------------
      ui: 
        location: ".location"
        body: ".body"
        bodyImg: ".body-img"
        createAt: ".create-at"
        landscape: ".landscape"

      # ------------------------------------------------------------
      events:
        "mouseenter @ui.body": "_bodyMouseenterHandler"
        "mouseleave @ui.body": "_bodyMouseleaveHandler"

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
      # /**
      #  * MemoryItemView#_stop
      #  */
      # ------------------------------------------------------------
      _stop: () ->
        console.log "%c[Memory] MemoryItemView -> _stop", debug.style
        cancelAnimationFrame @_updateProcess

      # ------------------------------------------------------------
      onRender: () ->
        console.log "%c[Memory] MemoryItemView -> onRender", debug.style
        positions = @model.get "positions"
        landscape = @model.get "landscape"

        loadImg = () =>
          return $.Deferred (defer) =>
            images = 
              landscape: landscape

            imgNames = []
            imgSrcs = []
            for key, value of images
              imgNames.push key
              imgSrcs.push value 

            loader = new $.ImgLoader
              srcs: imgSrcs

            loader.on "allload", ($imgs) =>
              result = {}
              for $img, index in $imgs
                result[imgNames[index]] = $img

              defer.resolve result

            loader.load()
          .promise()

        setPosition = () =>
          stageWindowSize = App.reqres.request "stageGetWindowSize"
          windowSize = @model.get "window"
    
          offsetX = (stageWindowSize.width - windowSize.width) / 2
          offsetY = (stageWindowSize.height - windowSize.height) / 2

          @ui.body.css
            transform: "translate(#{positions[0].x + offsetX}px, #{positions[0].y + offsetY}px)"          

        $.when(
          loadImg()
        ).then(
          ($imgs) =>
            setPosition()
            @ui.landscape.css
              "background-image": "url(#{landscape})"
        
            return @_showBodyImg()
        ).then(
          () =>
            @_update =>
              # 最後のフレームまでアニメーションしたらrequestAnimationFrameを破棄
              if positions.length is 0
                @_stop()
                $.when(
                  @_showCreateAt() # 時刻を表示する
                ).then(
                  () =>
                    return @_hide() # 要素を非表示にする
                ).then(
                  () =>
                    @triggerMethod 'hideMemory', @model.get "id"
                )
              else
                setPosition()
                positions.shift()
        )

      # ------------------------------------------------------------
      onDestroy: () ->
        console.log "%c[Memory] MemoryItemView -> onDestroy", debug.style

      # --------------------------------------------------------------
      # /**
      #  * MemoryItemView#_hide
      #  */
      # --------------------------------------------------------------
      _hide: () ->
        console.log "%c[Memory] MemoryItemView -> _hide", debug.style
        return $.Deferred (defer) =>
          Velocity.animate @$el,
            opacity: 0.0
          ,
            duration: 500
            delay: 1000
            easing: "ease"
            complete: () =>
              @$el.addClass "is-hidden"
              defer.resolve()
        .promise()      

      # --------------------------------------------------------------
      # /**
      #  * MemoryItemView#_showBodyImg
      #  */
      # --------------------------------------------------------------
      _showBodyImg: () ->
        console.log "%c[Memory] MemoryItemView -> _showBodyImg", debug.style
        return $.Deferred (defer) =>
          Velocity.animate @ui.bodyImg,
            opacity: 1.0
          ,
            duration: 500
            delay: 0
            easing: "ease"
            complete: () =>
              defer.resolve()
        .promise()

      # --------------------------------------------------------------
      # /**
      #  * MemoryItemView#_showCreateAt
      #  */
      # --------------------------------------------------------------
      _showCreateAt: () ->
        console.log "%c[Memory] MemoryItemView -> _showCreateAt", debug.style
        return $.Deferred (defer) =>

          @ui.createAt
            .removeClass "is-hidden"

          Velocity.animate @ui.createAt,
            opacity: 1.0
          ,
            duration: 200
            delay: 0
            easing: "easeOutQuart"
            complete: () =>
              defer.resolve()
        .promise()

      # --------------------------------------------------------------
      # /**
      #  * MemoryItemView#_bodyMouseenterHandler
      #  */
      # --------------------------------------------------------------
      _bodyMouseenterHandler: () ->
        # console.log "%c[Memory] MemoryItemView -> _bodyMouseenterHandler", debug.style
     
        Velocity @ui.landscape, "stop"

        @ui.landscape
          .css
            opacity: 1.0
          .removeClass "is-hidden"

      # --------------------------------------------------------------
      # /**
      #  * MemoryItemView#_bodyMouseleaveHandler
      #  */
      # --------------------------------------------------------------
      _bodyMouseleaveHandler: () ->
        # console.log "%c[Memory] MemoryItemView -> _bodyMouseleaveHandler", debug.style

        return $.Deferred (defer) =>
          Velocity.animate @ui.landscape,
            opacity: 0.0
          ,
            duration: 400
            delay: 200
            easing: "easeOutQuart"
            complete: () =>
              try
                @ui.landscape.addClass "is-hidden"
                defer.resolve()
              catch error
                console.log error
        .promise()



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
        hideMemory: (child, id) ->
          console.log "%c[Memory] MemorysCollectionView -> hideMemory", debug.style, child, id
          @collection.remove id: id

        onDestroy: ()->
          console.log "%c[Memory] MemorysCollectionView -> onDestroy", debug.style




    # ============================================================
    MemoryModule.addInitializer (options) ->
      console.log "%c[Memory] addInitializer", debug.style, options

      createAt = sn.moment(SETTING.CONFIG.MEMORY.createAt)
      SETTING.CONFIG.MEMORY.createAt = createAt.format("DD MMMM YYYY [at] HH:mm")

      # memorysCollection = new MemorysCollection([SETTING.CONFIG.MEMORY])
      memorysCollection = new MemorysCollection()

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






























