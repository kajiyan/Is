# ============================================================
# Lover
# ============================================================
module.exports = (App, sn, $, _, isElShadowRoot) ->
  debug = 
    style: "background-color: DarkBlue; color: #ffffff;"


  App.module "LoverModule", (LoverModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Lover] LoverModule", debug.style

    # ============================================================
    # Controller



    # ============================================================
    # MODEL
    # ============================================================
    LoverModel = Backbone.Model.extend
      # ------------------------------------------------------------
      defaults:
        position:
          x: 0
          y: 0
        window:
          width: 0
          height: 0
        link: ""
        landscape: ""
      
      # --------------------------------------------------------------
      # /**
      #  * LoverModel#initialize
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Lover] LoverModel -> initialize", debug.style
        # @listenTo @, "change:position", _changePositionHandler

      # --------------------------------------------------------------
      # /**
      #  * LoverModel#_changePositionHandler
      #  */
      # --------------------------------------------------------------
      _changePositionHandler: () ->
        console.log "%c[Lover] LoverModel -> _changePositionHandler", debug.style



    # ============================================================
    # COLLECTION
    # ============================================================
    LoversCollection = Backbone.Collection.extend
      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#initialize
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Lover] LoversCollection -> initialize", debug.style
        App.vent.on "connectDisconnect", @_resetUserHandler.bind @
        App.vent.on "connectAddUser", @_addUserHandler.bind @
        App.vent.on "connectAddResident", @_addUserHandler.bind @
        App.vent.on "connectCheckOut", @_removeUserHandler.bind @
        App.vent.on "connectUpdateLocation", @_updateLocationHandler.bind @
        App.vent.on "connectUpdateWindowSize", @_updateWindowSizeHandler.bind @
        App.vent.on "connectUpdatePointer", @_updatePointerHandler.bind @
        App.vent.on "connectUpdateLandscape", @_updateLandscapeHandler.bind @

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#model
      #  */
      # --------------------------------------------------------------
      model: LoverModel

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_addUserHandler
      #  * @param {Object} data
      #  * @prop {string} id - 発信元のsocket.id
      #  * @prop {number} position.x - 接続ユーザーのポインター x座標
      #  * @prop {number} position.y - 接続ユーザーのポインター y座標
      #  * @prop {number} window.width - 接続ユーザーのwindow の幅
      #  * @prop {number} window.height - 接続ユーザーのwindow の高さ
      #  * @prop {string} link - 接続ユーザーが閲覧していたページのURL
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # --------------------------------------------------------------
      _addUserHandler: (data) ->
        console.log "%c[Lover] LoversCollection -> _addUserHandler", debug.style, data
        @add data

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_removeUserHandler
      #  * @param {Object} data
      #  * @prop {string} id - 同じRoomに所属していたユーザーのSocketID
      #  */
      # --------------------------------------------------------------
      _removeUserHandler: (data) ->
        console.log "%c[Lover] LoversCollection -> _removeUserHandler", debug.style, data
        @remove id: data.id

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_resetUserHandler
      #  */
      # --------------------------------------------------------------
      _resetUserHandler: () ->
        console.log "%c[Lover] LoversCollection -> _removeUserHandler", debug.style
        @reset()

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_updateLocationHandler
      #  * @param {Object} data
      #  * @prop {string} id - 発信者のsocket.id
      #  * @prop {string} link - 接続ユーザーの閲覧しているURL
      #  */
      # --------------------------------------------------------------
      _updateLocationHandler: (data) ->
        console.log "%c[Lover] LoversCollection -> _updateLocationHandler", debug.style, data
        loverModel = @findWhere id: data.id
        loverModel.set "link": data.link

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_updateWindowSizeHandler
      #  * 同じRoom に所属していたユーザーのウインドウサイズの変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * @param {Object} data
      #  * @prop {string} id - 発信者のsocket.id
      #  * @prop {number} window.width - 発信者のwindowの幅
      #  * @prop {number} window.height - 発信者のwindowの高さ
      #  */
      # --------------------------------------------------------------
      _updateWindowSizeHandler: (data) ->
        console.log "%c[Lover] LoversCollection -> _updateWindowSizeHandler", debug.style, data
        loverModel = @findWhere id: data.id
        loverModel.set "window": data.window

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_updatePointerHandler
      #  * 同じRoom に所属していたユーザーのポインターの座標の変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * @param {Object} data
      #  * @prop {string} id - 発信元のsocket.id
      #  * @prop {number} position.x - 発信者のポインターのx座標
      #  * @prop {number} position.y - 発信者のポインターのy座標
      #  */
      # --------------------------------------------------------------
      _updatePointerHandler: (data) ->
        # console.log "%c[Lover] LoversCollection -> _updatePointerHandler", debug.style, data
        loverModel = @findWhere id: data.id
        loverModel.set position: data.position

      # --------------------------------------------------------------
      # /**
      #  * LoversCollection#_updateLandscapeHandler
      #  * 同じRoom に所属しているユーザーのスクリーンショットが更新されたことを
      #  * 通知された時に呼び出されるイベントハンドラー
      #  * LoverModel にlandscape をセットする
      #  * @param {Object} data
      #  * @prop {string} id - 発信元のsocket.id
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # --------------------------------------------------------------
      _updateLandscapeHandler: (data) ->
        console.log "%c[Lover] LoversCollection -> _updateLandscapeHandler", debug.style, data

        loverModel = @findWhere id: data.id
        loverModel.set landscape: data.landscape



      # ============================================================
      # ITEM VIEW
      # ============================================================
      LoverItemView = Backbone.Marionette.ItemView.extend
        # ------------------------------------------------------------
        initialize: () ->
          console.log "%c[Lover] LoverItemView -> initialize", debug.style
          @listenTo @model, "change:link", @_changeLinkHandler
          @listenTo @model, "change:position", @_changePositionHandler
          @listenTo @model, "change:window", @_changeWindowHandler
          @listenTo @model, "change:landscape", @_changeLandscapeHandler

        # ------------------------------------------------------------
        tagName: "div"
      
        # ------------------------------------------------------------
        className: "lover"

        # ------------------------------------------------------------
        template: _.template(isElShadowRoot.querySelector("#lover-template").innerHTML)
      
        # ------------------------------------------------------------
        ui: 
          location: ".location"
          body: ".body"
          landscape: ".landscape"

        # --------------------------------------------------------------
        events:
          "mouseenter @ui.body": "_bodyMouseenterHandler"
          "mouseleave @ui.body": "_bodyMouseleaveHandler"

        # --------------------------------------------------------------
        onRender: () ->

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_changeLinkHandler
        #  * @param {Object} model - BackBone Model Object
        #  * @param {string} link - 接続ユーザーの閲覧しているURL
        #  */
        # --------------------------------------------------------------
        _changeLinkHandler: (model, link) ->
          console.log "%c[Lover] LoverItemView -> _changeWindowHandler", debug.style, link
          @ui.location.attr "href", link

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_changeWindowHandler
        #  * loverModel のwindow の値が変化した時に呼び出される
        #  * @param {Object} model - BackBone Model Object
        #  * @param {Object} windowSize
        #  * @prop {number} windowSize.width - 発信者のwindowの幅
        #  * @prop {number} windowSize.height - 発信者のwindowの高さ
        #  */
        # --------------------------------------------------------------
        _changeWindowHandler: (model, windowSize) ->
          console.log "%c[Lover] LoverItemView -> _changeWindowHandler", debug.style, windowSize
          @ui.landscape.css
            "background-size": "#{windowSize.width}px #{windowSize.height}px"

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_changePositionHandler
        #  * loverModel のposition の値が変化した時に呼び出される
        #  * （同じRoom に所属していたユーザーのポインターの座標の変化した時）
        #  * @param {Object} model - BackBone Model Object
        #  * @param {Object} position
        #  * @prop {number} x - ポインターのx座標
        #  * @prop {number} y - ポインターのy座標
        #  */
        # --------------------------------------------------------------
        _changePositionHandler: (model, position) ->
          # console.log "%c[Lover] LoverItemView -> _changePositionHandler", debug.style, position
          stageWindowSize = App.reqres.request "stageGetWindowSize"
          windowSize = @model.get "window"
          
          offsetX = (stageWindowSize.width - windowSize.width) / 2
          offsetY = (stageWindowSize.height - windowSize.height) / 2

          @ui.body.css
            transform: "translate(#{position.x + offsetX}px, #{position.y + offsetY}px)"

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_changeLandscapeHandler
        #  * loverModel のlandscape の値が変化した時に呼び出される
        #  * （同じRoom に所属していたユーザーのスクリーンショットが更新された時）
        #  * 引数に渡されたdataUrl を背景画像として設定する
        #  * @param {Object} loverModel - BackBone Model Object
        #  * @param {Object} landscape - スクリーンショット（base64）
        #  */
        # --------------------------------------------------------------
        _changeLandscapeHandler: (model, landscape) ->
          console.log "%c[Lover] LoverItemView -> _changeLandscapeHandler", debug.style, landscape

          @ui.landscape.css
            "background-image": "url(#{landscape})"

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_bodyMouseenterHandler
        #  */
        # --------------------------------------------------------------
        _bodyMouseenterHandler: () ->
          console.log "%c[Lover] LoverItemView -> _bodyMouseenterHandler"
       
          Velocity @ui.landscape, "stop"

          @ui.landscape
            .css
              opacity: 1.0
            .removeClass "is-hidden"

        # --------------------------------------------------------------
        # /**
        #  * LoverItemView#_bodyMouseleaveHandler
        #  */
        # --------------------------------------------------------------
        _bodyMouseleaveHandler: () ->
          console.log "%c[Lover] LoverItemView -> _bodyMouseleaveHandler"

          return $.Deferred (defer) =>
            Velocity.animate @ui.landscape,
              opacity: 0.0
            ,
              duration: 400
              delay: 100
              easing: "easeOutQuart"
              complete: () =>
                @ui.landscape.addClass "is-hidden"
                defer.resolve()
          .promise()




    # ============================================================
    # COLLECTION VIEW
    # ============================================================
    LoversCollectionView = Backbone.Marionette.CollectionView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Lover] LoversCollectionView -> initialize", debug.style

      # ------------------------------------------------------------
      tagName: "div"
      
      # ------------------------------------------------------------
      className: "lovers"

      # ------------------------------------------------------------
      childView: LoverItemView



    # ============================================================
    LoverModule.addInitializer (options) ->
      console.log "%c[Lover] addInitializer", debug.style, options

      loversCollection = new LoversCollection()

      loversCollectionView = new LoversCollectionView
        collection: loversCollection

      App.content.currentView.lovers.show(loversCollectionView)
      
      # ============================================================
      # COMMANDS

      # ============================================================
      # REQUEST RESPONSE


    # ============================================================
    LoverModule.addFinalizer () ->
      console.log "%c[Lover] addFinalizer", debug.style






























