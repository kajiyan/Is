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
      "selsectedTabId": null


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

      @listenTo sn.bb.models.stage, "change:selsectedTabId", @_changeSelsectedTabIdHandler

      # chrome.runtime.onConnect.addListener (port) =>
      #   console.log "[Model] Connect -> _setEvents | onConnect", port

        # contentScript からの接続
        # if port.name is "fromBackground"


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
      console.log "[Model] Connect -> _changeSelsectedTabIdHandler", stageModel, tabId
      
      # tab のcontent script に接続する
      @contentScriptPort = chrome.tabs.connect(tabId, "name": "fromBackground")

      # メッセージの送信
      @contentScriptPort.postMessage joke: "host": "background"

      # メッセージの受信
      @contentScriptPort.onMessage.addListener (message) ->
        console.log message

        # content script からポインターの座標が変更された時に通知される
        if message.name is "updatePointerPosition"
          console.log message.pointerPosition












