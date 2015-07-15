# ============================================================
# Stage
module.exports = (sn, $, _) ->
	class Stage extends Backbone.Model
    # ------------------------------------------------------------
    defaults: 
      selsectTabId: null
      isBrowserAction: false
		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Stage -> Constructor"
      super





    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> initialize"

      # ブラウザアクションが始まった時に呼び出される
      @on "change:isBrowserAction", @_changeBrowserActionHandler

      # @listenTo sn.bb.model.overture, "visibility", -> alert ""

      # @on "change:file", @_changeFileHandler
      # @on "change:data", @_changeDataHandler
      # @on "change:id", @_changeIdHandler





    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[Model] Stage -> setup"
          defer.resolve()

        @_setEvent()

        # setInterval =>
        #   console.log "test"
          
        #   try
        #     chrome.tabCapture.capture
        #       audio: false
        #       video: true
        #       videoConstraints:
        #         mandatory:
        #           chromeMediaSource: 'tab'
        #           maxWidth: 1000
        #           minWidth: 1000
        #           maxHeight: 1000
        #           minHeight: 1000
        #       ,
        #       ( stream ) ->
        #         video = document.createElement "video"
        #         $("body").append(video)
        #         video.src = window.URL.createObjectURL stream
        #         video.play();
        #   catch e
        #     console.log e
          

        # , 1000
        

        # @listenTo @, "change:isScroll", @_changeScrollHandler

        # isFirstView の状態がCookie かLocalStrage に残っているか
        # 残っていれば　@set "isFirstView", false

        # for key, model of sn.bb.models
        #   @listenTo model, "popupIn", @_popupInHandler
        #   @listenTo model, "popupOut", @_popupOutHandler

        onDone()
      .promise()

    # ------------------------------------------------------------
    _setEvent: () ->
      console.log "[Model] Stage -> _setEvent"

      # Content Scriptや Browser Action からのデータを受け取る
      chrome.runtime.onConnect.addListener ( port ) ->
        console.log port.name

      # # 新規にタブが開かれた時
      # chrome.tabs.onCreated.addListener @_onCreatedHandler
      
      chrome.tabs.onUpdated.addListener @_onUpdatedHandler
      # # タブの順番を入れ替えた時
      # chrome.tabs.onMoved.addListener @_onMovedHandler
      # # タブが切り替えられた時
      # chrome.tabs.onSelectionChanged.addListener @_onSelectionChangedHandler
      # # タブが切り替えられてアクティブな状態になった時
      # chrome.tabs.onActiveChanged.addListener @_onActiveChangedHandler

      chrome.tabs.onActivated.addListener @_onActivatedHandler

      # chrome.tabs.onHighlightChanged.addListener @_onSelectionChangedHandler

      # chrome.tabs.onHighlighted.addListener @_onDetachedHandler

      # chrome.tabs.onDetached.addListener @_onDetachedHandler

      # chrome.tabs.onAttached.addListener @_onAttachedHandler

      # chrome.tabs.onRemoved.addListener @_onRemovedHandler

      # chrome.tabs.onReplaced.addListener @_onReplacedHandler

      # chrome.tabs.onZoomChange.addListener @_onZoomChangeHandler

    # エクステンション起動時に開いているタブを取得する
    # ------------------------------------------------------------
    _changeBrowserActionHandler: () ->
      console.log "[Model] Stage -> _changeBrowserActionHandler"

      if @get "isBrowserAction"
        chrome.tabs.getSelected ( tab ) =>
          @set "selsectTabId", tab.id


    # ------------------------------------------------------------
    # /**
    #  * @_onCreatedHandler
    #  * @param {Object} tab - https://developer.chrome.com/extensions/tabs#type-Tab
    #  */
    # ------------------------------------------------------------
    _onCreatedHandler: ( tab ) ->
      console.log "[Model] Stage -> _onCreated", tab


    # ------------------------------------------------------------
    # /**
    #  * @_onUpdatedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} changeInfo
    #  * @param {Object} tab - https://developer.chrome.com/extensions/tabs#type-Tab
    #  */
    # ------------------------------------------------------------
    _onUpdatedHandler: ( tabId, changeInfo, tab ) =>
      console.log "[Model] Stage -> _onUpdated", tabId, changeInfo, tab

      # エクステンションを起動した状態で、リロードが行われた場合
      # これまで保持していた selsectTabId を破棄して再度、selsectTabIdを設定する
      if @get( "isBrowserAction" ) and ( changeInfo.status is "complete" ) and ( @get( "selsectTabId" ) is tabId ) 
        @set(
          { "selsectTabId": null },
          { "silent": true }
        )
        @set( "selsectTabId", tabId )

    # ------------------------------------------------------------
    # /**
    #  * @_onMovedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} moveInfo
    #  */
    # ------------------------------------------------------------
    _onMovedHandler: ( tabId, moveInfo ) ->
      console.log "[Model] Stage -> _onMoved", tabId, moveInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onSelectionChangedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    _onSelectionChangedHandler: ( tabId, selectInfo ) ->
      console.log "[Model] Stage -> _onSelectionChanged", tabId, selectInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onActiveChangedHandler 
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    _onActiveChangedHandler: ( tabId, selectInfo ) ->
      console.log "[Model] Stage -> _onActiveChangedHandler", tabId, selectInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onActivatedHandler 
    #  * @param {Object} activeInfo
    #  */
    # ------------------------------------------------------------
    _onActivatedHandler: ( activeInfo ) =>
      console.log "[Model] Stage -> _onActivatedHandler", activeInfo

      if @get "isBrowserAction"
        @set "selsectTabId", activeInfo.tabId


      # chrome.tabCapture.capture
      #   audio: false
      #   video: true
      #   videoConstraints:
      #     mandatory:
      #       chromeMediaSource: 'tab'
      #       maxWidth: 1000
      #       minWidth: 1000
      #       maxHeight: 1000
      #       minHeight: 1000
      #   ,
      #   ( stream ) ->
      #     video = document.createElement "video"
      #     $("body").append(video)
      #     video.src = window.URL.createObjectURL stream
      #     video.play();

    # ------------------------------------------------------------
    # /**
    #  * @_onHighlightChangedHandler 
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    _onHighlightChangedHandler: ( selectInfo ) ->
      console.log "[Model] Stage -> _onHighlightChangedHandler", selectInfo      

    # ------------------------------------------------------------
    # /**
    #  * @_onHighlighted
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    _onHighlightedHandler: ( highlightInfo ) ->
      console.log "[Model] Stage -> _onHighlightedHandler", highlightInfo 

    # ------------------------------------------------------------
    # /**
    #  * @_onDetachedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} detachInfo
    #  */
    # ------------------------------------------------------------
    _onDetachedHandler: ( tabId, detachInfo ) ->
      console.log "[Model] Stage -> _onDetachedHandler", tabId, detachInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} attachInfo
    #  */
    # ------------------------------------------------------------
    _onAttachedHandler: ( tabId, attachInfo ) ->
      console.log "[Model] Stage -> _onAttachedHandler", tabId, attachInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} removeInfo
    #  */
    # ------------------------------------------------------------
    _onRemovedHandler: ( tabId, removeInfo ) ->
      console.log "[Model] Stage -> _onRemovedHandler", tabId, removeInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} addedTabId
    #  * @param {number} removedTabId
    #  */
    # ------------------------------------------------------------
    _onReplacedHandler: ( addedTabId, removedTabId ) ->
      console.log "[Model] Stage -> _onReplacedHandler", addedTabId, removedTabId

    # ------------------------------------------------------------
    # /**
    #  * @_onZoomChangeHandler
    #  * @param {Object} zoomChangeInfo
    #  */
    # ------------------------------------------------------------
    _onZoomChangeHandler: ( zoomChangeInfo ) ->
      console.log "[Model] Stage -> _onZoomChangeHandler", zoomChangeInfo    










    # ------------------------------------------------------------
    _popupInHandler: () ->
      # console.log "Model | Stage -> _popupInHandler"

      # # 初回の表示時だけ処理を分岐させる
      # if not @get "isFirstView"
      #   # ファーストビューでなければスクロールができない状態にする
      #   @set "isScroll", false





    # ------------------------------------------------------------
    _popupOutHandler: () ->
      # console.log "Model | Stage -> _popupOutHandler"

      # # 初回の表示時だけ処理を分岐させる
      # if not @get "isFirstView"
      #   @set "isScroll", true
      # else
      #   @set "isFirstView", false


















