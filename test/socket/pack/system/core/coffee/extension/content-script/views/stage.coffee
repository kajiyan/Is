# ============================================================
# Stage
module.exports = (sn, $, _) ->
  class Stage extends Backbone.View
    # ------------------------------------------------------------
    # /** 
    #  * Stage#defaults
    #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
    #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
    #  * @type {Object}
    #  * @prop {Object} pointerPosition - ポインターの座標を格納する
    #  * @prop {number} pointerPosition.x - ポインターのx座標
    #  * @prop {number} pointerPosition.y - ポインターのy座標
    #  */
    # ------------------------------------------------------------
    defaults:
      "pointerPosition":
        "x": 0
        "y": 0

    # ------------------------------------------------------------
    # /** 
    #  * Stage#constructor
    #  */
    constructor: () ->
      console.log "[View] Stage -> constructor"
      super

    
    # ------------------------------------------------------------
    el: "body"


    # ------------------------------------------------------------
    events:
      "pointermove": "_pointerMoveHandler"
      # "click .btns__btn": "_setInput"
      # "change .file__input": "_updateInput"
      # "touchstart input[type=\"file\"]":      "_pointerdown"
      # "mousedown input[type=\"file\"]":       "_pointerdown"
      # "MSPointerDown input[type=\"file\"]":   "_pointerdown"
      # "pointerdown input[type=\"file\"]":     "_pointerdown"
      # "touchend input[type=\"file\"]":        "_pointercancel"
      # "touchcancel input[type=\"file\"]":     "_pointercancel"
      # "mouseup input[type=\"file\"]":         "_pointercancel"
      # "MSPointerUp input[type=\"file\"]":     "_pointercancel"
      # "MSPointerCancel input[type=\"file\"]": "_pointercancel"
      # "pointerUp input[type=\"file\"]":       "_pointercancel"
      # "pointercancel input[type=\"file\"]":   "_pointercancel"
      # "change input[type=\"file\"]":          "_change"

    # ------------------------------------------------------------
    initialize: () ->
      console.log "[View] Stage -> initialize"

      console.log @el

      # 初回の表示時に呼び出されるイベントリスナー
      # @listenTo @model, "change:isFirstView", @_firstViewHndler





    # ------------------------------------------------------------
    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "[View] Stage -> setup"
          defer.resolve()

        @$els = @_getElements()

        onDone()
      .promise()


    # --------------------------------------------------------------
    _getElements: () ->
      console.log "[View] Stage -> _getElements"
      result = {}

      return result



    # --------------------------------------------------------------
    # /**
    #  * Stage#_pointerMoveHandler
    #  * @el でpointerMove イベントが発生すると呼ばれるイベントハンドラー
    #  * @param {Object} e - pointermoveイベントのイベントオブジェクト
    #  */
    # --------------------------------------------------------------
    _pointerMoveHandler: (e) ->
      # console.log "[View] Stage -> _pointerMoveHandler"

      @model.set "pointerPosition",
        "x": e.clientX
        "y": e.clientY

      console.log(e.clientX + ' : ' + e.clientY);



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