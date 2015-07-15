# ============================================================
# Connect
module.exports = (sn, $, _) ->
	class Connect extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      contentScriptSender: {}
      isBrowserAction: false
		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Connect -> Constructor"
      super



# chrome.tabs.connect

# chrome.extension.onConnect.addListener ( port ) ->
#         console.assert(port.name == "knockknock")
#         port.onMessage.addListener ( msg ) ->
#           if msg.joke is "Knock knock"
#             port.postMessage question: "Who's there?"
#           else if msg.answer is "Madame"
#             port.postMessage question: "Madame who?"
#           else if msg.answer is "Madame... Bovary"
#             port.postMessage question: "I don't get it." 




    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Connect -> initialize"

      # # ブラウザアクションが始まった時に呼び出される
      # @on "change:isBrowserAction", @_changeBrowserActionHandler


    # ------------------------------------------------------------
    setup: () ->
      console.log "[Model] Connect -> setup"
      return $.Deferred (defer) =>
        onDone = =>
          defer.resolve()

        @_setEvent()

        for key, model of sn.bb.models
          @listenTo model, "change:selsectTabId", @_setTabConnect

        onDone()

      .promise()

    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Connect -> _setEvent"

      # chrome.extension.onConnect.addListener ( port ) ->
        # port.postMessage joke: "Knock knock"


    # ------------------------------------------------------------
    _changeBrowserActionHandler: () ->
      console.log "[Model] Connect -> _changeBrowserActionHandler"

      # port = chrome.runtime.connect({name: "hogeChannel"});
      # port.postMessage({msMessage: "myscript.jsからのメッセージ！"});
      # エクステンション起動時に開いているタブを取得する
      chrome.tabs.getSelected ( tab ) =>
        # Tab ID を取得して接続する 
        @_setTabConnect @, tab.id

        # setInterval =>
        #   console.log "send"
        #   @get("contentScriptSender").postMessage({joke: "Knock knock"})
        # , 1000


    # ------------------------------------------------------------
    # /**
    #  * @_setTabConnect 
    #  * @param {Object} model - BackBone  Model Object
    #  * @param {number} tabId
    #  *
    #  * 引数で渡された TabId を持つタブのcontent scriptに対して 
    #  * contentScriptSender という名前で通信を確立する 
    #  * connect はこのモデルの contentScriptSender に格納される 
    #  *
    #  */
    # ------------------------------------------------------------
    _setTabConnect: ( model, tabId ) ->
      console.log "[Model] Connect -> _setTabConnect", model, tabId

      @set( "contentScriptSender", chrome.tabs.connect( tabId, "name": "contentScriptSender" ))












