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
    defaults: 
      "isRun": false
      # "selsectedTabId": null


    # --------------------------------------------------------------
    # /**
    #  * Connect#constructor
    #  * @constructor
    #  */
    # --------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Connect -> Constructor"
      super

      # /**
      #  * content script との接続情報
      #  * @type {Port}
      #  */
      @contentScriptPort


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
      console.log "[Model] Connect -> _setEvents"

      chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
        console.log request, sender, sendResponse

      # chrome.runtime.onConnect.addListener (port) =>
        # console.log "%c[Model] Connect -> _setEvents | onConnect", "color: #999999", port

      @listenTo sn.bb.models.stage, "change:isRun", @_changeIsRunHandler
      @listenTo sn.bb.models.stage, "change:selsectedTabId", @_changeSelsectedTabIdHandler

      # @listenTo sn.bb.models.stage, "change:isBrowserAction", @_changeIsBrowserActionHandler

        # contentScript からの接続
        # if port.name is "fromBackground"


    # --------------------------------------------------------------
    _changeIsRunHandler: (stageModel, isRun) ->
      console.log "%c[Model] Connect -> _changeIsRunHandler", "color: #999999", stageModel, isRun

      @set "isRun", isRun



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

      isRun = @get "isRun"

      # tab のcontent script に接続する
      # appが起動していなくても接続する必要が有る
      @contentScriptPort = chrome.tabs.connect tabId, "name": "background"

      # メッセージの送信
      @contentScriptPort.postMessage "isRun": isRun

      # エクステンションが起動中であるか
      if isRun
        # メッセージの受信
        @contentScriptPort.onMessage.addListener (message) =>
          # console.log message

          # content script からポインターの座標が変更された時に通知される
          if message.name is "updatePointerPosition"
            console.log message.pointerPosition
      else
        @contentScriptPort.postMessage
          "status": "disconnect"


    # _changeIsBrowserActionHandler: (stageModel, isBrowserAction) ->
    #   if not isBrowserAction
    #     @contentScriptPort.postMessage "exit"










