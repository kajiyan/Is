# ============================================================
# Connect
module.exports = (sn, $, _) ->
	class Connect extends Backbone.Model
    # ------------------------------------------------------------
    # /** 
    #  * Stage#defaults
    #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
    #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
    #  * @type {Object}
    #  * @prop {Object} backgroundScriptSender - Background のスクリプトへデータを送信するオブジェクト
    #  */
    # ------------------------------------------------------------
    defaults: {}
      # "backgroundReceiver": {}
      # "backgroundSender": chrome.extension.connect "name": "contentScript"


    # --------------------------------------------------------------
    # /**
    #  * Connect#constructor
    #  * @constructor
    #  */
    # --------------------------------------------------------------
    constructor: () ->
      console.log "%c[Model] Connect -> Constructor", "color: #619db9"
      super

      # /**
      #  * background との接続情報
      #  * @type {Port}
      #  */
      @backgroundPort

    # ------------------------------------------------------------
    initialize: () ->
      console.log "%c[Model] Connect -> initialize", "color: #619db9"

      # @listenTo @, "change:backgroundReceiver", @_changeBackgroundReceiverHandler


    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "%c[Model] Connect -> setup", "color: #619db9"
          defer.resolve()

        # @backgroundSender = chrome.extension.connect "name": "contentScript"

        chrome.runtime.sendMessage greeting: "hello", (response) ->
          console.log(response)

        # chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
        #   console.log request, sender, sendResponse


        # イベントリスナーを登録する
        @_setEvents()

        # chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
        #   console.log request, sender, sendResponse

        # @get("backgroundScriptSender").postMessage joke: "fromContentScript"

        onDone()
      .promise()

    # --------------------------------------------------------------
    # /**
    #  * Connect#_setEvents
    #  * イベントリスナーを登録する
    #  */
    # --------------------------------------------------------------
    _setEvents: () ->
      console.log "[Model] Connect -> _setEvents", new Date()

      chrome.runtime.onConnect.addListener (port) =>
        console.log "[Model] Connect -> _setEvents | onConnect", port

        # background からの接続
        if port.name is "background"
          @backgroundPort = port
          @_updateBackgroundPort(@backgroundPort)
          # @backgroundPort.postMessage "host": "contentScript"

          # @listenTo sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler


    # --------------------------------------------------------------
    # /**
    #  * Connect#_updateBackgroundPort
    #  * background からデータを受信した時の処理を設定する 
    #  */
    # --------------------------------------------------------------
    _updateBackgroundPort: (backgroundPort) ->
      console.log "[Model] Connect -> _updateBackgroundPort"
      
      backgroundPort.onMessage.addListener (message) =>
        console.log message

        # エクステンションが起動中
        if (message.isRun?) and (message.isRun)
          @listenTo sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler

        # エクステンションが停止中
        if (message.isRun?) and (not message.isRun)
          @stopListening sn.bb.models.stage, "change:pointerPosition", () -> alert "stop"

        # else
        #  イベント解除

    # --------------------------------------------------------------
    # /**
    #  * Connect#_changePointerPositionHandler
    #  * ポインターの座標に変化があった時のイベントハンドラー
    #  */
    # --------------------------------------------------------------
    _changePointerPositionHandler: (stageModel, pointerPosition) ->
      console.log "[Model] Connect -> _changePointerPositionHandler", stageModel, pointerPosition

      # Background にポインターの座標を通知する
      @backgroundPort.postMessage
        "name": "updatePointerPosition"
        "pointerPosition": pointerPosition








