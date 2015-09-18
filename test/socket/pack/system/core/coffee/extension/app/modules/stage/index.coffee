# ============================================================
# Stage
# 
# EVENT
#   - 
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: Black; color: #ffffff;"

  App.module "StageModule", (StageModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Stage] StageModule", debug.style

    Backbone.Validation.configure
      forceUpdate: true

    _.extend Backbone.Validation.patterns,
      isAlphanumeric: /^[a-zA-Z0-9]+$/

    _.extend Backbone.Validation.messages,
      isAlphanumeric: "isnt isAlphanumeric"


    # ============================================================
    # Model
    # ============================================================
    EntranceModel = Backbone.Model.extend
      # ------------------------------------------------------------
      defaults:
        roomId: ""
        isValid: false
        isRoomIdValid: false

      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] EntranceModel -> initialize", debug.style
        # @listenTo @, "change:roomId", () => console.log @get "roomId"
        @listenTo @, "validated", @_validatedHandler

      # ------------------------------------------------------------
      validation: 
        roomId: 
          pattern: "isAlphanumeric"
          length: 6
          required: true

      # ------------------------------------------------------------
      _validatedHandler: (isValid, model, errors) ->
        console.log "%c[SignUp] EntranceModel -> _validatedHandler", debug.style, isValid, model, errors

        # バリデーションの状態
        @set "isValid", isValid

        # エラーがひとつもない状態であればすべて true
        if _.isEmpty(errors)
          @set "isRoomIdValid", true

        for key, value of errors
          switch key
            when "roomId"
              @set "isRoomIdValid", false

    # ============================================================
    # Model - CheckOutModel
    CheckOutModel = Backbone.Model.extend
      # ------------------------------------------------------------
      defaults:
        isActive: false
      # ------------------------------------------------------------
      # /**
      #  * CheckOutModel#initialize
      #  */
      initialize: () ->
        console.log "%c[Stage] CheckOutModel -> initialize", debug.style
    # End Model - CheckOutModel
    # ============================================================



    # ============================================================
    # View
    # ============================================================

    # ============================================================
    # View - LoadingItemView
    LoadingItemView = Backbone.Marionette.ItemView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] LoadingItemView -> initialize", debug.style

      # ------------------------------------------------------------
      el: "#js-loading"

      # ------------------------------------------------------------
      template: false

      # ------------------------------------------------------------
      show: (duration=400, delay=0) ->
        console.log "%c[Stage] LoadingItemView -> show", debug.style
        
        return $.Deferred (defer) =>
          @$el
            .css
              opacity: 0.0
            .removeClass "is__hidden"
          
          Velocity.animate @$el,
            opacity: 1.0
          ,
            duration: duration
            delay: delay
            easing: "easeOutQuart"
            complete: () =>
              defer.resolve()
        .promise()

      # ------------------------------------------------------------
      hide: (duration=400, delay=0) ->
        console.log "%c[Stage] LoadingItemView -> hide", debug.style
        
        return $.Deferred (defer) =>
          Velocity.animate @$el,
            opacity: 0.0
          ,
            duration: duration
            delay: delay
            easing: "easeOutQuart"
            complete: () =>
              @$el.addClass "is__hidden"
              defer.resolve()
        .promise()
    # END View - LoadingItemView
    # ============================================================

    # ============================================================
    # ItemView - CheckInItemView
    CheckInItemView = Backbone.Marionette.ItemView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] CheckInItemView -> initialize", debug.style
        Backbone.Validation.bind @

        # エクステンションのポップアップが表示された時のイベントリスナー
        App.vent.on "connectSetup", @_setupHandler.bind @
        # background scriptの socket.ioが特定のRoomへの入室処理が完了した時のイベントリスナー
        App.vent.on "connectJointed", @_jointedHandler.bind @
        # # エクステンションの起動状態に変化があった時のイベントリスナー
        # App.vent.on "connectChangeExtensionState", @_changeExtensionStateHandler.bind @

        @listenTo @model, "change:isRoomIdValid", @_changeIsRoomIdValidHandler

      # ------------------------------------------------------------
      el: "#js-check-in"

      # ------------------------------------------------------------
      ui: 
        manualRoomForm: "#js-check-in-form--room_manual"
        manualRoomButton: "#js-check-in-button--room_manual"
        manualRoomCheckInerrorType0: "#check-in-error--type-0"
        manualRoomCheckInerrorType1: "#check-in-error--type-1"
        manualRoomCheckInerrorType2: "#check-in-error--type-2"
        checkInRoomIdInput: "#js-check-in-input--room_id"
        automaticRoomForm: "#js-check-in-form--room_automatic"
        automaticRoomButton: "#js-check-in-button--room_automatic"
        # checkOutForm: "#js-check-out-form"
        # checkOutButton: "#js-check-out-button"

      # ------------------------------------------------------------
      template: false

      # ------------------------------------------------------------
      events:
        "submit @ui.manualRoomForm": "_checkInManualRoomHandler"
        "submit @ui.automaticRoomForm": "_checkInAutomaticRoomHandler"
        # "submit @ui.checkOutForm": (e) ->
        #   e.preventDefault()
        #   window.bg.appStop()

      # ------------------------------------------------------------
      bindings: 
        "#js-check-in-input--room_id":
          observe: "roomId"
          setOptions: 
            validate: true

      # ------------------------------------------------------------
      onRender: ->
        console.log "%c[SignUp] CheckInItemView -> onRender", debug.style
        @stickit()

      # ------------------------------------------------------------
      # /** 
      #  * CheckInItemView#_checkInManualRoomHandler
      #  * #js-check-in-button--room_manual からSubmit された時に呼び出されるイベントハンドラー
      #  * @param {Object} e - submit イベントオブジェクト
      #  */
      # ------------------------------------------------------------
      _checkInManualRoomHandler: (e) ->
        console.log "%c[Stage] CheckInItemView -> _checkInManualRoomHandler", debug.style
        e.preventDefault()
        # 二度押しを防止するためボタンを無効化
        @ui.manualRoomButton.prop "disabled", true
        @ui.automaticRoomButton.prop "disabled", true

        # 画面をローディング中に
        App.reqres.request "loadingShow", 400
        
        window.bg.appRun @model.get "roomId"

      # ------------------------------------------------------------
      # /** 
      #  * CheckInItemView#_checkInAutomaticRoomHandler
      #  * #js-check-in-button--room_automatic からSubmit された時に呼び出されるイベントハンドラー
      #  * @param {Object} e - submit イベントオブジェクト
      #  */
      # ------------------------------------------------------------
      _checkInAutomaticRoomHandler: (e) ->
        console.log "%c[Stage] CheckInItemView -> _checkInAutomaticRoomHandler", debug.style
        e.preventDefault()
        # 二度押しを防止するためボタンを無効化
        @ui.manualRoomButton.prop "disabled", true
        @ui.automaticRoomButton.prop "disabled", true

        # 画面をローディング中に
        App.reqres.request "loadingShow", 400
        
        window.bg.appRun null

      # ------------------------------------------------------------
      # /** 
      #  * CheckInItemView#_changeIsRoomIdValidHandler
      #  * フォームのバリデーション結果によってボタンの状態をアップデートする
      #  * @prop {Object} model - BackBone Model Object
      #  * @prop {bool} isRoomIdValid - フォームに入力されたAutomatic Room IDのバリデーション結果
      #  */
      # ------------------------------------------------------------
      _changeIsRoomIdValidHandler: (model, isRoomIdValid) ->
        console.log "%c[Stage] CheckInItemView -> _changeIsRoomIdValidHandler", debug.style, model, isRoomIdValid
        if isRoomIdValid
          @ui.manualRoomButton.prop "disabled", false
        else
          @ui.manualRoomButton.prop "disabled", true

      # --------------------------------------------------------------
      # /**
      #  * CheckInItemView#_setupHandler
      #  * エクステンションのポップアップが表示された時に呼ばれるイベントハンドラー
      #  * @param {Object} extensionState
      #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      #  * @prop {boolean} extensionState.isRoomJoin - roomへの入室状態
      #  */
      # --------------------------------------------------------------
      _setupHandler: (extensionState) ->
        console.log "%c[Stage] CheckInItemView -> _setupHandler", debug.style, extensionState

        if not extensionState.isRun and
          not extensionState.isConnected and
          not extensionState.isRoomJoin
            chrome.browserAction.setIcon path: "public/images/extension/icon-off-32-0.png"
            @show 600, 200
            # @$el.removeClass "is__hidden"

      # # --------------------------------------------------------------
      # # /**
      # #  * CheckInItemView#_changeExtensionStateHandler
      # #  * エクステンションの起動状態が変わった時に呼ばれるイベントハンドラー
      # #  * @param {Object} extensionState
      # #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      # #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      # #  */
      # # --------------------------------------------------------------
      # _changeExtensionStateHandler: (extensionState) ->
      #   console.log "%c[Stage] CheckInItemView -> _changeExtensionStateHandler", debug.style, extensionState

      # --------------------------------------------------------------
      # /**
      #  * CheckInItemView#_jointedHandler
      #  * background scriptの socket.ioが特定のRoomへの入室処理が完了した時のイベントハンドラー
      #  * @param {Object} data
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  * @prop {boolean} isConnected - socketサーバーとの接続状態
      #  * @prop {boolean} isRoomJoin - roomへの入室状態
      #  * @prop {string} status - roomにjoinできたか success | error
      #  * @prop {string} type - errorだった場合、その種類
      #  * @prop {Object} body
      #  * @prop {string} body.message - errorだった場合、その内容
      #  */
      # --------------------------------------------------------------
      _jointedHandler: (data) ->
        console.log "%c[Stage] CheckInItemView -> _jointedHandler", debug.style, data

        @ui.manualRoomCheckInerrorType0.addClass "is__hidden"
        @ui.manualRoomCheckInerrorType1.addClass "is__hidden"
        @ui.manualRoomCheckInerrorType2.addClass "is__hidden"

        if data.status is "success"
          $.when(
            App.reqres.request "loadingHide", 400, 600
          )
          .then(
            =>
              return $.when(
                @hide 600
              )
          )
          .then(
            =>
              chrome.browserAction.setIcon path: "public/images/extension/icon-on-32-0.png"
              App.reqres.request "checkOutShow", 400, 600
          )
        else if data.status is "error"
          switch data.type
            when "CapacityOver"
              @ui.manualRoomCheckInerrorType0.removeClass "is__hidden"
            when "BudQuery"
              @ui.manualRoomCheckInerrorType1.removeClass "is__hidden"
            when "Unknown"
              @ui.manualRoomCheckInerrorType2.removeClass "is__hidden"
          @ui.automaticRoomButton.prop "disabled", false
          App.reqres.request "loadingHide", 400, 600

      # ------------------------------------------------------------
      show: (duration=600, delay=0) ->
        console.log "%c[Stage] CheckInItemView -> show", debug.style

        return $.Deferred (defer) =>
          @ui.automaticRoomButton.prop "disabled", false
          to =
            height: @$el.height()
            opacity: 1.0

          @$el
            .css
              height: 0
              opacity: 0.0
            .removeClass "is__hidden"

          Velocity.animate @$el,
            to
          ,
            duration: duration
            delay: delay
            easing: "ease"
            complete: () =>
              @$el.removeAttr "style"
              defer.resolve()
        .promise()

      # ------------------------------------------------------------
      # /**
      #  * CheckInItemView#hide
      #  */
      # ------------------------------------------------------------
      hide: (duration=600, delay=0) ->
        console.log "%c[Stage] CheckInItemView -> hide", debug.style

        return $.Deferred (defer) =>
          Velocity.animate @$el,
            height: 0
            opacity: 0.0
          ,
            duration: duration
            delay: delay
            easing: "ease"
            complete: () =>
              @ui.checkInRoomIdInput.val "" # inputを空にする
              @$el
                .addClass "is__hidden"
                .removeAttr "style"
              defer.resolve()
        .promise()
    # End ItemView - CheckInItemView
    # ============================================================


    # ============================================================
    # ItemView - CheckOutItemView
    CheckOutItemView = Backbone.Marionette.ItemView.extend
      # ------------------------------------------------------------
      # /**
      #  * CheckOutItemView#initialize
      #  */
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] LoadingItemView -> initialize", debug.style
        # エクステンションのポップアップが表示された時のイベントリスナー
        App.vent.on "connectSetup", @_setupHandler.bind @
        # background scriptがsocketサーバーとのが通信が切断された時のイベントリスナー
        App.vent.on "connectDisconnect", @_disconnectHandler.bind @

      # ------------------------------------------------------------
      el: "#js-check-out"

      # ------------------------------------------------------------
      ui: 
        checkOutForm: "#js-check-out-form"
        checkOutButton: "#js-check-out-button"

      # ------------------------------------------------------------
      template: false

      # ------------------------------------------------------------
      events:
        "submit @ui.checkOutForm": "_checkOutHandler"

      # --------------------------------------------------------------
      # /**
      #  * CheckOutItemView#_setupHandler
      #  * エクステンションのポップアップが表示された時に呼ばれるイベントハンドラー
      #  * @param {Object} extensionState
      #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      #  * @prop {boolean} extensionState.isRoomJoin - roomへの入室状態
      #  */
      # --------------------------------------------------------------
      _setupHandler: (extensionState) ->
        console.log "%c[Stage] CheckOutItemView -> _setupHandler", debug.style, extensionState

        if extensionState.isRun and
          extensionState.isConnected and
          extensionState.isRoomJoin
            chrome.browserAction.setIcon path: "public/images/extension/icon-on-32-0.png"
            @model.set "isActive", true
            @show 600, 200
            # @$el.removeClass "is__hidden"

      # ------------------------------------------------------------
      # /**
      #  * CheckOutItemView#_checkOutHandler
      #  */
      # ------------------------------------------------------------
      _checkOutHandler: (e) ->
        console.log "%c[Stage] CheckOutItemView -> _checkOutHandler", debug.style
        e.preventDefault()
        App.reqres.request "loadingShow", 400
        window.bg.appStop()

      # ------------------------------------------------------------
      # /**
      #  * CheckOutItemView#_disconnectHandler
      #  */
      # ------------------------------------------------------------
      _disconnectHandler: (data) ->
        console.log "%c[Stage] CheckOutItemView -> _disconnectHandler", debug.style
        # checkOut画面がアクティブであったら切り替えのアニメーションをさせる
        if @model.get "isActive"
          $.when(
            App.reqres.request "loadingHide", 400, 600
          )
          .then(
            =>
              return $.when(
                @hide 600
              )
          )
          .then(
            =>
              chrome.browserAction.setIcon path: "public/images/extension/icon-off-32-0.png"
              App.reqres.request "checkInShow", 400, 600
          )

      # ------------------------------------------------------------
      # /**
      #  * CheckOutItemView#show
      #  */
      # ------------------------------------------------------------
      show: (duration=600, delay=0) ->
        console.log "%c[Stage] CheckOutItemView -> show", debug.style

        return $.Deferred (defer) =>
          to =
            height: @$el.height()
            opacity: 1.0

          @$el
            .css
              height: 0
              opacity: 0.0
            .removeClass "is__hidden"

          Velocity.animate @$el,
            to
          ,
            duration: duration
            delay: delay
            easing: "ease"
            complete: () =>
              @model.set "isActive", true
              @$el.removeAttr "style"
              defer.resolve()
        .promise()

      # ------------------------------------------------------------
      # /**
      #  * CheckOutItemView#hide
      #  */
      # ------------------------------------------------------------
      hide: (duration=600, delay=0) ->
        console.log "%c[Stage] CheckOutItemView -> hide", debug.style

        return $.Deferred (defer) =>
          Velocity.animate @$el,
            height: 0
            opacity: 0.0
          ,
            duration: duration
            delay: delay
            easing: "ease"
            complete: () =>
              @model.set "isActive", false
              @$el
                .addClass "is__hidden"
                .removeAttr "style"
              defer.resolve()
        .promise()
    # End ItemView - CheckOutItemView
    # ============================================================


    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      models = 
        entrance: new EntranceModel()
        checkOut: new CheckOutModel()

      views =
        checkIn: new CheckInItemView
          model: models.entrance
        checkOut: new CheckOutItemView
          model: models.checkOut
        loading: new LoadingItemView()

      views.checkIn.render()

      # ============================================================
      # REQUEST RESPONSE
      App.reqres.setHandler "checkInShow", (duration=400, delay=0) ->
        console.log "%c[Stage] Commands | checkInShow", debug.style
        return views.checkIn.show duration, delay

      App.reqres.setHandler "checkOutShow", (duration=400, delay=0) ->
        console.log "%c[Stage] Commands | checkOutShow", debug.style
        return views.checkOut.show duration, delay

      App.reqres.setHandler "loadingShow", (duration=400, delay=0) ->
        console.log "%c[Stage] Commands | loadingShow", debug.style
        return views.loading.show duration, delay

      App.reqres.setHandler "loadingHide", (duration=400, delay=0) ->
        console.log "%c[Stage] Commands | loadingHide", debug.style
        return views.loading.hide duration, delay


    # ============================================================
    StageModule.addFinalizer () ->
      console.log "%c[Stage] addFinalizer", debug.style



