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

    EntranceItemView = Backbone.Marionette.ItemView.extend
      # ------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] EntranceItemView -> initialize", debug.style
        Backbone.Validation.bind @

        # background scriptの socket.ioが特定のRoomへの入室処理が完了した時のイベントリスナー
        App.vent.on "connectJointed", @_jointedHandler.bind @

        # エクステンションの起動状態に変化があった時のイベントリスナー
        App.vent.on "connectChangeExtensionState", @_changeExtensionStateHandler.bind @

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
        console.log "%c[SignUp] EntranceItemView -> onRender", debug.style
        @stickit()

      # ------------------------------------------------------------
      # /** 
      #  * EntranceItemView#_checkInManualRoomHandler
      #  * #js-check-in-button--room_manual からSubmit された時に呼び出されるイベントハンドラー
      #  * @param {Object} e - submit イベントオブジェクト
      #  */
      # ------------------------------------------------------------
      _checkInManualRoomHandler: (e) ->
        console.log "%c[Stage] EntranceItemView -> _checkInManualRoomHandler", debug.style
        e.preventDefault()
        # 二度押しを防止するためボタンを無効化
        @ui.manualRoomButton.prop "disabled", true
        @ui.automaticRoomButton.prop "disabled", true

        # 画面をローディング中に
        App.execute "loadingShow", 400
        
        window.bg.appRun @model.get "roomId"

      # ------------------------------------------------------------
      # /** 
      #  * EntranceItemView#_checkInAutomaticRoomHandler
      #  * #js-check-in-button--room_automatic からSubmit された時に呼び出されるイベントハンドラー
      #  * @param {Object} e - submit イベントオブジェクト
      #  */
      # ------------------------------------------------------------
      _checkInAutomaticRoomHandler: (e) ->
        console.log "%c[Stage] EntranceItemView -> _checkInAutomaticRoomHandler", debug.style
        e.preventDefault()
        # 二度押しを防止するためボタンを無効化
        @ui.manualRoomButton.prop "disabled", true
        @ui.automaticRoomButton.prop "disabled", true
        
        window.bg.appRun null

      # ------------------------------------------------------------
      # /** 
      #  * EntranceItemView#_changeIsRoomIdValidHandler
      #  * フォームのバリデーション結果によってボタンの状態をアップデートする
      #  * @prop {Object} model - BackBone Model Object
      #  * @prop {bool} isRoomIdValid - フォームに入力されたAutomatic Room IDのバリデーション結果
      #  */
      # ------------------------------------------------------------
      _changeIsRoomIdValidHandler: (model, isRoomIdValid) ->
        console.log "%c[Stage] EntranceItemView -> _changeIsRoomIdValidHandler", debug.style, model, isRoomIdValid
        if isRoomIdValid
          @ui.manualRoomButton.prop "disabled", false
        else
          @ui.manualRoomButton.prop "disabled", true

      # --------------------------------------------------------------
      # /**
      #  * EntranceItemView#_changeExtensionStateHandler
      #  * エクステンションの起動状態が変わった時に呼ばれるイベントハンドラー
      #  * @param {Object} extensionState
      #  * @prop {boolean} extensionState.isRun - エクステンションの起動状態
      #  * @prop {boolean} extensionState.isConnected - socketサーバーとの接続状態
      #  */
      # --------------------------------------------------------------
      _changeExtensionStateHandler: (extensionState) ->
        console.log "%c[Stage] EntranceItemView -> _changeExtensionStateHandler", debug.style, extensionState

      # --------------------------------------------------------------
      # /**
      #  * EntranceItemView#_jointedHandler
      #  */
      # --------------------------------------------------------------
      _jointedHandler: (data) ->
        console.log "%c[Stage] EntranceItemView -> _jointedHandler", debug.style, data

        if data.status is "success"
          @ui.manualRoomCheckInerrorType0.addClass "is__hidden"
          @ui.manualRoomCheckInerrorType1.addClass "is__hidden"
          @ui.manualRoomCheckInerrorType2.addClass "is__hidden"
          App.execute "loadingHide", 400, 600
        else if data.status is "error"
          switch data.type
            when "CapacityOver"
              @ui.manualRoomCheckInerrorType0.removeClass "is__hidden"
            when "BudQuery"
              @ui.manualRoomCheckInerrorType1.removeClass "is__hidden"
            when "Unknown"
              @ui.manualRoomCheckInerrorType2.removeClass "is__hidden"
          App.execute "loadingHide", 400, 600

    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      models = 
        entrance: new EntranceModel()

      views =
        entrance: new EntranceItemView
          model: models.entrance
        loading: new LoadingItemView()

      views.entrance.render()

      # ============================================================
      # COMMANDS
      App.commands.setHandler "loadingShow", (duration=400, delay=0) ->
        console.log "%c[Connect] Commands | loadingShow", debug.style
        views.loading.show duration, delay

      App.commands.setHandler "loadingHide", (duration=400, delay=0) ->
        console.log "%c[Connect] Commands | loadingHide", debug.style
        views.loading.hide duration, delay

    # ============================================================
    StageModule.addFinalizer () ->
      console.log "%c[Stage] addFinalizer", debug.style



