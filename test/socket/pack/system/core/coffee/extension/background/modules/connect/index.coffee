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

        # エクステンションの起動状態に変化があった時のイベントリスナー
        App.vent.on "stageChangeIsRun", @_changeIsRunHandler.bind @
        # タブが変更された時のイベントリスナー
        App.vent.on "stageSelsectedTabId", @_changeSelsectedTabIdHandler.bind @
        # socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出される
        App.vent.on "socketCheckIn", @_sendCheckInHandler.bind @
        # 同じRoom に所属していたユーザーがsoket通信を切断した時に呼び出される
        App.vent.on "socketCheckOut", @_sendCheckOutHandler.bind @

        # スクリーンショットが撮影された時に呼び出される
        @listenTo @, "change:landscape", @_changeLandscapeHandler

        # content script からの通知を受信する
        chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
          # console.log "%c[Connect] ConnectModel | Receive Message", debug.style, request, sender, sendResponse

          # content script からの通知か判別する
          if (request.from? and request.from is "contentScript") and request.type?
            switch request.type
              when "setup"
                console.log "%c[Connect] ConnectModel | Receive Message | setup", debug.style, request, sender, sendResponse
                
                # エクステンションがすでに起動している場合の処理
                if @get "isRun"
                  # contentscript とLong-lived な接続をする
                  contentScriptPort = chrome.tabs.connect sender.tab.id, name: "background"
                  @_setContentScriptPort contentScriptPort

                  # CheckInしているユーザーを取得する
                  @_sendCheckInHandler App.reqres.request "socketGetUsers"


                sendResponse
                  to: "contentScript"
                  from: "background"
                  body:
                    isRun: @get "isRun"

              when "updateLandscape"
                console.log "%c[Connect] ConnectModel | Receive Message | updateLandscape", debug.style, request, sender, sendResponse
                chrome.tabs.captureVisibleTab format: "jpeg",
                  (dataUrl) =>
                    @set "landscape", dataUrl


      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * エクステンションの起動状態に変化があった時に呼び出されるイベントハンドラー
      #  * @param {boolean} isRun - エクステンションの起動状態
      #  */
      # --------------------------------------------------------------
      _changeIsRunHandler: (isRun) ->
        console.log "%c[Connect] ConnectModel -> _changeIsRunHandler", debug.style, isRun

        @set "isRun", isRun

        # content script にデータを送信する
        chrome.tabs.query
          active: true
          currentWindow: true
          ,
          (tabs) =>
            # エクステンションの起動状態をアクティブなTab のcontent script へ通知する
            chrome.tabs.sendMessage tabs[0].id,
              to: "contentScript"
              from: "background"
              type: "changeIsRun"
              body:
                isRun: isRun

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeSelsectedTabIdHandler
      #  * 選択されているタブが変わった時のイベントハンドラー 
      #  * contentScript からデータを受信した時の処理を設定する
      #  * @param {number} tabId - 選択されているタブのID
      #  */
      # -------------------------------------------------------------
      _changeSelsectedTabIdHandler: (tabId) ->
        console.log "%c[Connect] ConnectModel -> _changeSelsectedTabIdHandler", debug.style, tabId

        if @get "isRun"
          contentScriptPort = chrome.tabs.connect tabId, "name": "background"
          @_setContentScriptPort contentScriptPort

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_sendCheckInHandler
      #  * socketサーバーに接続した時、所属するroomに新規ユーザーが追加された時に呼び出されるイベントハンドラーかつ
      #  * Receive Message | setup が発生した時にエクステンションが起動している時にも呼び出される
      #  * アクティブなタブのcontent script にユーザーの一覧を通知する
      #  * @param {[string]} users - 同じRoom に所属するユーザーのSocket ID の配列
      #  */
      # -------------------------------------------------------------
      _sendCheckInHandler: (users) ->
        console.log "%c[Connect] ConnectModel -> _sendCheckInHandler", debug.style, users

        chrome.tabs.query
          active: true
          currentWindow: true
          ,
          (tabs) =>
            if tabs.length > 0
              chrome.tabs.sendMessage tabs[0].id,
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
      _sendCheckOutHandler: (user) ->
        console.log "%c[Connect] ConnectModel -> _sendCheckOutHandler", debug.style, user

        chrome.tabs.query
          active: true
          currentWindow: true
          ,
          (tabs) =>
            if tabs.length > 0
              chrome.tabs.sendMessage tabs[0].id,
                to: "contentScript"
                from: "background"
                type: "checkOut"
                body:
                  user: user

      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_changeIsRunHandler
      #  * スクリーンショットが撮影された時に呼び出されるイベントハンドラー
      #  * @param {Object} Model - BackBone Model Object
      #  * @prop {string} landscape - base64形式のスクリーンショット
      #  */
      # --------------------------------------------------------------
      _changeLandscapeHandler: (model, landscape) ->
        console.log "%c[Connect] ConnectModel -> _changeLandscapeHandler", debug.style


      # --------------------------------------------------------------
      # /**
      #  * ConnectModel#_setContentScriptPort
      #  * contentScript に接続したLong-lived なポートの設定をする
      #  * @param {Port} port - 双方向通信を可能にするオブジェクト
      #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
      #  */
      # --------------------------------------------------------------
      _setContentScriptPort: (port) ->
        console.log "%c[Connect] ConnectModel -> _setContentScriptPort", debug.style

        # メッセージを受信した時の処理
        port.onMessage.addListener (message) =>
          console.log "%c[Connect] ConnectModel | Long-lived Receive Message", debug.style, message

          # content script からの通知か判別する
          if (message.from? and message.from is "contentScript") and message.type?
            switch message.type
              when "pointerMove"
                App.vent.trigger "connectPointerMove", message.body


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





























