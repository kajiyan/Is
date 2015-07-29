# ============================================================
# Background - Stage
module.exports = (sn, $, _) ->
	class Stage extends Backbone.Model
    # ------------------------------------------------------------
    # /** 
    #  * Stage#defaults
    #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
    #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
    #  * @type {Object}
    #  * @prop {boolean} debug - デバッグモードであるかの真偽値
    #  * @prop {number} selsectedTabId - 選択されているタブのID
    #  * @prop {boolean} isBrowserAction - ブラウザアクションが発生したかを示す真偽値
    #  */
    # ------------------------------------------------------------
    defaults: 
      "debug": false
      "selsectedTabId": null
      "isBrowserAction": false


    # --------------------------------------------------------------
    # /**
    #  * Stage#constructor
    #  * @constructor
    #  */
    # --------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Stage -> Constructor"
      super


    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> initialize"

      # 選択されているタブが変更されて時変わった時
      @on "change:selsectedTabId", @_changeselSectedTabIdHandler

      # ブラウザアクションが始まった時に呼び出される
      @on "change:isBrowserAction", @_changeBrowserActionHandler

      # デバッグモードが有効であれば設定を変更する
      # if @get("debug")
      #   @set("isBrowserAction", true)




    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[Model] Stage -> setup"
          defer.resolve()

        @_setEvent()

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
      # chrome.runtime.onConnect.addListener ( port ) ->
        # console.log port.name


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

      # chrome.tabs.onHighlightChanged.addListener @_onHighlightChangedHandler

      # キーボード操作でタブが選択などされた時
      # chrome.tabs.onHighlighted.addListener @_onHighlightedHandler

      # chrome.tabs.onDetached.addListener @_onDetachedHandler

      # chrome.tabs.onAttached.addListener @_onAttachedHandler

      # chrome.tabs.onRemoved.addListener @_onRemovedHandler

      # chrome.tabs.onReplaced.addListener @_onReplacedHandler

      # chrome.tabs.onZoomChange.addListener @_onZoomChangeHandler

    # ------------------------------------------------------------
    # /**
    #  * @_getSelectedTab
    #  * @return {Object} jQuery Deferred
    #  * 
    #  * 結果がresolve であれば現在選択されているタブの Tab Objectを返す 
    #  * reject であればエラーメッセージを返す 
    #  *
    #  */
    # ------------------------------------------------------------
    _getSelectedTab: () ->
      console.log "[Model] Stage -> _getActiveTab"

      return $.Deferred (defer) =>
        chrome.tabs.getSelected (tab) =>
          if tab?
            defer.resolve(tab)
          else
            error = new Error("[Model] Stage -> _getActiveTab: Not Selected Tab")
            defer.reject(error)
      .promise()


    # ------------------------------------------------------------
    # /**
    #  * @_changeselSectedTabIdHandler
    #  */
    # ------------------------------------------------------------
    _changeselSectedTabIdHandler: () =>
      console.log "[Model] Stage -> _changeselSectedTabIdHandler"

      # @_video = document.createElement( "video" ) 

      # $.when(
      #   @_getSelectedTab()
      # ).then(
      #   ( tab ) =>
      #     @_setTabCaptureStream
      #       maxWidth: tab.width
      #       minWidth: tab.width
      #       maxHeight: tab.height
      #       minHeight: tab.height
      # ).then(
      #   ( canplay ) => 
      # )

      # try
      #   chrome.tabCapture.capture
      #     audio: false
      #     video: true
      #     videoConstraints:
      #       mandatory:
      #         # chromeMediaSource: 'tab'
      #         maxWidth: 1000
      #         minWidth: 1000
      #         maxHeight: 1000
      #         minHeight: 1000
      #     ,
      #     ( stream ) ->
      #       video = document.createElement "video"
      #       $("body").append(video)
      #       video.src = window.URL.createObjectURL stream
      #       video.play();
      # catch e
      #   console.log e


    # エクステンションのポップアップの展開状態が変わった時に実行される
    # ------------------------------------------------------------
    _changeBrowserActionHandler: (model, isBrowserAction) =>
      console.log "[Model] Stage -> _changeBrowserActionHandler", model, isBrowserAction

      if isBrowserAction
        chrome.tabs.getSelected (tab) =>
          @set("selsectedTabId", tab.id)


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
      # これまで保持していた selsectedTabId を破棄して再度、selsectedTabIdを設定する
      if @get("isBrowserAction") and (changeInfo.status is "complete") and (@get("selsectedTabId") is tabId) 
        chrome.tabs.getSelected ( tab ) =>
          # ロード終了時も同じタブを開いているか
          if tabId is tab.id
            @set(
              { "selsectedTabId": null },
              { "silent": true }
            )
            @set("selsectedTabId", tabId)
            return


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onMovedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} moveInfo
    #  */
    # ------------------------------------------------------------
    # _onMovedHandler: ( tabId, moveInfo ) ->
    #   console.log "[Model] Stage -> _onMoved", tabId, moveInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onSelectionChangedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    # _onSelectionChangedHandler: ( tabId, selectInfo ) ->
    #   console.log "[Model] Stage -> _onSelectionChanged", tabId, selectInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onActiveChangedHandler 
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    # _onActiveChangedHandler: ( tabId, selectInfo ) ->
    #   console.log "[Model] Stage -> _onActiveChangedHandler", tabId, selectInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onActivatedHandler 
    #  * @param {Object} activeInfo
    #  */
    # ------------------------------------------------------------
    _onActivatedHandler: (activeInfo) =>
      console.log "[Model] Stage -> _onActivatedHandler", activeInfo

      if @get "isBrowserAction"
        @set "selsectedTabId", activeInfo.tabId


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onHighlightChangedHandler 
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    # _onHighlightChangedHandler: (selectInfo) ->
    #   console.log "[Model] Stage -> _onHighlightChangedHandler", selectInfo      


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onHighlighted
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    # _onHighlightedHandler: (highlightInfo) ->
    #   console.log "[Model] Stage -> _onHighlightedHandler", highlightInfo 


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onDetachedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} detachInfo
    #  */
    # ------------------------------------------------------------
    # _onDetachedHandler: (tabId, detachInfo) ->
    #   console.log "[Model] Stage -> _onDetachedHandler", tabId, detachInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onAttachedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} attachInfo
    #  */
    # ------------------------------------------------------------
    # _onAttachedHandler: (tabId, attachInfo) ->
    #   console.log "[Model] Stage -> _onAttachedHandler", tabId, attachInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onRemovedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} removeInfo
    #  */
    # ------------------------------------------------------------
    # _onRemovedHandler: (tabId, removeInfo) ->
    #   console.log "[Model] Stage -> _onRemovedHandler", tabId, removeInfo


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onReplacedHandler
    #  * @param {number} addedTabId
    #  * @param {number} removedTabId
    #  */
    # ------------------------------------------------------------
    # _onReplacedHandler: (addedTabId, removedTabId) ->
    #   console.log "[Model] Stage -> _onReplacedHandler", addedTabId, removedTabId


    # ------------------------------------------------------------
    # /**
    #  * Stage#_onZoomChangeHandler
    #  * @param {Object} zoomChangeInfo
    #  */
    # ------------------------------------------------------------
    # _onZoomChangeHandler: (zoomChangeInfo) ->
    #   console.log "[Model] Stage -> _onZoomChangeHandler", zoomChangeInfo    










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


















