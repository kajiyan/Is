# ============================================================
# Connect
# 
# EVENT
#   - connectInitializeUser
#   - connectChangeLocation
#   - connectWindowResize
#   - connectPointerMove
#   - connectUpdateLandscape
#   - connectAddMemory
#   - connectGetMemory
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
          # ============================================================
          if port.name is "popupScript"
            console.log "%c[Connect] ConnectModel | popupScript - onConnect", debug.style

            changeIsRunHandler = @_changeIsRunHandler.bind(@)(port)
            sendConnectedHandler = @_sendConnectedHandler.bind(@)(port)
            sendJointedHandler = @_sendJointedHandler.bind(@)(port)
            sendDisconnectHandler = @_sendDisconnectHandler.bind(@)(port)

            # Long-lived 接続 切断時の処理を登録する
            port.onDisconnect.addListener =>
              App.vent.off "stageChangeIsRun", changeIsRunHandler
              App.vent.off "socketConnected", sendConnectedHandler
              App.vent.off "socketJointed", sendJointedHandler
              App.vent.off "socketDisconnect", sendDisconnectHandler
              # App.reqres.request "stageStopApp"

            # エクステンションの起動状態に変化があった時のイベントリスナー
            App.vent.on "stageChangeIsRun", changeIsRunHandler
            # socketサーバーへの接続が成功した時
            App.vent.on "socketConnected", sendConnectedHandler
            # socketサーバーの特定のRoomへの入室が完了した時に呼び出される
            App.vent.on "socketJointed", sendJointedHandler
            # socketサーバーsocketサーバーとの通信が切断された時に呼び出される
            App.vent.on "socketDisconnect", sendDisconnectHandler 

            # メッセージを受信した時の処理
            port.onMessage.addListener (message) =>
              if (message.from? and message.from is "popupScript") and message.type?
                switch message.type
                  # --------------------------------------------------------------
                  when "setup"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | popupScript - setup", debug.style, message

                    # エクステンションとsocketの接続情報を返す
                    port.postMessage
                      to: "popupScript"
                      from: "background"
                      type: "setup"
                      body:
                        isRun: @get "isRun"
                        isConnected: App.reqres.request "socketGetIsConnected"
                        isRoomJoin: App.reqres.request "socketGetIsRoomJoin"

          # ============================================================
          if port.name is "contentScript"
            console.log "%c[Connect] ConnectModel | contentScript - onConnect", debug.style

            # スクリーンショット
            landscape = ""
            # 初期化済みのResident IDの配列
            initializedResidents = []

            tabId = port.sender.tab.id
            windowId = port.sender.tab.windowId
            link = port.sender.tab.url

            changeIsRunHandler = @_changeIsRunHandler.bind(@)(port)
            changeActiveInfoHandler = 
              @_changeActiveInfoHandler
                .bind(@)(
                  port
                  ,
                  get: ->
                    return [].concat(initializedResidents)
                  set: (_initializedResidents) ->
                    initializedResidents = _initializedResidents
                  ,
                  getLandscape = ->
                    return landscape: landscape
                )
            sendJointedHandler = @_sendJointedHandler.bind(@)(port)
            sendDisconnectHandler = @_sendDisconnectHandler.bind(@)(port)
            sendAddUser = @_sendAddUser.bind(@)(port)
            sendAddResident = @_sendAddResident
              .bind(@)(
                port,
                get: ->
                  return [].concat(initializedResidents)
                set: (_initializedResidents) ->
                  initializedResidents = _initializedResidents
              )
            sendCheckOutHandler = @_sendCheckOutHandler.bind(@)(port)
            sendUpdateLocation = @_sendUpdateLocation.bind(@)(port)
            sendUpdateWindowSize = @_sendUpdateWindowSize.bind(@)(port)
            sendUpdatePointerHandler = @_sendUpdatePointerHandler.bind(@)(port)
            sendUpdateLandscapeHandler = @_sendUpdateLandscapeHandler.bind(@)(port)
            sendMemoryHandler = @_sendMemoryHandler.bind(@)(port)

            # Long-lived 接続 切断時の処理を登録する
            port.onDisconnect.addListener =>
              App.vent.off "stageChangeIsRun", changeIsRunHandler
              App.vent.off "stageChangeActiveInfo", changeActiveInfoHandler
              App.vent.off "socketJointed", sendJointedHandler
              App.vent.off "socketDisconnect", sendDisconnectHandler
              App.vent.off "socketAddUser", sendAddUser
              App.vent.off "socketAddResident", sendAddResident
              App.vent.off "socketCheckOut", sendCheckOutHandler
              App.vent.off "socketUpdateLocation", sendUpdateLocation
              App.vent.off "socketUpdateWindowSize", sendUpdateWindowSize
              App.vent.off "socketUpdatePointer", sendUpdatePointerHandler
              App.vent.off "socketUpdateLandscape", sendUpdateLandscapeHandler
              App.vent.off "socketResponseMemory", sendMemoryHandler
              port.disconnect()
              console.log "%c[Connect] ConnectModel | onDisconnect", debug.style


            # エクステンションの起動状態に変化があった時のイベントリスナー
            App.vent.on "stageChangeIsRun", changeIsRunHandler
            # タブが切り替わった時のイベントリスナー
            App.vent.on "stageChangeActiveInfo", changeActiveInfoHandler
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
            # 同じRoom に所属しているユーザーの閲覧しているURLに変化があった時に呼び出される
            App.vent.on "socketUpdateLocation", sendUpdateLocation
            # 同じRoom に所属しているユーザーのウインドウサイズに変化があった時に呼び出される
            App.vent.on "socketUpdateWindowSize", sendUpdateWindowSize
            # 同じRoom に所属しているユーザーのポインター座標に変化があった時に呼び出される
            App.vent.on "socketUpdatePointer", sendUpdatePointerHandler
            # 同じRoom に所属しているユーザーのスクリーンショットが更新された時に呼び出される
            App.vent.on "socketUpdateLandscape", sendUpdateLandscapeHandler
            # サーバーに保存されているMemoryを取得した時に呼び出される
            App.vent.on "socketResponseMemory", sendMemoryHandler

            # メッセージを受信した時の処理
            port.onMessage.addListener (message) =>
              # console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

              # content script からの通知か判別する
              if (message.from? and message.from is "contentScript") and message.type?
                switch message.type
                  # --------------------------------------------------------------
                  when "setup"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | setup | #{tabId}", debug.style, message

                    chrome.tabs.captureVisibleTab
                      format: "jpeg"
                      quality: 80
                      ,
                      (dataUrl) =>
                        landscape = dataUrl

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

                  # --------------------------------------------------------------
                  when "initializeUser"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | initializeUser", debug.style, message

                    # 現在選択されているTabの情報を取得する
                    activeInfo = App.reqres.request "stageGetActiveInfo"

                    if activeInfo.tabId is tabId
                      # スクリーンショットを撮影する
                      chrome.tabs.captureVisibleTab
                        format: "jpeg"
                        quality: 80
                        ,
                        (dataUrl) ->
                          landscape = dataUrl

                          App.vent.trigger "connectInitializeUser",
                            position:
                              x: message.body.position.x
                              y: message.body.position.y
                            window:
                              width: message.body.window.width
                              height: message.body.window.height
                            link: link
                            landscape: landscape

                  # --------------------------------------------------------------
                  when "initializeResident"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | initializeResident", debug.style, message

                    # 現在選択されているTabの情報を取得する
                    activeInfo = App.reqres.request "stageGetActiveInfo"

                    if activeInfo.tabId is tabId
                      chrome.tabs.captureVisibleTab
                        format: "jpeg"
                        quality: 80
                        ,
                        (dataUrl) ->
                          landscape = dataUrl

                          App.vent.trigger "connectInitializeResident",
                            toSocketId: message.body.toSocketId
                            position: message.body.position
                            window: message.body.window
                            link: link
                            landscape: landscape

                  # --------------------------------------------------------------
                  when "windowResize"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | windowResize", debug.style, message
                    App.vent.trigger "connectWindowResize", message.body

                  # --------------------------------------------------------------
                  when "pointerMove"
                    # console.log "%c[Connect] ConnectModel | Long-lived Receive Message | pointerMove", debug.style, message
                    App.vent.trigger "connectPointerMove", message.body

                  # --------------------------------------------------------------
                  when "updateLandscape"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | updateLandscape", debug.style, message
                    
                    # 現在選択されているTabの情報を取得する
                    activeInfo = App.reqres.request "stageGetActiveInfo"

                    if activeInfo.tabId is tabId
                      # スクリーンショットを撮影する
                      chrome.tabs.captureVisibleTab
                        format: "jpeg"
                        quality: 80
                        ,
                        (dataUrl) ->
                          landscape = dataUrl

                          App.vent.trigger "connectUpdateLandscape",
                            landscape: landscape

                  # --------------------------------------------------------------
                  when "addMemory"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | addMemory", debug.style, message

                    activeInfo = App.reqres.request "stageGetActiveInfo"

                    if activeInfo.tabId is tabId
                      App.vent.trigger "connectAddMemory",
                        link: port.sender.tab.url
                        window: message.body.window
                        landscape: landscape
                        positions: message.body.positions

                  # --------------------------------------------------------------
                  when "getMemory"
                    console.log "%c[Connect] ConnectModel | Long-lived Receive Message | getMemory", debug.style, message
                    
                    activeInfo = App.reqres.request "stageGetActiveInfo"

                    if activeInfo.tabId is tabId
                      App.vent.trigger "connectGetMemory", message.body




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
            to: port.name
            from: "background"
            type: "changeIsRun"
            body:
              isRun: isRun
              isConnected: App.reqres.request "socketGetIsConnected"
              isRoomJoin: App.reqres.request "socketGetIsRoomJoin"

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeActiveInfoHandler
      #  * 選択されているタブ、ウインドウが変わった時のイベントハンドラー 
      #  * @param {Object} port - Chrome Extentions Port Object
      #  * @param {Object} initializedResidents 
      #  * @prop {Function} get - 初期化済みのResident IDの配列を取得する
      #  * @prop {Function} set - 初期化済みのResident IDの配列を更新する
      #  * @param {Function} getLandscape - 最後に撮影されたスクリーンショット(base64)を取得する
      #  */
      # --------------------------------------------------------------
      _changeActiveInfoHandler: (port, initializedResidents, getLandscape) ->
        # /**
        #  * @param {Object} - activeInfo
        #  * @prop {number} - tabId
        #  * @prop {number} - windowId
        #  */
        return (activeInfo) =>
          console.log "%c[Connect] ConnectModel -> _changeActiveInfoHandler", debug.style, "PORT TabID:#{port.sender.tab.id} | ACTIVE TabID:#{activeInfo.tabId}", initializedResidents.get()

          # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          # リンク、ランドスケープのアップデートもする
          # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          if port.sender.tab.id is activeInfo.tabId
            # 同じroomIdにjoinしているResidentsを取得する
            residents = App.reqres.request "socketGetResidents"
            _initializedResidents = initializedResidents.get()

            for resident, index in residents
              # 表示リストに表示されていないResidentがあるか調べる
              if _.indexOf(_initializedResidents, resident.id) is -1
                # content script にResidentの表示依頼をする
                port.postMessage
                  to: "contentScript"
                  from: "background"
                  type: "addResident"
                  body: resident
            
                # 表示リストに加える
                _initializedResidents.push resident.id
                initializedResidents.set _initializedResidents

            # リンクの情報をアップデートする
            App.vent.trigger "connectChangeLocation", link: port.sender.tab.url
            App.vent.trigger "connectUpdateLandscape", getLandscape()

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendConnectedHandler
      #  * socketサーバーへの接続が成功した時に呼び出されるイベントハンドラー
      #  */
      # -------------------------------------------------------------
      _sendConnectedHandler: (port) ->
        return () =>
          console.log "%c[Connect] ConnectModel -> _sendConnectedHandler", debug.style

          port.postMessage
            to: port.name
            from: "background"
            type: "connected"
            body: 
              isRun: @get "isRun"
              isConnected: App.reqres.request "socketGetIsConnected"
              isRoomJoin: App.reqres.request "socketGetIsRoomJoin"

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendJointedHandler
      #  * socketサーバーの特定のRoomへの入室が完了した時に呼び出されるイベントハンドラー
      #  */
      # -------------------------------------------------------------
      _sendJointedHandler: (port) ->
        # /**
        #  * @param {Object} _data
        #  * @prop {string} status - roomにjoinできたか success | error
        #  * @prop {string} type - errorだった場合、その種類
        #  * @param {Object} body
        #  * @prop {string} body.message - errorだった場合、その内容
        #  */
        return (_data) =>
          console.log "%c[Connect] ConnectModel -> _sendJointedHandler", debug.style

          data = _.extend
            isRun: @get "isRun"
            isConnected: App.reqres.request "socketGetIsConnected"
            isRoomJoin: App.reqres.request "socketGetIsRoomJoin"
          , _data

          if port.name is "popupScript"
            port.postMessage
              to: "popupScript"
              from: "background"
              type: "jointed"
              body: data
            return

          # 現在選択されているTabの情報を取得する
          activeInfo = App.reqres.request "stageGetActiveInfo"

          # アクティブなタブだけにメッセージを送る
          if port.sender.tab.id is activeInfo.tabId
            port.postMessage
              to: "contentScript"
              from: "background"
              type: "jointed"
              body: data

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendDisconnectHandler
      #  * socketサーバーとの通信が切断された時のイベントハンドラー
      #  */
      # -------------------------------------------------------------
      _sendDisconnectHandler: (port) ->
        return (data) =>
          console.log "%c[Connect] ConnectModel -> _sendDisconnectHandler", debug.style, data

          port.postMessage
            to: port.name
            from: "background"
            type: "disconnect"
            body: 
              isRun: @get "isRun"
              isConnected: App.reqres.request "socketGetIsConnected"
              isRoomJoin: App.reqres.request "socketGetIsRoomJoin"

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

          # 現在選択されているTabの情報を取得する
          activeInfo = App.reqres.request "stageGetActiveInfo"

          # アクティブなタブだけにメッセージを送る
          if port.sender.tab.id is activeInfo.tabId
          # if port.sender.tab.id is selsectedTabId
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
      #  * @param {Object} port - Chrome Extentions Port Object
      #  * @param {Object} initializedResidents 
      #  * @prop {Function} get - 初期化済みのResident IDの配列を取得する
      #  * @prop {Function} set - 初期化済みのResident IDの配列を更新する
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

          # 現在選択されているTabの情報を取得する
          # selsectedTabId = App.reqres.request "stageGetSelsectedTabId"

          _initializedResidents = initializedResidents.get()
          _initializedResidents.push data.id

          initializedResidents.set _initializedResidents

          # if port.sender.tab.id is selsectedTabId
          port.postMessage
            to: "contentScript"
            from: "background"
            type: "addResident"
            body: data

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
      #  * 同じRoom に所属していたユーザーの閲覧しているURLの変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # ------------------------------------------------------------
      _sendUpdateLocation: (port) ->
        # /**
        #  * @param {Object} data
        #  * @param {string} id - 同じRoomに所属していたユーザーのSocketID
        #  * @prop {string} link - 接続ユーザーの閲覧しているURL
        #  */
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendUpdateLocation", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "updateLocation"
            body: data

      # ------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendUpdateWindowSize
      #  * 同じRoom に所属していたユーザーのウインドウサイズの変化をsoketが受信した時に呼び出されるイベントハンドラー
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # ------------------------------------------------------------
      _sendUpdateWindowSize: (port) ->
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
      #  * @param {Object} port - Chrome Extentions Port Object
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

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendMemoryHandler
      #  * @param {Object} port - Chrome Extentions Port Object
      #  */
      # --------------------------------------------------------------
      _sendMemoryHandler: (port) ->
        # /**
        #  * @param {Object} data
        #  * @prop {[Memory]} memorys - Memory Documentの配列
        #  */
        (data) =>
          console.log "%c[Connect] ConnectModel -> _sendMemoryHandler", debug.style, data

          port.postMessage
            to: "contentScript"
            from: "background"
            type: "receiveMemory"
            body: data

      # # --------------------------------------------------------------
      # _poupChangeIsRunHandler: (port) ->
      #   return (isRun) =>
      #     console.log "%c[Connect] ConnectModel -> popup | _changeIsRunHandler", debug.style, isRun

      #     @set "isRun", isRun

      #     port.postMessage
      #       to: "poupScript"
      #       from: "background"
      #       type: "changeIsRun"
      #       body:
      #         isRun: isRun


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





























