# ============================================================
# Popup - Stage
module.exports = (sn, $, _) ->
  class Stage extends Backbone.View
    # ------------------------------------------------------------
    # /** 
    #  * Stage#defaults
    #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
    #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
    #  * @type {Object}
    #  */
    # ------------------------------------------------------------
    defaults: {}

    # ------------------------------------------------------------
    # /** 
    #  * Stage#constructor
    #  */
    constructor: () ->
      console.log "%c[View] Stage -> constructor", "color: #d9597b"
      super

    
    # ------------------------------------------------------------
    el: "#js-is-body"


    # ------------------------------------------------------------
    events:
      "submit #js-check-in-form--room_manual": "_checkInManualRoomHandler"
      "submit #js-check-in-form--room_automatic": "_checkInAutomaticRoomHandler"
      "click #js-check-out-button": "_checkOutHandler"


    # ------------------------------------------------------------
    initialize: () ->
      console.log "%c[View] Stage -> initialize", "color: #d9597b"

      # BAC427
      # 619DB9

    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "%c[View] Stage -> setup", "color: #d9597b"
          defer.resolve()

        @$els = @_getElements()

        onDone()
      .promise()


    # --------------------------------------------------------------
    _getElements: () ->
      console.log "%c[View] Stage -> _getElements", "color: #d9597b"
      result = {}

      return result


    # ------------------------------------------------------------
    # /** 
    #  * Stage#_checkInManualRoomHandler
    #  * #js-check-in-button--room_manual からSubmit された時に呼び出されるイベントハンドラー
    #  * @param {Object} e - submit イベントオブジェクト
    #  */
    # ------------------------------------------------------------
    _checkInManualRoomHandler: (e) ->
      e.preventDefault()
      console.log "%c[View] Stage -> _checkInManualRoomHandler", "color: #d9597b"

      window.bg.appRun()


    # ------------------------------------------------------------
    # /** 
    #  * Stage#_checkInAutomaticRoomHandler
    #  * #js-check-in-button--room_automatic からSubmit された時に呼び出されるイベントハンドラー
    #  * @param {Object} e - submit イベントオブジェクト
    #  */
    # ------------------------------------------------------------
    _checkInAutomaticRoomHandler: (e) ->
      e.preventDefault()
      console.log "%c[View] Stage -> _checkInAutomaticRoomHandler", "color: #d9597b"

      window.bg.appRun()


    # ------------------------------------------------------------
    # /** 
    #  * Stage#_checkOutHandler
    #  * #js-check-out-button がクリックされた時に呼び出されるイベントハンドラー
    #  * @param {Object} e - clickイベントオブジェクト
    #  */
    # ------------------------------------------------------------
    _checkOutHandler: (e) ->
      e.preventDefault()
      console.log "%c[View] Stage -> _checkOutHandler", "color: #d9597b"

      window.bg.appStop()
   


    # --------------------------------------------------------------
    # /**
    #  * 引数に指定された durationの時間で@elを画面に表示する。  
    #  * @param {number} duration 表示にかかるまでの時間をms で指定する
    #  * @return {Object} $.Deferred オブジェクトを返す
    #  */
    # --------------------------------------------------------------
    # show: ( duration=400 ) ->
    #   console.log "View | Stage -> show"

    #   return $.Deferred (defer) =>
    #     onDone = =>
    #       defer.resolve()

    #     # 初期値を設定する
    #     @$el
    #       .css "opacity": 0.0
    #       .removeClass "is__hidden"

    #     animate1 = () =>
    #       return $.Deferred (defer) =>
    #         thisDone = ->
    #           defer.resolve()
            
    #         Velocity @$el,
    #           {
    #             "opacity": 1.0
    #           }
    #           {
    #             duration: duration
    #             easing: "ease"
    #             complete: () ->
    #               thisDone()
    #           }
    #       .promise()

    #     $.when(
    #       animate1()
    #     ).then( () =>
    #       onDone()
    #     )
    #   .promise()





    # --------------------------------------------------------------
    # /**
    #  * 引数に指定された durationの時間で@elを画面から非表示する。  
    #  * @param {number} duration 表示にかかるまでの時間をms で指定する
    #  * @return {Object} $.Deferred オブジェクトを返す
    #  */
    # --------------------------------------------------------------
    # hide: ( duration=400 ) ->
    #   console.log "View | Content -> hide"

    #   return $.Deferred (defer) =>
    #     onDone = =>
    #       @$el
    #         .css "opacity": ""
    #         .addClass "is__hidden"
    #       defer.resolve()

    #     # 初期値を設定する
    #     @$el
    #       .css "opacity": 1.0
    #       .removeClass "is__hidden"

    #     animate1 = () =>
    #       return $.Deferred (defer) =>
    #         thisDone = ->
    #           defer.resolve()
            
    #         Velocity @$el,
    #           {
    #             "opacity": 0.0
    #           }
    #           {
    #             duration: duration
    #             easing: "ease"
    #             complete: () ->
    #               thisDone()
    #           }
    #       .promise()

    #     $.when(
    #       animate1()
    #     ).then( () =>
    #       onDone()
    #     )
    #   .promise()