# ============================================================
# Stage
# 
# EVENT
#   - stageWindowScroll
#   - stageWindowResize
#   - stageInitializeUser
#   - stagePointerMove
#   - stageAddMemory
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
    # Model
    # SoundModel = Backbone.Model.extend
    #   # ------------------------------------------------------------
    #   initialize: () ->
    #     console.log "%c[Stage] SoundModel -> initialize", debug.style


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

        # エクステンションの起動状態に変化があった時のイベントリスナー
        App.vent.on "connectChangeIsRun", @_changeIsRunHandler.bind @
        # サーバーでMemoryの追加処理が終了した時に呼び出される
        App.vent.on "connectAddedMemory", @_addedMemoryHandler.bind @

        @_isMemoryProcessed = true

        @_getTime = ->
          now = window.perfomance and (perfomance.now or perfomance.webkitNow or perfomance.mozNow or perfomance.msNow or perfomance.oNow)
          return ( now and now.cell perfomance ) or ( new Date().getTime() )

        @_frameRate = SETTING.CONFIG.FRAME_RATE

        @_recInterval = @_frameRate * (SETTING.CONFIG.REC_INTERVAL / 1000)
        
        @_memoryGetInterval = @_frameRate * (SETTING.CONFIG.MEMORY_GET_INTERVAL / 1000)
        @_memoryGetMaxLimit = 2
        
        @_updateProcess = $.noop
        @_startTime = 0
        @_oldFrame = 0
        @_currentFrame = 0

        @_recordingTime = 6000

        @_positionsSize = @_recordingTime / 1000 * @_frameRate
        # 最短の録画時間 (2000ms)
        @_positionsSelectOffset = 2000 / 1000 * @_frameRate

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_update
      #  */
      # ------------------------------------------------------------
      _update: (process=$.noop) ->
        # console.log "%c[Stage] StageModel -> _update", debug.style

        @_updateProcess = window.requestAnimationFrame =>
          @_update(process)
        ,
          @_frameRate

        @_currentFrame = Math.floor((@_getTime() - @_startTime) / (1000 / @_frameRate) % 2)
        
        if @_currentFrame isnt @_oldFrame then process()

        @_oldFrame = @_currentFrame

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_stop
      #  */
      # ------------------------------------------------------------
      _stop: () ->
        console.log "%c[Stage] StageModel -> _stop", debug.style
        cancelAnimationFrame @_updateProcess

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeIsRunHandler
      #  */
      # ------------------------------------------------------------
      _changeIsRunHandler: (isRun) ->
        # console.log "%c[Stage] StageModel -> _changeIsRunHandler", debug.style, isRun

        if isRun
          @_startTime = @_getTime()

          position = @get "position"

          @_positions = ((size) ->
            result = new Array(size)
            for i in [0...size]
              result[i] = position
          )(@_positionsSize)

          @_update =>
            @_positions.unshift(@get "position")
            @_positions.pop()

            ###
            ###
            if (~~(Math.random() * @_recInterval)) is 1
              console.log "%c[Stage] StageModel | REC", debug.style
              if @_isMemoryProcessed
                @_isMemoryProcessed = false # フラグを処理中にする
                limit = ~~(Math.random() * (@_positionsSize - @_positionsSelectOffset) + @_positionsSelectOffset)
                positions = _.first(@_positions, limit)

                App.vent.trigger "stageAddMemory",
                  window: @get "window"
                  positions: positions
            
            if (~~(Math.random() * @_memoryGetInterval)) is 1
              console.log "%c[Stage] StageModel | getMemory Request", debug.style
              App.vent.trigger "stageGetMemory",
                limit: (~~(Math.random() * @_memoryGetMaxLimit + 1))
            
        else
          @_stop()

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_addedMemoryHandler
      #  */
      # ------------------------------------------------------------
      _addedMemoryHandler: (status) ->
        console.log "%c[Stage] StageModel -> _addedMemoryHandler", debug.style, status
        # フラグを処理完了状態にする
        @_isMemoryProcessed = true


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
          width: @$el[0].innerWidth
          height: @$el[0].innerHeight


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
            width: @$el[0].innerWidth
            height: @$el[0].innerHeight

          @model.set "window", windowSize
          App.vent.trigger "stageWindowResize", windowSize
        , 500

      # ------------------------------------------------------------
      el: window

      # ------------------------------------------------------------
      events: 
        scroll: "_windowScrollHandler"
        resize: "_windowResizeHandler"
        mousemove: "_mouseMoveHandler"

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
      #  * StageItemView#_mouseMoveHandler
      #  * @el でpointerMove イベントが発生すると呼ばれるイベントハンドラー
      #  * @param {Object} e - pointermove のイベントオブジェクト
      #  */
      # --------------------------------------------------------------
      _mouseMoveHandler: (e) ->
        # console.log "%c[Stage] StageItemView -> _mouseMoveHandler", debug.style, e.clientX, e.clientY
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
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      @models = 
        stage: new StageModel()

      @views =
        stage: new StageItemView(
          model: @models.stage
        )

      # ============================================================
      # REQUEST RESPONSE
      App.reqres.setHandler "stageGetWindowSize", () =>
        # console.log "%c[Stage] Request Response | stageGetWindowSize", debug.style
        return @models.stage.get "window"

    # ============================================================
    StageModule.addFinalizer () ->
      console.log "%c[Stage] addFinalizer", debug.style










