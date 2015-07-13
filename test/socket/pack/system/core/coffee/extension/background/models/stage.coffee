# ============================================================
# Stage
module.exports = (sn, $, _) ->
	class Stage extends Backbone.Model
    # ------------------------------------------------------------
    defaults: {}
		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "[Model] Stage -> Constructor"
      super





    # ------------------------------------------------------------
    initialize: () ->
      console.log "[Model] Stage -> initialize"

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

      # 新規にタブが開かれた時
      chrome.tabs.onCreated.addListener @_onCreatedHandler
      
      chrome.tabs.onUpdated.addListener @_onUpdatedHandler
      # タブの順番を入れ替えた時
      chrome.tabs.onMoved.addListener @_onMovedHandler
      # タブが切り替えられた時
      chrome.tabs.onSelectionChanged.addListener @_onSelectionChangedHandler
      # タブが切り替えられてアクティブな状態になった時
      chrome.tabs.onActiveChanged.addListener @_onActiveChangedHandler

      chrome.tabs.onActivated.addListener @_onActivatedHandler

# chrome.tabs.onHighlightChanged.addListener ( e ) ->
#   console.log "onHighlightChanged", e

# chrome.tabs.onHighlighted.addListener ( e ) ->
#   console.log "onHighlighted", e

# chrome.tabs.onDetached.addListener ( e ) ->
#   console.log "onDetached", e

# chrome.tabs.onAttached.addListener ( e ) ->
#   console.log "onAttached", e

# chrome.tabs.onRemoved.addListener ( e ) ->
#   console.log "onRemoved", e

# chrome.tabs.onReplaced.addListener ( e ) ->  
#   console.log "onReplaced", e

# chrome.tabs.onZoomChange.addListener ( e ) ->  
#   console.log "onZoomChange", e


    # ------------------------------------------------------------
    # /**
    #  * @_onCreatedHandler
    #  * @param {Object} tab - https://developer.chrome.com/extensions/tabs#type-Tab
    #  */
    # ------------------------------------------------------------
    _onCreatedHandler: ( tab ) ->
      console.log "onCreated", tab

    # ------------------------------------------------------------
    # /**
    #  * @_onUpdatedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} changeInfo
    #  * @param {Object} tab - https://developer.chrome.com/extensions/tabs#type-Tab
    #  */
    # ------------------------------------------------------------
    _onUpdatedHandler: ( tabId, changeInfo, tab ) ->
      console.log "onUpdated", tabId, changeInfo, tab

    # ------------------------------------------------------------
    # /**
    #  * @_onMovedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} moveInfo
    #  */
    # ------------------------------------------------------------
    _onMovedHandler: ( tabId, moveInfo ) ->
      console.log "onMoved", tabId, moveInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onSelectionChangedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    _onSelectionChangedHandler: ( tabId, selectInfo ) ->
      console.log "onSelectionChanged", tabId, selectInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onActiveChangedHandler 
    #  * @param {number} tabId - タブID
    #  * @param {Object} selectInfo - { windowId: (number) }
    #  */
    # ------------------------------------------------------------
    _onActiveChangedHandler: ( tabId, selectInfo ) ->
      console.log "onActiveChangedHandler", tabId, selectInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onActivatedHandler 
    #  * @param {Object} activeInfo
    #  */
    # ------------------------------------------------------------
    _onActivatedHandler: ( activeInfo ) ->
      console.log "onActivatedHandler", activeInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onHighlightChangedHandler 
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    _onHighlightChangedHandler: ( selectInfo ) ->
      console.log "onHighlightChangedHandler", selectInfo      

    # ------------------------------------------------------------
    # /**
    #  * @_onHighlighted
    #  * @param {Object} selectInfo
    #  */
    # ------------------------------------------------------------
    _onHighlightedHandler: ( highlightInfo ) ->
      console.log "onHighlightedHandler", highlightInfo 

    # ------------------------------------------------------------
    # /**
    #  * @_onDetachedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} detachInfo
    #  */
    # ------------------------------------------------------------
    _onDetachedHandler: ( tabId, detachInfo ) ->
      console.log "onDetachedHandler", tabId, detachInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} attachInfo
    #  */
    # ------------------------------------------------------------
    _onAttachedHandler: ( tabId, attachInfo ) ->
      console.log "_onAttachedHandler", tabId, attachInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} tabId - タブID
    #  * @param {Object} removeInfo
    #  */
    # ------------------------------------------------------------
    _onRemovedHandler: ( tabId, removeInfo ) ->
      console.log "_onRemovedHandler", tabId, removeInfo

    # ------------------------------------------------------------
    # /**
    #  * @_onReplacedHandler
    #  * @param {number} addedTabId
    #  * @param {number} removedTabId
    #  */
    # ------------------------------------------------------------
    _onReplacedHandler: ( addedTabId, removedTabId ) ->
      console.log "_onReplacedHandler", addedTabId, removedTabId

    # ------------------------------------------------------------
    # /**
    #  * @_onZoomChangeHandler
    #  * @param {Object} zoomChangeInfo
    #  */
    # ------------------------------------------------------------
    _onZoomChangeHandler: ( zoomChangeInfo ) ->
      console.log "_onZoomChangeHandler", ZoomChangeInfo    









    # ------------------------------------------------------------
    _changeScrollHandler: () ->
      # console.log "Model | Stage -> _changeScrollHandler"





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


















