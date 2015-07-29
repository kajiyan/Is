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
      # "backgroundSender": chrome.extension.connect "name": "fromContentScript"


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
      #  * background との接続情報
      #  * @type {Port}
      #  */
      @backgroundPort

    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Connect -> initialize"

      # @listenTo @, "change:backgroundReceiver", @_changeBackgroundReceiverHandler


    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[Model] Connect -> setup"
          defer.resolve()

        # chrome.runtime.sendMessage({greeting: "hello"}, function(response) {
        #   console.log(response.farewell);
        # });

        # イベントリスナーを登録する
        @_setEvents()

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
      console.log "[Model] Connect -> _setEvents"

      chrome.runtime.onConnect.addListener (port) =>
        console.log "[Model] Connect -> _setEvents | onConnect", port.name

        # background からの接続
        if port.name is "fromBackground"
          @backgroundPort = port
          @_updateBackgroundPort(@backgroundPort)
          @backgroundPort.postMessage "host": "contentScript"

          @listenTo sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler


    # --------------------------------------------------------------
    # /**
    #  * Connect#_updateBackgroundPort
    #  * background からデータを受信した時の処理を設定する 
    #  */
    # --------------------------------------------------------------
    _updateBackgroundPort: (backgroundPort) ->
      console.log "[Model] Connect -> _updateBackgroundPort"
      
      backgroundPort.onMessage.addListener (message) ->
        console.log message


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








