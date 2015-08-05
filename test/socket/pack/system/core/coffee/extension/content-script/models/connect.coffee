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
    #  * @prop {boolean} isRun - エクステンションの起動状態
    #  * @prop {Object} backgroundScriptSender - Background のスクリプトへデータを送信するオブジェクト
    #  */
    # ------------------------------------------------------------
    defaults: 
      isRun: false
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


    # ------------------------------------------------------------
    initialize: () ->
      console.log "%c[Model] Connect -> initialize", "color: #619db9"

      @listenTo @, "change:isRun", @_changeIsRunHandler
      # @listenTo @, "change:backgroundReceiver", @_changeBackgroundReceiverHandler


    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "%c[Model] Connect -> setup", "color: #619db9"
          defer.resolve()
      
        # イベントリスナーを登録する
        @_setEvents()

        # データの受信
        chrome.extension.onMessage.addListener (request, sender, sendResponse) =>
          console.log "%cReceive Message", "color: #619db9", request, sender, sendResponse

          # background からの通知か判別する
          if request.from? and request.from is "background"
            # エクステンションの起動状態の変化メッセージ
            if request.type? and request.type is "changeIsRun"
              console.log  "coll!"
              @set "isRun", request.body.isRun


        # background にデータを送信
        chrome.runtime.sendMessage
          to: "background"
          from: "contentScriptSetup"
          ,
          (response) =>
            # エクステンションの起動状態が返ってくる
            @set "isRun", response.body.isRun

        onDone()
      .promise()

    # --------------------------------------------------------------
    # /**
    #  * Connect#_setEvents
    #  * イベントリスナーを登録する
    #  */
    # --------------------------------------------------------------
    _setEvents: () ->
      console.log "%c[Model] Connect -> _setEvents", "color: #619db9"

      chrome.runtime.onConnect.addListener (port) =>
        console.log "%c[Model] Connect -> _setEvents | onConnect", "color: #619db9"

        # background からの接続
        if port.name is "background"
          @_setBackgroundPort port

    
    # --------------------------------------------------------------
    # /**
    #  * Connect#_changeIsRunHandler
    #  * background からエクステンションの起動状態を受信した時の処理を設定する 
    #  * @prop {Object} model - BackBone Model Object
    #  * @prop {boolean} isRun - エクステンションの起動状態
    #  */
    # --------------------------------------------------------------
    _changeIsRunHandler: (model, isRun) ->
      console.log "%c[Model] Connect -> _changeIsRunHandler", "color: #619db9", isRun

      if not isRun
        console.log "call"
        @stopListening sn.bb.models.stage, "change:pointerPosition"


      # if isRun
      #   # エクステンションが起動状態であればイベントリスナーを登録する
      #   @listenTo sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler
      # else
      #   # エクステンションが停止状態であればイベントリスナーを破棄する
      #   @stopListening sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler


    # --------------------------------------------------------------
    # /**
    #  * Connect#_setBackgroundPort
    #  * background と接続しているLong-lived なポートの設定をする
    #  * @param {Port} port - 双方向通信を可能にするオブジェクト
    #  * @prop https://developer.chrome.com/extensions/runtime#type-Port
    #  */
    # --------------------------------------------------------------
    _setBackgroundPort: (port) ->
      console.log "%c[Model] Connect -> _setBackgroundPort", "color: #619db9", port

      port.postMessage
        to: "background"
        from: "contentScript"

      # changePointerPositionHandler = (stageModel, pointerPosition) ->
      #   port.postMessage
      #     "test": "test"

      @listenTo sn.bb.models.stage, "change:pointerPosition", @_changePointerPositionHandler(port)

    # --------------------------------------------------------------
    # /**
    #  * Connect#_changePointerPositionHandler
    #  * ポインターの座標に変化があった時のイベントハンドラー
    #  */
    # --------------------------------------------------------------
    _changePointerPositionHandler: (port) ->
      return (stageModel, pointerPosition) ->
        console.log "[Model] Connect -> _changePointerPositionHandler", stageModel, pointerPosition, port

        port.postMessage
          to: "background"
          from: "contentScript"
          body: pointerPosition

      # Background にポインターの座標を通知する
      # @backgroundPort.postMessage
      #   to: "background"
      #   from: "contentScriptSetup"
      #   body:
      #     pointerPosition: pointerPosition



    # _changePointerPositionHandler: (stageModel, pointerPosition) ->
    #   console.log "[Model] Connect -> _changePointerPositionHandler", stageModel, pointerPosition

    #   # Background にポインターの座標を通知する
    #   # @backgroundPort.postMessage
    #   #   to: "background"
    #   #   from: "contentScriptSetup"
    #   #   body:
    #   #     pointerPosition: pointerPosition








