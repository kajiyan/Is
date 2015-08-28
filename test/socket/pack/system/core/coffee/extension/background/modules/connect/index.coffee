# ============================================================
# Connect
# 
# EVENT
#   - connectInitializeUser
#   - connectWindowResize
#   - connectPointerMove
#   - connectUpdateLandscape
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

        # TEST
        # content script からのLong-lived 接続
        # chrome.extension.onConnect.addListener (port) =>
        chrome.runtime.onConnect.addListener (port) =>

          # chrome.tabs.query
          #   currentWindow: true
          #   active: true
          #   ,
          #   (tabs) ->
          #     console.log tabs
          tabId = port.sender.tab.id
          windowId = port.sender.tab.windowId
          link = port.sender.tab.url

          changeIsRunHandler = @_changeIsRunHandler.bind(@)(port)
          sendJointedHandler = @_sendJointedHandler.bind(@)(port)
          sendAddUser = @_sendAddUser.bind(@)(port)
          # sendCheckInHandler = @_sendCheckInHandler.bind(@)(port)
          sendCheckOutHandler = @_sendCheckOutHandler.bind(@)(port)
          sendUpdatePointerHandler = @_sendUpdatePointerHandler.bind(@)(port)
          sendUpdateLandscapeHandler = @_sendUpdateLandscapeHandler.bind(@)(port)

          # Long-lived 接続 切断時の処理を登録する
          port.onDisconnect.addListener =>
            App.vent.off "stageChangeIsRun", changeIsRunHandler
            App.vent.off "socketJointed", sendJointedHandler
            App.vent.off "socketAddUser", sendAddUser
            # "socketAddResident"
            # App.vent.off "socketCheckIn", sendCheckInHandler
            App.vent.off "socketCheckOut", sendCheckOutHandler
            App.vent.off "socketUpdatePointer", sendUpdatePointerHandler
            App.vent.off "socketUpdateLandscape", sendUpdateLandscapeHandler
            port.disconnect()
            console.log "%c[Connect] ConnectModel | onDisconnect", debug.style


          if port.name is "contentScript"
            console.log "%c[Connect] ConnectModel | onConnect", debug.style

            # エクステンションの起動状態に変化があった時のイベントリスナー
            App.vent.on "stageChangeIsRun", changeIsRunHandler
            # socketサーバーの特定のRoomへの入室が完了した時に呼び出される
            App.vent.on "socketJointed", sendJointedHandler
            # socketサーバーから所属するroomに新規ユーザーが追加された時に呼び出される
            App.vent.on "socketAddUser", sendAddUser
            # socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出される
            # App.vent.on "socketCheckIn", sendCheckInHandler
            # 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出される
            App.vent.on "socketCheckOut", sendCheckOutHandler
            # 同じRoom に所属しているユーザーのポインター座標に変化があった時に呼び出される
            App.vent.on "socketUpdatePointer", sendUpdatePointerHandler
            # 同じRoom に所属しているユーザーのスクリーンショットが更新された時に呼び出される
            App.vent.on "socketUpdateLandscape", sendUpdateLandscapeHandler

            # メッセージを受信した時の処理
            port.onMessage.addListener (message) =>
              # console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

              # content script からの通知か判別する
              if (message.from? and message.from is "contentScript") and message.type?
                switch message.type
                  when "setup"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup", debug.style, message

                    # # エクステンションがすでに起動している場合の処理
                    # if @get "isRun"
                    #   # CheckInしているユーザーを取得する
                    #   _sendCheckInHandler = @_sendCheckInHandler.bind(@)(port)
                    #   _sendCheckInHandler App.reqres.request "socketGetUsers"

                    port.postMessage
                      to: "contentScript"
                      from: "background"
                      type: "setup"
                      body:
                        isRun: @get "isRun"

                  when "initializeUser"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | initializeUser", debug.style, message
                    
                    # スクリーンショットを撮影する
                    chrome.tabs.captureVisibleTab windowId,
                      format: "jpeg"
                      quality: 80
                      ,
                      (dataUrl) ->
                        App.vent.trigger "connectInitializeUser",
                          position:
                            x: message.body.position.x
                            y: message.body.position.y
                          window:
                            width: message.body.window.width
                            height: message.body.window.height
                          link: link
                          landscape: dataUrl

                  when "initializeResident"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | initializeResident", debug.style, message

                    chrome.tabs.captureVisibleTab windowId,
                      format: "jpeg"
                      quality: 80
                      ,
                      (dataUrl) ->
                        App.vent.trigger "connectInitializeResident",
                          toSocketId: message.body.toSocketId
                          position: message.body.position
                          window: message.body.window
                          link: link
                          landscape: dataUrl


                  when "windowResize"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | windowResize", debug.style, message
                    App.vent.trigger "connectWindowResize", message.body

                  when "pointerMove"
                    # console.log "%c[Connect] ConnectModel | Long-lived Receive Message | pointerMove", debug.style, message
                    App.vent.trigger "connectPointerMove", message.body

                  when "updateLandscape"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updateLandscape", debug.style, message
                    
                    # スクリーンショットを撮影する
                    chrome.tabs.captureVisibleTab windowId,
                      format: "jpeg"
                      quality: 80
                      ,
                      (dataUrl) ->
                        App.vent.trigger "connectUpdateLandscape",
                          landscape: dataUrl


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
      #  * ConnectModel#_sendJointedHandler
      #  * socketサーバーの特定のRoomへの入室が完了した時に呼び出されるイベントハンドラー
      #  */
      # -------------------------------------------------------------
      _sendJointedHandler: (port) ->
        return () =>
          console.log "%c[Connect] ConnectModel -> _sendJointedHandler", debug.style

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "jointed"
            body: {}

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendAddUser
      #  * socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出されるイベントハンドラー
      #  * content script に新規ユーザーの表示依頼(addUser)と、
      #  * 新規ユーザーに通知する既存ユーザーの情報取得依頼(initializeResident)をする
      #  */
      # -------------------------------------------------------------
      _sendAddUser: (port) ->
        # /**
        #  * @param {Object} data
        #  * @prop {string} id - 発信元のsocket.id
        #  * @prop {number} position.x - 接続ユーザーのポインター x座標
        #  * @prop {number} position.y - 接続ユーザーのポインター y座標
        #  * @prop {number} window.width - 接続ユーザーのwindow の幅
        #  * @prop {number} window.height - 接続ユーザーのwindow の高さ
        #  * @prop {string} link - 接続ユーザーが閲覧していたページのURL
        #  * @prop {string} landscape - スクリーンショット（base64）
        #  */
        return (data) =>
          console.log "%c[Connect] ConnectModel -> _sendAddUser", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "addUser"
            body: data

          # このポートが接続しているtabId
          tabId = port.sender.tab.id
          # 現在選択されているTabのIDを取得する
          selsectedTabId = App.reqres.request "stageGetSelsectedTabId"

          # アクティブなタブだけにメッセージを送る
          if tabId is selsectedTabId
            port.postMessage
              to: "contentScript"
              from: "background"
              type: "initializeResident"
              body:
                toSocketId: data.id

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
      #  * ConnectModel#_sendUpdateLandscapeHandler
      #  * 同じRoom に所属しているユーザーのスクリーンショットが更新された時に呼び出されるイベントハンドラー
      #  * アクティブなタブのcontent script にスクリーンショットの情報を通知する
      #  * @param {Object} data
      #  * @prop {string} socketId - 発信元のsocket.id
      #  * @prop {number} devicePixelRatio - 発信元のデバイスピクセル比
      #  * @prop {string} landscape - スクリーンショット（base64）
      #  */
      # --------------------------------------------------------------
      _sendUpdateLandscapeHandler: (port) ->
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendUpdateLandscapeHandler", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "updateLandscape"
            body: data

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





























