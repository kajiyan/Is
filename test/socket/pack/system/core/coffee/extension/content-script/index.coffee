# popupとの連携
# chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
#   console.log(msg, sender, sendResponse)
  
#   ret = $('title').text()
#   dev = $('title').text()
#   sendResponse { title: ret }

do (window=window, document=document, $=jQuery) ->
  "use strict"

  window.sn = {}

  window.requestAnimationFrame = do ->
    return window.requestAnimationFrame or
      window.webkitRequestAnimationFrame or
      window.mozRequestAnimationFrame or
      window.oRequestAnimationFrame or
      window.msRequestAnimationFrame or
      (callback, fps) ->
        window.setTimeout callback, 1000 / fps
        return

  window.cancelAnimationFrame = do ->
    return window.cancelAnimationFrame or
      window.webkitCancelAnimationFrame or
      window.webkitCancelRequestAnimationFrame or
      window.mozCancelAnimationFrame or
      window.mozCancelRequestAnimationFrame or
      window.msCancelAnimationFrame or
      window.msCancelRequestAnimationFrame or
      window.oCancelAnimationFrame or
      window.oCancelRequestAnimationFrame or
      (id) ->
        window.clearTimeout id
        return

  # ============================================================
  # TypeFrameWork
  # ============================================================
  sn.tf = new TypeFrameWork()

  # ============================================================
  # Library
  # ============================================================
  jQBridget = require "jquery-bridget"
  
  require "pepjs/dist/pep.min"
  require "backbone.marionette/lib/backbone.marionette.min"
  require "velocity/velocity.min"
  require "velocity/velocity.ui.min"

  # ============================================================
  # APPLICATION
  # ============================================================
  Extension = new Backbone.Marionette.Application()

  # ============================================================
  # MODULES
  sn.modules =
    stage: require("./modules/stage/index")(Extension, sn, $, _)
    connect: require("./modules/connect/index")(Extension, sn, $, _)


  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->

      debug = style: "background-color: DarkBlue; color: #ffffff;"

      # ============================================================
      #  EXTENSION MODULE
      # ============================================================
      Extension.module "ExtensionModule", (ExtensionModule, Extension, Backbone, Marionette, $, _) ->
        console.log "%c[Extension] ExtensionModule", debug.style

        # Extension のベースになるDOM を生成する
        isEl = document.createElement "div"
        
        # Extension のView にID をつける
        isEl.id = chrome.runtime.id

        isElShadowRoot = isEl.createShadowRoot()

        isElShadowRoot.innerHTML = """
          <style>
            .is-debug {
              -moz-box-shadow: black 0px 0px 0px 1px inset;
              -webkit-box-shadow: black 0px 0px 0px 1px inset;
              box-shadow: black 0px 0px 0px 1px inset;
              background-color: rgba(204, 204, 204, 0.5);
            }

            .is-debug * {
              -moz-box-shadow: black 0px 0px 0px 1px inset;
              -webkit-box-shadow: black 0px 0px 0px 1px inset;
              box-shadow: black 0px 0px 0px 1px inset;
              background-color: rgba(204, 204, 204, 0.5);
            }

            .is-hidden {
              position: fixed;
              top: 0;
              left: 0;
              visibility: hidden;
              clip: rect(0 0 0 0);
            }

            .is {}

            .is .lover {
              position: fixed;
              left: 0;
              top: 0;
            }

            .is .memory {
              position: fixed;
              left: 0;
              top: 0;
              z-index: 2147483647;
            }

            .is .location {
              width: 0;
              height: 0;
              position: fixed;
              left: 0;
              top: 0;
              z-index: 2147483646;
              cursor: default;
            }

            .is .body {
              vertical-align: top;;
              width: 16px;
              height: 22px;
              position: fixed;
              left: 0;
              top: 0;
              z-index: 2147483647;
            }

            .is .landscape {
              background-repeat: no-repeat;
              background-position: center;
              width: 100%;
              height: 100%;
              position: fixed;
              left: 0;
              top: 0;
              z-index: 2147483646;
            }
          </style>
        """

        # Template の生成
        isTemplate = document.createElement "template"
        isTemplate.id = "is-template-#{chrome.runtime.id}"
        isTemplate.innerHTML = """
          <div id="is" class="is">
            <script id="is-template" type="text/html">
              <div id="is-region__lovers">lovers</div>
              <div id="is-region__memorys">memorys</div>
            <\/script>
          </div>

          <script id="lover-template" type="text/html">
            <a class="location" href="<%- link %>" target="_blank">
              <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgJy0vL1czQy8vRFREIFNWRyAxLjEvL0VOJyAnaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkJz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgdmVyc2lvbj0iMS4xIiB5PSIwcHgiIHg9IjBweCIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZpZXdCb3g9IjAgMCAxNiAyMiIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTYgMjIiPjxpbWFnZSBvcGFjaXR5PSIuMiIgeGxpbms6aHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFCSUFBQUFaQ0FZQUFBQThDWDZVQUFBQUNYQklXWE1BQUFzU0FBQUxFZ0hTM1g3OEFBQUEgR1hSRldIUlRiMlowZDJGeVpRQkJaRzlpWlNCSmJXRm5aVkpsWVdSNWNjbGxQQUFBQVpWSlJFRlVlTnFrbGMxTHcwQVF4YlBKcXJWVSBDNjFmMEJZL0Rub1ZQdzZlRlB6VDllQkpQWWpvUlFRVlViRm9wYWh0emZvRzNzcVlOdGl0Z1Y5TDA5MlhtWjAzRXhPRlh5YnoyOGxIIEVpZ1NnM0V3Q2NhVWtBc1JrclZGTUE4V1FRVjhnVStRSmdFaUVrVWRiSUVkc0FCYTRBVjBiSUJJQTJ5RFhiQU1yc0FsRUExakEwWDIgd1NaVGJQSzg1TndpR3lnaTN6WHd3ZitOcmtLSVNJUFI5TzJ6STRqayt1SmZrUXdTR2xsRUM4WEtKOEVpWHNEUTdqTmdIZXpSZEhXSyB4OFAyVGtRL3pJRTFzQUxLM21qRDlvOVZqZGVqNVcrVTBhcU0xZ3dyMUFIMzRBZzhnZzB3QWFaVWwvK01qRHdoSDAyVDNlellTMTAvIEl0U2FsUHZTdkloU3RYQ2FiVkJoaW82alFoN1VaZ0ZTOWRBK1p5ZE1wY2F5bDNsUEluc0FaK0NXMVozMTQ4TkhaOVg0bEUwRlVPTDkgTGlOcGMyUWNnQXRHdWdSZXdUTXorVFVoWXg1c2tZS0dpK1R3VDhBaE9HZFV3alc0QTI4U2xja0lGZWduOGRLcU92UlRjTXpLT2o3USBNYlZlVmtoSFZXSUtWVzZRTTNvQzd3TXM0S0ljb3hrS1dsYk4rNnc3cU94NTc2Zy8zMTk1MTdjQUF3QlJabU1PRlQ0U0lBQUFBQUJKIFJVNUVya0pnZ2c9PSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMikiIGhlaWdodD0iMjUiIHdpZHRoPSIxOCIgb3ZlcmZsb3c9InZpc2libGUiPjwvaW1hZ2U+PHBvbHlnb24gcG9pbnRzPSI5LjI0MTcgMTguNDc4IDcuMzc4OSAxNy40NzUgNS43NjQyIDE2LjYzNSA4LjMzMiAxMS44MiA0IDExLjgyIDE1LjM3OSAwLjQxMTcgMTUuMzc5IDE2LjQyNyAxMi4wNjMgMTMuMjA2IiBmaWxsPSIjZmZmIi8+PHJlY3QgeT0iOS4wMDU1IiB4PSI4LjY2MzkiIGhlaWdodD0iNy45OTg5IiB0cmFuc2Zvcm09Im1hdHJpeCgtLjg4MjUgLS40NzA0IC40NzA0IC0uODgyNSAxMi4wNzUgMjkuMDI3KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iMTQuMDk1IDIuODE5IDE0LjA5NSAxNC4wMDcgMTAuODM4IDEwLjg2MiA2LjA3MDUgMTAuODYyIi8+PC9zdmc+" style="transform: translate(<%- position.x %>px, <%- position.y %>px);">
              <div class="landscape is-hidden" style="background-image: url(<%- landscape %>); background-size: <%- window.width %>px <%- window.height %>px;"></div>
            </a>
          <\/script>

          <script id="memory-template" type="text/html">
            <div class="memory__inner">
              <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgJy0vL1czQy8vRFREIFNWRyAxLjEvL0VOJyAnaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkJz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgdmVyc2lvbj0iMS4xIiB5PSIwcHgiIHg9IjBweCIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZpZXdCb3g9IjAgMCAxNiAyMiIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTYgMjIiPjxpbWFnZSBvcGFjaXR5PSIuMiIgeGxpbms6aHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFCSUFBQUFaQ0FZQUFBQThDWDZVQUFBQUNYQklXWE1BQUFzU0FBQUxFZ0hTM1g3OEFBQUEgR1hSRldIUlRiMlowZDJGeVpRQkJaRzlpWlNCSmJXRm5aVkpsWVdSNWNjbGxQQUFBQVpWSlJFRlVlTnFrbGMxTHcwQVF4YlBKcXJWVSBDNjFmMEJZL0Rub1ZQdzZlRlB6VDllQkpQWWpvUlFRVlViRm9wYWh0emZvRzNzcVlOdGl0Z1Y5TDA5MlhtWjAzRXhPRlh5YnoyOGxIIEVpZ1NnM0V3Q2NhVWtBc1JrclZGTUE4V1FRVjhnVStRSmdFaUVrVWRiSUVkc0FCYTRBVjBiSUJJQTJ5RFhiQU1yc0FsRUExakEwWDIgd1NaVGJQSzg1TndpR3lnaTN6WHd3ZitOcmtLSVNJUFI5TzJ6STRqayt1SmZrUXdTR2xsRUM4WEtKOEVpWHNEUTdqTmdIZXpSZEhXSyB4OFAyVGtRL3pJRTFzQUxLM21qRDlvOVZqZGVqNVcrVTBhcU0xZ3dyMUFIMzRBZzhnZzB3QWFaVWwvK01qRHdoSDAyVDNlellTMTAvIEl0U2FsUHZTdkloU3RYQ2FiVkJoaW82alFoN1VaZ0ZTOWRBK1p5ZE1wY2F5bDNsUEluc0FaK0NXMVozMTQ4TkhaOVg0bEUwRlVPTDkgTGlOcGMyUWNnQXRHdWdSZXdUTXorVFVoWXg1c2tZS0dpK1R3VDhBaE9HZFV3alc0QTI4U2xja0lGZWduOGRLcU92UlRjTXpLT2o3USBNYlZlVmtoSFZXSUtWVzZRTTNvQzd3TXM0S0ljb3hrS1dsYk4rNnc3cU94NTc2Zy8zMTk1MTdjQUF3QlJabU1PRlQ0U0lBQUFBQUJKIFJVNUVya0pnZ2c9PSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMikiIGhlaWdodD0iMjUiIHdpZHRoPSIxOCIgb3ZlcmZsb3c9InZpc2libGUiPjwvaW1hZ2U+PHBvbHlnb24gcG9pbnRzPSI5LjI0MTcgMTguNDc4IDcuMzc4OSAxNy40NzUgNS43NjQyIDE2LjYzNSA4LjMzMiAxMS44MiA0IDExLjgyIDE1LjM3OSAwLjQxMTcgMTUuMzc5IDE2LjQyNyAxMi4wNjMgMTMuMjA2IiBmaWxsPSIjZmZmIi8+PHJlY3QgeT0iOS4wMDU1IiB4PSI4LjY2MzkiIGhlaWdodD0iNy45OTg5IiB0cmFuc2Zvcm09Im1hdHJpeCgtLjg4MjUgLS40NzA0IC40NzA0IC0uODgyNSAxMi4wNzUgMjkuMDI3KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iMTQuMDk1IDIuODE5IDE0LjA5NSAxNC4wMDcgMTAuODM4IDEwLjg2MiA2LjA3MDUgMTAuODYyIi8+PC9zdmc+">
              <div class="landscape is-hidden"></div>
            </div>
            <div class="time"></div>
          <\/script>
        """

        # Node の複製
        isTemplateCloneNode = document.importNode(isTemplate.content, true)
     
        # 生成したエレメントをDOMツリーに追加
        document.body.appendChild isEl
        isElShadowRoot.appendChild isTemplateCloneNode
        


        # ============================================================
        # REGION
        extensionRegion = new Backbone.Marionette.Region(
          el: "##{chrome.runtime.id} /deep/ #is"
        )


        # ============================================================
        # MODEL
        # ============================================================
        # ============================================================
        # MODEL - LOVER
        LoverModel = Backbone.Model.extend(
          # ------------------------------------------------------------
          defaults:
            position:
              x: 0
              y: 0
            window:
              width: 0
              height: 0
            link: ""
            landscape: ""

          # --------------------------------------------------------------
          # /**
          #  * LoverModel#initialize
          #  */
          # --------------------------------------------------------------
          initialize: () ->
            console.log "%c[Extension] LoverModel -> initialize", debug.style
            # @listenTo @, "change:position", _changePositionHandler

          # # --------------------------------------------------------------
          # # /**
          # #  * LoverModel#_changePositionHandler
          # #  */
          # # --------------------------------------------------------------
          # _changePositionHandler: () ->
          #   console.log "%c[Extension] LoversCollection -> _changePositionHandler", debug.style
        )

        # ============================================================
        # MODEL - MEMORY
        MemoryModel = Backbone.Model.extend(
          # ------------------------------------------------------------
          defaults:
            position:
              x: 0
              y: 0
            windowWidth: 0
            windowHeight: 0
            landscape: ""
            time: ""
        )



        # ============================================================
        # COLLECTION
        # ============================================================
        # ============================================================
        # COLLECTION - LOVERS
        LoversCollection = Backbone.Collection.extend
          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#initialize
          #  */
          # --------------------------------------------------------------
          initialize: () ->
            console.log "%c[Extension] LoversCollection -> initialize", debug.style
            Extension.vent.on "connectDisconnect", @_resetUserHandler.bind @
            Extension.vent.on "connectAddUser", @_addUserHandler.bind @
            Extension.vent.on "connectAddResident", @_addUserHandler.bind @
            Extension.vent.on "connectCheckOut", @_removeUserHandler.bind @
            Extension.vent.on "connectUpdateLocation", @_updateLocationHandler.bind @
            Extension.vent.on "connectUpdateWindowSize", @_updateWindowSizeHandler.bind @
            Extension.vent.on "connectUpdatePointer", @_updatePointerHandler.bind @
            Extension.vent.on "connectUpdateLandscape", @_updateLandscapeHandler.bind @

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#model
          #  */
          # --------------------------------------------------------------
          model: LoverModel

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_addUserHandler
          #  * @param {Object} data
          #  * @prop {string} id - 発信元のsocket.id
          #  * @prop {number} position.x - 接続ユーザーのポインター x座標
          #  * @prop {number} position.y - 接続ユーザーのポインター y座標
          #  * @prop {number} window.width - 接続ユーザーのwindow の幅
          #  * @prop {number} window.height - 接続ユーザーのwindow の高さ
          #  * @prop {string} link - 接続ユーザーが閲覧していたページのURL
          #  * @prop {string} landscape - スクリーンショット（base64）
          #  */
          # --------------------------------------------------------------
          _addUserHandler: (data) ->
            console.log "%c[Extension] LoversCollection -> _addUserHandler", debug.style, data
            @add data

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_removeUserHandler
          #  * @param {Object} data
          #  * @prop {string} id - 同じRoomに所属していたユーザーのSocketID
          #  */
          # --------------------------------------------------------------
          _removeUserHandler: (data) ->
            console.log "%c[Extension] LoversCollection -> _removeUserHandler", debug.style, data
            @remove id: data.id

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_resetUserHandler
          #  */
          # --------------------------------------------------------------
          _resetUserHandler: () ->
            console.log "%c[Extension] LoversCollection -> _removeUserHandler", debug.style
            @reset()

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_updateLocationHandler
          #  * @param {Object} data
          #  * @prop {string} id - 発信者のsocket.id
          #  * @prop {string} link - 接続ユーザーの閲覧しているURL
          #  */
          # --------------------------------------------------------------
          _updateLocationHandler: (data) ->
            console.log "%c[Extension] LoversCollection -> _updateLocationHandler", debug.style, data
            loverModel = @findWhere id: data.id
            loverModel.set "link": data.link

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_updateWindowSizeHandler
          #  * 同じRoom に所属していたユーザーのウインドウサイズの変化をsoketが受信した時に呼び出されるイベントハンドラー
          #  * @param {Object} data
          #  * @prop {string} id - 発信者のsocket.id
          #  * @prop {number} window.width - 発信者のwindowの幅
          #  * @prop {number} window.height - 発信者のwindowの高さ
          #  */
          # --------------------------------------------------------------
          _updateWindowSizeHandler: (data) ->
            console.log "%c[Extension] LoversCollection -> _updateWindowSizeHandler", debug.style, data
            loverModel = @findWhere id: data.id
            loverModel.set "window": data.window

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_updatePointerHandler
          #  * 同じRoom に所属していたユーザーのポインターの座標の変化をsoketが受信した時に呼び出されるイベントハンドラー
          #  * @param {Object} data
          #  * @prop {string} id - 発信元のsocket.id
          #  * @prop {number} position.x - 発信者のポインターのx座標
          #  * @prop {number} position.y - 発信者のポインターのy座標
          #  */
          # --------------------------------------------------------------
          _updatePointerHandler: (data) ->
            # console.log "%c[Extension] LoversCollection -> _updatePointerHandler", debug.style, data
            loverModel = @findWhere id: data.id
            loverModel.set position: data.position

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_updateLandscapeHandler
          #  * 同じRoom に所属しているユーザーのスクリーンショットが更新されたことを
          #  * 通知された時に呼び出されるイベントハンドラー
          #  * LoverModel にlandscape をセットする
          #  * @param {Object} data
          #  * @prop {string} id - 発信元のsocket.id
          #  * @prop {string} landscape - スクリーンショット（base64）
          #  */
          # --------------------------------------------------------------
          _updateLandscapeHandler: (data) ->
            console.log "%c[Extension] LoversCollection -> _updateLandscapeHandler", debug.style, data

            loverModel = @findWhere id: data.id
            loverModel.set landscape: data.landscape


        # End. COLLECTION - LOVERS
        # ============================================================

        # ============================================================
        # COLLECTION - MEMORYS
        MemorysCollection = Backbone.Collection.extend(
          model: MemoryModel
        )



        # ============================================================
        # ITEM VIEW
        # ============================================================
        # ============================================================
        # ITEM VIEW - LOVER
        LoverItemView = Backbone.Marionette.ItemView.extend(
          # ------------------------------------------------------------
          initialize: () ->
            console.log "[ExtensionModule] LoverItemView -> initialize", debug.style
            @listenTo @model, "change:link", @_changeLinkHandler
            @listenTo @model, "change:position", @_changePositionHandler
            @listenTo @model, "change:window", @_changeWindowHandler
            @listenTo @model, "change:landscape", @_changeLandscapeHandler

          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "lover"

          # ------------------------------------------------------------
          template: _.template(isElShadowRoot.querySelector("#lover-template").innerHTML)
          
          # ------------------------------------------------------------
          ui: 
            location: ".location"
            body: ".body"
            landscape: ".landscape"

          # --------------------------------------------------------------
          events:
            "mouseenter @ui.body": "_bodyMouseenterHandler"
            "mouseleave @ui.body": "_bodyMouseleaveHandler"

          # --------------------------------------------------------------
          onRender: () ->

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_changeLinkHandler
          #  * @param {Object} model - BackBone Model Object
          #  * @param {string} link - 接続ユーザーの閲覧しているURL
          #  */
          # --------------------------------------------------------------
          _changeLinkHandler: (model, link) ->
            console.log "%c[Extension] LoverItemView -> _changeWindowHandler", debug.style, link
            @ui.location.attr "href", link

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_changeWindowHandler
          #  * loverModel のwindow の値が変化した時に呼び出される
          #  * @param {Object} model - BackBone Model Object
          #  * @param {Object} windowSize
          #  * @prop {number} windowSize.width - 発信者のwindowの幅
          #  * @prop {number} windowSize.height - 発信者のwindowの高さ
          #  */
          # --------------------------------------------------------------
          _changeWindowHandler: (model, windowSize) ->
            console.log "%c[Extension] LoverItemView -> _changeWindowHandler", debug.style, windowSize
            @ui.landscape.css
              "background-size": "#{windowSize.width}px #{windowSize.height}px"

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_changePositionHandler
          #  * loverModel のposition の値が変化した時に呼び出される
          #  * （同じRoom に所属していたユーザーのポインターの座標の変化した時）
          #  * @param {Object} model - BackBone Model Object
          #  * @param {Object} position
          #  * @prop {number} x - ポインターのx座標
          #  * @prop {number} y - ポインターのy座標
          #  */
          # --------------------------------------------------------------
          _changePositionHandler: (model, position) ->
            # console.log "%c[Extension] LoverItemView -> _changePositionHandler", debug.style, position
            @ui.body.css
              transform: "translate(#{position.x}px, #{position.y}px)"

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_changeLandscapeHandler
          #  * loverModel のlandscape の値が変化した時に呼び出される
          #  * （同じRoom に所属していたユーザーのスクリーンショットが更新された時）
          #  * 引数に渡されたdataUrl を背景画像として設定する
          #  * @param {Object} loverModel - BackBone Model Object
          #  * @param {Object} landscape - スクリーンショット（base64）
          #  */
          # --------------------------------------------------------------
          _changeLandscapeHandler: (model, landscape) ->
            console.log "%c[Extension] LoverItemView -> _changeLandscapeHandler", debug.style, landscape

            @ui.landscape.css
              "background-image": "url(#{landscape})"

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_bodyMouseenterHandler
          #  */
          # --------------------------------------------------------------
          _bodyMouseenterHandler: () ->
            console.log "[ExtensionModule] MemoryItemView -> _bodyMouseenterHandler"
           
            Velocity @ui.landscape, "stop"

            @ui.landscape
              .css
                opacity: 1.0
              .removeClass "is-hidden"

          # --------------------------------------------------------------
          # /**
          #  * LoverItemView#_bodyMouseleaveHandler
          #  */
          # --------------------------------------------------------------
          _bodyMouseleaveHandler: () ->
            console.log "[ExtensionModule] MemoryItemView -> _bodyMouseleaveHandler"

            return $.Deferred (defer) =>
              Velocity.animate @ui.landscape,
                opacity: 0.0
              ,
                duration: 400
                delay: 0
                easing: "easeOutQuart"
                complete: () =>
                  @ui.landscape.addClass "is-hidden"
                  defer.resolve()
            .promise()
        )

        # ============================================================
        # ITEM VIEW - MEMORY
        MemoryItemView = Backbone.Marionette.ItemView.extend(
          # ------------------------------------------------------------
          initialize: () ->
            console.log "[ExtensionModule] MemoryItemView -> initialize"

          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "memory"

          # ------------------------------------------------------------
          template: _.template(isElShadowRoot.querySelector("#memory-template").innerHTML)
        )



        # # ============================================================
        # COLLECTION VIEW
        # ============================================================
        # ============================================================
        # COLLECTION VIEW - LOVERS
        LoversCollectionView = Backbone.Marionette.CollectionView.extend(
          # ------------------------------------------------------------
          initialize: () ->
            console.log "[ExtensionModule] LoversCollectionView -> initialize"

          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "lovers"

          # ------------------------------------------------------------
          childView: LoverItemView
        )


        # ============================================================
        # COLLECTION VIEW - MEMORYS
        MemorysCollectionView = Backbone.Marionette.CollectionView.extend(
          # ------------------------------------------------------------
          initialize: () ->
            console.log "[ExtensionModule] MemorysCollectionView -> initialize"

          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "memorys"

          # ------------------------------------------------------------
          childView: MemoryItemView
        )





        # ============================================================
        # LAYOUT VIEW
        ExtensionLayoutView = Backbone.Marionette.LayoutView.extend(
          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "is-layout is__debug"

          # ------------------------------------------------------------
          initialize: () ->
            console.log "[ExtensionModule] ExtensionLayoutView -> initialize"

          # ------------------------------------------------------------
          template: isElShadowRoot.querySelector("#is-template")

          # el: isElShadowRoot.querySelector("#is")

          # ------------------------------------------------------------
          # ui:
          #   lovers: "#is-region__lovers"
          #   memorys: "#is-region__memorys"

          # ------------------------------------------------------------
          regions: 
            lovers: "#is-region__lovers"
            memorys: "#is-region__memorys"
        )





        ExtensionModule.addInitializer () ->
          console.log "[ExtensionModule] addInitializer"

          Extension.addRegions(
            content: extensionRegion
          )

          Extension.content.show(new ExtensionLayoutView())

          loversCollection = new LoversCollection()
          memorysCollection = new MemorysCollection()

          loversCollectionView = new LoversCollectionView(
            collection: loversCollection
          )

          memorysCollectionView = new MemorysCollectionView(
            collection: memorysCollection
          )

          Extension.content.currentView.lovers.show(loversCollectionView)
          Extension.content.currentView.memorys.show(memorysCollectionView)


        Extension.start()


      # $.when(
      #   for key, model of sn.bb.models
      #     model.setup?()
      # ).then( =>
      #   $.when(
      #     sn.bb.views.stage.setup()
      #   )
      # ).then( =>
      #   console.log "- SETUP CONTENT SCRIPT -"
      # )


    # --------------------------------------------------------------
    sn.tf.update ->

    # --------------------------------------------------------------
    sn.tf.draw ->
   
    # --------------------------------------------------------------
    sn.tf.hover ->
   
    # --------------------------------------------------------------
    sn.tf.keyPressed (key) ->
   
    # --------------------------------------------------------------
    sn.tf.keyReleased (key) ->
   
    # --------------------------------------------------------------
    sn.tf.click ->
   
    # --------------------------------------------------------------
    sn.tf.pointerDown ->

    # --------------------------------------------------------------
    sn.tf.pointerEnter ->

    # --------------------------------------------------------------
    sn.tf.pointerLeave ->

    # --------------------------------------------------------------
    sn.tf.pointerMoved ->

    # --------------------------------------------------------------
    sn.tf.pointerOut ->

    # --------------------------------------------------------------
    sn.tf.pointerOver ->

    # --------------------------------------------------------------
    sn.tf.pointerUp ->
    
    # --------------------------------------------------------------
    sn.tf.windowScroll (top) ->

    # --------------------------------------------------------------
    sn.tf.windowResized (width, height) ->

    # --------------------------------------------------------------
    sn.tf.fullScreenChange (full) ->