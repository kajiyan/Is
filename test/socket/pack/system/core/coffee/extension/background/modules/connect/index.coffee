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
          # 初期化済みのResident IDの配列
          initializedResidents = []

          tabId = port.sender.tab.id
          windowId = port.sender.tab.windowId
          link = port.sender.tab.url

          # socketDisconnect

          changeIsRunHandler = @_changeIsRunHandler.bind(@)(port)
          changeSelsectedTabIdHandler = @_changeSelsectedTabIdHandler.bind(@)(port, initializedResidents)
          sendJointedHandler = @_sendJointedHandler.bind(@)(port)
          sendDisconnectHandler = @_sendDisconnectHandler.bind(@)(port)
          sendAddUser = @_sendAddUser.bind(@)(port)
          sendAddResident = @_sendAddResident.bind(@)(port, initializedResidents)
          sendCheckOutHandler = @_sendCheckOutHandler.bind(@)(port)
          sendUpdateWindowSize = @_sendUpdateWindowSize.bind(@)(port)
          sendUpdatePointerHandler = @_sendUpdatePointerHandler.bind(@)(port)
          sendUpdateLandscapeHandler = @_sendUpdateLandscapeHandler.bind(@)(port)

          # Long-lived 接続 切断時の処理を登録する
          port.onDisconnect.addListener =>
            App.vent.off "stageChangeIsRun", changeIsRunHandler
            App.vent.off "stageSelsectedTabId", changeSelsectedTabIdHandler
            App.vent.off "socketJointed", sendJointedHandler
            App.vent.off "socketDisconnect", sendDisconnectHandler 
            App.vent.off "socketAddUser", sendAddUser
            App.vent.off "socketAddResident", sendAddResident
            App.vent.off "socketCheckOut", sendCheckOutHandler
            App.vent.off "socketUpdateWindowSize", sendUpdateWindowSize
            App.vent.off "socketUpdatePointer", sendUpdatePointerHandler
            App.vent.off "socketUpdateLandscape", sendUpdateLandscapeHandler
            port.disconnect()
            console.log "%c[Connect] ConnectModel | onDisconnect", debug.style


          if port.name is "contentScript"
            console.log "%c[Connect] ConnectModel | onConnect", debug.style

            # エクステンションの起動状態に変化があった時のイベントリスナー
            App.vent.on "stageChangeIsRun", changeIsRunHandler
            # タブが切り替わった時のイベントリスナー
            App.vent.on "stageSelsectedTabId", changeSelsectedTabIdHandler
            # socketサーバーの特定のRoomへの入室が完了した時に呼び出される
            App.vent.on "socketJointed", sendJointedHandler
            # socketサーバーsocketサーバーとの通信が切断された時に呼び出される
            App.vent.on "socketDisconnect", sendDisconnectHandler 
            # socketサーバーから所属するroomに新規ユーザーが追加された時に呼び出される
            App.vent.on "socketAddUser", sendAddUser
            # socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出される
            App.vent.on "socketAddResident", sendAddResident
            # 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出される
            App.vent.on "socketCheckOut", sendCheckOutHandler
            # 同じRoom に所属しているユーザーのウインドウサイズに変化があった時に呼び出される
            App.vent.on "socketUpdateWindowSize", sendUpdateWindowSize
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
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup | #{tabId}", debug.style, message

                    port.postMessage
                      to: "contentScript"
                      from: "background"
                      type: "setup"
                      body:
                        isRun: @get "isRun"

                    # エクステンションがすでに起動している場合の処理
                    if @get "isRun"
                      # 同じroomIdにjoinしているユーザーを取得する
                      residents = App.reqres.request "socketGetResidents"

                      for resident, index in residents
                        # 表示リストに表示されていないResidentがあるか調べる
                        if _.indexOf(initializedResidents, resident.id) is -1
                          # content script にResidentの表示依頼をする
                          port.postMessage
                            to: "contentScript"
                            from: "background"
                            type: "addResident"
                            body: resident
                      
                          # 表示リストに加える
                          initializedResidents.push resident.id


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

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeSelsectedTabIdHandler
      #  */
      # --------------------------------------------------------------
      _changeSelsectedTabIdHandler: (port, initializedResidents) ->
        return (tabId) =>
          console.log "%c[Connect] ConnectModel -> _changeSelsectedTabIdHandler", debug.style, "PORT TabID:#{port.sender.tab.id} | ACTIVE TabID:#{tabId}", initializedResidents

          # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          # リンク、ランドスケープのアップデートもする
          # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          if port.sender.tab.id is tabId
            # 同じroomIdにjoinしているResidentsを取得する
            residents = App.reqres.request "socketGetResidents"

            for resident, index in residents
              # 表示リストに表示されていないResidentがあるか調べる
              if _.indexOf(initializedResidents, resident.id) is -1
                # content script にResidentの表示依頼をする
                port.postMessage
                  to: "contentScript"
                  from: "background"
                  type: "addResident"
                  body: resident
            
                # 表示リストに加える
                initializedResidents.push resident.id

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

          # 現在選択されているTabのIDを取得する
          selsectedTabId = App.reqres.request "stageGetSelsectedTabId"

          # アクティブなタブだけにメッセージを送る
          if port.sender.tab.id is selsectedTabId
            port.postMessage
              to: "contentScript"
              from: "background"
              type: "jointed"
              body: {}

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendDisconnectHandler
      #  * socketサーバーとの通信が切断された時のイベントハンドラー
      #  */
      # -------------------------------------------------------------
      _sendDisconnectHandler: (port) ->
        return () =>
          console.log "%c[Connect] ConnectModel -> _sendDisconnectHandler", debug.style

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "disconnect"
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
      #  * ConnectModel#_sendAddResident
      #  * 同じRoomに所属するユーザーの初期化に必要なデータを受信したときのイベントハンドラー
      #  * content script に既存ユーザーの表示依頼(addResident)を発信する
      #  * portに紐づけて表示中のResidentのIDを保存する
      #  * @param {Array} initializedResidents - 初期化済みのResident IDの配列
      #  */
      # -------------------------------------------------------------
      _sendAddResident: (port, initializedResidents) ->
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
          console.log "%c[Connect] ConnectModel -> _sendAddResident | #{port.sender.tab.id}", debug.style, data

          # 現在選択されているTabのIDを取得する
          selsectedTabId = App.reqres.request "stageGetSelsectedTabId"

          # if port.sender.tab.id is selsectedTabId
          initializedResidents.push data.id

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "addResident"
            body: data

      # # --------------------------------------------------------------
      # # /**
      # #  * ConnectModel#_sendCheckInHandler
      # #  * socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出されるイベントハンドラーかつ
      # #  * Receive Message | setup が発生した時にエクステンションが起動している時にも呼び出される
      # #  * アクティブなタブのcontent script にユーザーの一覧を通知する
      # #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      # #  */
      # # -------------------------------------------------------------
      # _sendCheckInHandler: (port) ->
      #   return (users) =>
      #     console.log "%c[Connect] ConnectModel -> _sendCheckInHandler", debug.style, users

      #     port.postMessage
      #       to: "contentScript"
      #       from: "background"
      #       type: "checkIn"
      #       body:
      #         users: users

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_receiveCheckOutHandler
      #  * 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出されるイベントハンドラー
      #  * アクティブなタブのcontent script に切断したユーザーのSocket IDを通知する
      #  */
      # ------------------------------------------------------------
      _sendCheckOutHandler: (port) ->
        # /**
        #  * @param {Object} data
        #  * @param {string} id - 同じRoomに所属していたユーザーのSocketID
        #  */
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendCheckOutHandler", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "checkOut"
            body: data

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendUpdateWindowSize
      #  * 同じRoom に所属していたユーザーのウインドウサイズの変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # ------------------------------------------------------------
      _sendUpdateWindowSize: (port)->
        # /**
        #  * @param {Object} data
        #  * @prop {string} id - 発信者のsocket.id
        #  * @prop {number} window.width - 発信者のwindowの幅
        #  * @prop {number} window.height - 発信者のwindowの高さ
        #  */
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendUpdateWindowSize", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "updateWindowSize"
            body: data

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendUpdatePointerHandler
      #  * 同じRoom に所属していたユーザーのポインターの座標の変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * アクティブなタブのcontent script にポインター座標の情報を通知する
      #  */
      # ------------------------------------------------------------
      _sendUpdatePointerHandler: (port) ->
        # /**
        #  * @param {Object} data
        #  * @prop {string} id - 発信元のsocket.id
        #  * @prop {number} position.x - 発信者のポインターのx座標
        #  * @prop {number} position.y - 発信者のポインターのy座標
        #  */
        (data) =>
          # console.log "%c[Connect] ConnectModel -> _sendUpdatePointerHandler", debug.style, data

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





























