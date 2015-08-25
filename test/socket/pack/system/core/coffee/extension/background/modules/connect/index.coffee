# ============================================================
# Connect
# 
# EVENT
#   - connectPointerMove
#
# SEND TYPE
#   - changeIsRun ConnectModel#_changeIsRunHandler
#   - checkIn     ConnectModel#_changeIsRunHandler
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: DarkGreen; color: #ffffff;"

  App.module "ConnectModule", (ConnectModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Connect] ConnectModule", debug.style

    # ============================================================
    # Controller
    # ============================================================



    # ============================================================
    # Model
    # ============================================================
    ConnectModel = Backbone.Model.extend
      # ------------------------------------------------------------
      # /** 
      #  * ConnectModel#defaults
      #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
      #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
      #  * @type {Object}
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  * @prop {string} landscape - base64形式のスクリーンショット
      #  */
      # ------------------------------------------------------------
      defaults:
        isRun: false
        landscape: ""

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#initialize
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Connect] ConnectModel -> initialize", debug.style

        # タブが変更された時のイベントリスナー
        # App.vent.on "stageSelsectedTabId", @_changeSelsectedTabIdHandler.bind @

        # スクリーンショットが撮影された時に呼び出される
        @listenTo @, "change:landscape", @_changeLandscapeHandler

        # TEST
        # content script からのLong-lived 接続
        # chrome.extension.onConnect.addListener (port) =>
        chrome.runtime.onConnect.addListener (port) =>
          changeIsRunHandler = @_changeIsRunHandler.bind(@)(port)
          sendCheckInHandler = @_sendCheckInHandler.bind(@)(port)
          sendCheckOutHandler = @_sendCheckOutHandler.bind(@)(port)
          sendUpdatePointerHandler = @_sendUpdatePointerHandler.bind(@)(port)

          # Long-lived 接続 切断時の処理を登録する
          port.onDisconnect.addListener =>
            App.vent.off "stageChangeIsRun", changeIsRunHandler
            App.vent.off "socketCheckIn", sendCheckInHandler
            App.vent.off "socketCheckOut", sendCheckOutHandler
            App.vent.off "socketUpdatePointer", sendUpdatePointerHandler
            port.disconnect()
            console.log "%c[Connect] ConnectModel | onDisconnect", debug.style


          if port.name is "contentScript"
            console.log "%c[Connect] ConnectModel | onConnect", debug.style

            # エクステンションの起動状態に変化があった時のイベントリスナー
            # App.vent.off "stageChangeIsRun", @_changeIsRunHandler.bind(@)(port)
            # App.vent.on "stageChangeIsRun", @_changeIsRunHandler.bind(@)(port)
            App.vent.on "stageChangeIsRun", changeIsRunHandler
            # socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出される
            # App.vent.off "socketCheckIn", @_sendCheckInHandler.bind(@)(port)
            # App.vent.on "socketCheckIn", @_sendCheckInHandler.bind(@)(port)
            App.vent.on "socketCheckIn", sendCheckInHandler
            # 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出される
            # App.vent.off "socketCheckOut", @_sendCheckOutHandler.bind(@)(port)
            # App.vent.on "socketCheckOut", @_sendCheckOutHandler.bind(@)(port)
            App.vent.on "socketCheckOut", sendCheckOutHandler
            # ポインターの座標に変化があった時に呼び出される
            # App.vent.off "socketUpdatePointer", @_sendUpdatePointerHandler.bind(@)(port)
            # App.vent.on "socketUpdatePointer", @_sendUpdatePointerHandler.bind(@)(port)
            App.vent.on "socketUpdatePointer", sendUpdatePointerHandler

            # メッセージを受信した時の処理
            port.onMessage.addListener (message) =>
              console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

              # content script からの通知か判別する
              if (message.from? and message.from is "contentScript") and message.type?
                switch message.type
                  when "setup"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup", debug.style, message
                    
                    # エクステンションがすでに起動している場合の処理
                    if @get "isRun"
                      # CheckInしているユーザーを取得する
                      _sendCheckInHandler = @_sendCheckInHandler.bind(@)(port)
                      _sendCheckInHandler App.reqres.request "socketGetUsers"

                    port.postMessage
                      to: "contentScript"
                      from: "background"
                      type: "setup"
                      body:
                        isRun: @get "isRun"

                  when "pointerMove"
                    App.vent.trigger "connectPointerMove", message.body

                  when "updateLandscape"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updateLandscape", debug.style, message

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * エクステンションの起動状態に変化があった時に呼び出されるイベントハンドラー
      #  * @param {boolean} isRun - エクステンションの起動状態
      #  */
      # --------------------------------------------------------------
      _changeIsRunHandler: (port) ->
        return (isRun) =>
          console.log "%c[Connect] ConnectModel -> _changeIsRunHandler", debug.style, isRun

          @set "isRun", isRun

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "changeIsRun"
            body:
              isRun: isRun

      # # --------------------------------------------------------------
      # # /**
      # #  * ConnectModel#_changeSelsectedTabIdHandler
      # #  * 選択されているタブが変わった時のイベントハンドラー 
      # #  * contentScript からデータを受信した時の処理を設定する
      # #  * @param {number} tabId - 選択されているタブのID
      # #  */
      # # -------------------------------------------------------------
      # _changeSelsectedTabIdHandler: (tabId) ->
      #   console.log "%c[Connect] ConnectModel -> _changeSelsectedTabIdHandler", debug.style, tabId

      #   if @get "isRun"
      #     contentScriptPort = chrome.tabs.connect tabId, "name": "background"
      #     @_setContentScriptPort contentScriptPort

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendCheckInHandler
      #  * socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出されるイベントハンドラーかつ
      #  * Receive Message | setup が発生した時にエクステンションが起動している時にも呼び出される
      #  * アクティブなタブのcontent script にユーザーの一覧を通知する
      #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # -------------------------------------------------------------
      _sendCheckInHandler: (port) ->
        return (users) =>
          console.log "%c[Connect] ConnectModel -> _sendCheckInHandler", debug.style, users

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "checkIn"
            body:
              users: users

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_receiveCheckOutHandler
      #  * 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出されるイベントハンドラー
      #  * アクティブなタブのcontent script に切断したユーザーのSocket IDを通知する
      #  * @param {string} user - 同じRoom に所属していたユーザーのSocket ID
      #  */
      # ------------------------------------------------------------
      _sendCheckOutHandler: (port) ->
        (user) =>
          console.log "%c[Connect] ConnectModel -> _sendCheckOutHandler", debug.style, user

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "checkOut"
            body:
              user: user

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendUpdatePointerHandler
      #  * 同じRoom に所属していたユーザーのポインターの座標の変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * アクティブなタブのcontent script にポインター座標の情報を通知する
      #  * @param {Object} data
      #  * @prop {string} socketId - 発信元のsocket.id
      #  * @prop {number} x - 発信者のポインターのx座標
      #  * @prop {number} y - 発信者のポインターのy座標
      #  */
      # ------------------------------------------------------------
      _sendUpdatePointerHandler: (port) ->
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendUpdatePointerHandler", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "updatePointer"
            body: data

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeLandscapeHandler
      #  * スクリーンショットが撮影された時に呼び出されるイベントハンドラー
      #  * @param {Object} Model - BackBone Model Object
      #  * @prop {string} landscape - base64形式のスクリーンショット
      #  */
      # --------------------------------------------------------------
      _changeLandscapeHandler: (model, landscape) ->
        console.log "%c[Connect] ConnectModel -> _changeLandscapeHandler", debug.style


      # # --------------------------------------------------------------
      # # /**
      # #  * ConnectModel#_setContentScriptPort
      # #  * contentScript に接続したLong-lived なポートの設定をする
      # #  * @param {Port} port - 双方向通信を可能にするオブジェクト
      # #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
      # #  */
      # # --------------------------------------------------------------
      # _setContentScriptPort: (port) ->
      #   console.log "%c[Connect] ConnectModel -> _setContentScriptPort", debug.style

      #   # メッセージを受信した時の処理
      #   port.onMessage.addListener (message) =>
      #     console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

      #     # content script からの通知か判別する
      #     if (message.from? and message.from is "contentScript") and message.type?
      #       switch message.type
      #         when "pointerMove"
      #           App.vent.trigger "connectPointerMove", message.body


    # ============================================================
    ConnectModule.addInitializer (options) ->
      console.log "%c[Connect] addInitializer", debug.style, options

      @models = 
        connect: new ConnectModel()

      # ============================================================
      # COMMANDS


    # ============================================================
    ConnectModule.addFinalizer (options) ->
      console.log "%c[Connect] addFinalizer", debug.style, options





























