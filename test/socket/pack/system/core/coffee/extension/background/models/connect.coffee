# ============================================================
# Background - Connect
module.exports = (sn, $, _) ->
	class Connect extends Backbone.Model
    # ------------------------------------------------------------
    # /** 
    #  * Connect#defaults
    #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
    #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
    #  * @type {Object}
    #  * @prop {number} selsectedTabId - 選択されているタブのID
    #  */
    # ------------------------------------------------------------
    defaults: {}


    # --------------------------------------------------------------
    # /**
    #  * Connect#constructor
    #  * @constructor
    #  */
    # --------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Connect -> Constructor"
      super


    # --------------------------------------------------------------
    # /**
    #  * Connect#initialize
    #  */
    # --------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Connect -> initialize"

      # @listenTo @, "change:contentScriptReceiver", @_changeContentScriptReceiverHandler
      # @listenTo @, "change:selsectedTabId", @_changeSelsectedTabIdHandler


    # ------------------------------------------------------------
    setup: () ->
      console.log "[Model] Connect -> setup"
      return $.Deferred (defer) =>
        onDone = =>
          defer.resolve()

        @_setEvents()

        onDone()
      .promise()

    # --------------------------------------------------------------
    # /**
    #  * Connect#_setEvents
    #  * イベントリスナーを登録する
    #  */
    # --------------------------------------------------------------
    _setEvents: () ->
      console.log "%c[Model] Connect -> _setEvents", "color: #999999"

      # エクステンションの起動状態に変化があった時のイベントリスナー
      @listenTo sn.bb.models.stage, "change:isRun", @_changeIsRunHandler
      @listenTo sn.bb.models.stage, "change:selsectedTabId", @_changeSelsectedTabIdHandler

      # content script からの通知を受信する
      chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
        console.log "%cReceive Message", "color: #999999", request, sender, sendResponse
        # console.log if sender.tab then "from a content script:" + sender.tab.url else "from the extension"
        # console.log request, sender, sendResponse
        
        isRun = sn.bb.models.stage.get "isRun"

        if isRun
          # エクステンションが起動状態
          contentScriptPort = chrome.tabs.connect sender.tab.id, name: "background"
          @_setContentScriptPort contentScriptPort
      # else
        # エクステンションが停止状態

        # content script からの通知か判別する
        if request.from? and request.from is "contentScriptSetup"
          sendResponse
            to: "contentScript"
            from: "background"
            body:
              isRun: isRun


    # --------------------------------------------------------------
    # /**
    #  * Connect#_changeIsRunHandler
    #  * エクステンションの起動状態に変化があった時に呼び出されるイベントハンドラー
    #  * @param {Object} stageModel - BackBone Model Object
    #  * @param {boolean} isRun - エクステンションの起動状態
    #  */
    # --------------------------------------------------------------
    _changeIsRunHandler: (stageModel, isRun) ->
      console.log "%c[Model] Connect -> _changeIsRunHandler", "color: #999999", stageModel, isRun

      # content script にデータを送信する
      chrome.tabs.query
        active: true
        currentWindow: true
        ,
        (tabs) =>
          console.log tabs[0].id

          # エクステンションの起動状態をアクティブなTab のcontent script へ通知する
          chrome.tabs.sendMessage tabs[0].id,
            to: "contentScript"
            from: "background"
            type: "changeIsRun"
            body:
              isRun: isRun # エクステンションが起動状態
            ,
            (response) ->
              console.log response


    # --------------------------------------------------------------
    # /**
    #  * Connect#_setContentScriptPort
    #  * contentScript に接続したLong-lived なポートの設定をする
    #  * @param {Port} port - 双方向通信を可能にするオブジェクト
    #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
    #  */
    # --------------------------------------------------------------
    _setContentScriptPort: (port) ->
      console.log "%c[Model] Connect -> _setContentScriptPort", "color: #999999"

      # メッセージを受信した時の処理
      port.onMessage.addListener (message) =>
        console.log message

        # contentScript からのデータか
        if message.from? and message.from is "contentScript"
          if message.body? and message.body.x? and message.body.y?
            # pointerMove イベントを発火する
            # [model] socket がlisten
            @trigger "pointerMove", message.body


    # --------------------------------------------------------------
    # /**
    #  * Connect#_changeSelsectedTabIdHandler
    #  * selsectedTabId に変化があった時のイベントハンドラー 
    #  * contentScript からデータを受信した時の処理をする 
    #  * @param {Object} stageModel - BackBone Model Object
    #  * @param {number} tabId - 選択されているタブのID
    #  */
    # --------------------------------------------------------------
    _changeSelsectedTabIdHandler: (stageModel, tabId) ->
      console.log "%c[Model] Connect -> _changeSelsectedTabIdHandler", "color: #999999", stageModel, tabId, new Date()

      isRun = sn.bb.models.stage.get "isRun"

      if isRun
        contentScriptPort = chrome.tabs.connect tabId, "name": "background"
        @_setContentScriptPort contentScriptPort


    #   # tab のcontent script に接続する
    #   # appが起動していなくても接続する必要が有る
    #   @contentScriptPort = chrome.tabs.connect tabId, "name": "background"

    #   # メッセージの送信
    #   @contentScriptPort.postMessage "isRun": isRun

    #   # エクステンションが起動中であるか
    #   if isRun
    #     # メッセージの受信
    #     @contentScriptPort.onMessage.addListener (message) =>
    #       # console.log message

    #       # content script からポインターの座標が変更された時に通知される
    #       if message.name is "updatePointerPosition"
    #         console.log message.pointerPosition
    #   else
    #     @contentScriptPort.postMessage
    #       "status": "disconnect"










