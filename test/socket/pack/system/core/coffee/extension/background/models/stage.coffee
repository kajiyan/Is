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

      @_video = document.createElement "video"
      @_localMediaStream = null



    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> initialize"

      # 選択されているタブが変更されて時変わった時
      @on "change:selsectTabId", @_changeSelsectTabIdHandler

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

      # キーボード操作でタブが選択などされた時
      # chrome.tabs.onHighlighted.addListener @_onHighlightedHandler

      # chrome.tabs.onDetached.addListener @_onDetachedHandler

      # chrome.tabs.onAttached.addListener @_onAttachedHandler

      # chrome.tabs.onRemoved.addListener @_onRemovedHandler

      chrome.tabs.onReplaced.addListener @_onReplacedHandler

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

      return $.Deferred ( defer ) =>
        chrome.tabs.getSelected ( tab ) =>
          if tab?
            defer.resolve( tab )
          else
            error = new Error( "[Model] Stage -> _getActiveTab: Not Selected Tab" )
            defer.reject( error )
      .promise()


    # ------------------------------------------------------------
    # /**
    #  * @_setTabCaptureStream
    #  */
    # ------------------------------------------------------------
    _setTabCaptureStream: ( options ) =>
      console.log "[Model] Stage -> _setTabCaptureStream"

      _options = _.extend
        maxWidth: 1920
        minWidth: 640
        maxHeight: 1080
        minHeight: 480
        ,
        options

      # if @_localMediaStream?
        # @_localMediaStream = null
        # chrome.runtime.reload()
        # return

      console.log _options
      console.log @_video


      chrome.tabs.captureVisibleTab ( dataUrl ) ->
        console.log dataUrl

      # return $.Deferred ( defer ) =>
      #   try
      #     chrome.tabCapture.capture
      #       audio: false
      #       video: true
      #       videoConstraints:
      #         mandatory:
      #           # chromeMediaSource: 'tab'
      #           maxWidth: _options.maxWidth
      #           minWidth: _options.minWidth
      #           maxHeight: _options.maxHeight
      #           minHeight: _options.minHeight
      #       ,
      #       ( stream ) =>
      #         # console.dir stream
      #         @_localMediaStream = stream
      #         # stream.stop()
      #         # @_video = document.createElement( "video" ) 
      #         # @_video.src = window.URL.createObjectURL( stream )
      #         # window.URL.revokeObjectURL( stream )
      #         # @_video.addEventListener "canplay", ( canplay ) ->
      #         #   defer.resolve( canplay )
      #         # @_video.play()
      #     return
      #   catch e
      #     defer.reject( e )
      # .promise()


    # ------------------------------------------------------------
    # /**
    #  * @_changeSelsectTabIdHandler
    #  */
    # ------------------------------------------------------------
    _changeSelsectTabIdHandler: () =>
      console.log "[Model] Stage -> _changeSelsectTabIdHandler"

      @_video = document.createElement( "video" ) 

      $.when(
        @_getSelectedTab()
      ).then(
        ( tab ) =>
          @_setTabCaptureStream
            maxWidth: tab.width
            minWidth: tab.width
            maxHeight: tab.height
            minHeight: tab.height
      ).then(
        ( canplay ) =>
          
      )

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


    # エクステンション起動時に開いているタブを取得する
    # ------------------------------------------------------------
    _changeBrowserActionHandler: () =>
      console.log "[Model] Stage -> _changeBrowserActionHandler"

      if @get "isBrowserAction"
        chrome.tabs.getSelected ( tab ) =>
          @set( "selsectTabId", tab.id )


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
        chrome.tabs.getSelected ( tab ) =>
          # ロード終了時も同じタブを開いているか
          if tabId is tab.id
            @set(
              { "selsectTabId": null },
              { "silent": true }
            )
            @set( "selsectTabId", tabId )
            return


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


















