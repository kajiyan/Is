# popupとの連携
# chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
#   console.log(msg, sender, sendResponse)
  
#   ret = $('title').text()
#   dev = $('title').text()
#   sendResponse { title: ret }

do (window=window, document=document, $=jQuery) ->
  "use strict"

  window.sn = {}

  # ============================================================
  # TypeFrameWork
  # ============================================================
  sn.tf = new TypeFrameWork()

  # ============================================================
  # Library
  # ============================================================
  jQBridget = require "jquery-bridget"
  
  require "backbone.marionette/lib/backbone.marionette.min"
  require "pepjs/dist/pep.min"

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

      # chrome.tabs.captureVisibleTab (a) ->
      #   console.log a

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
              z-index: 2147483647;
            }

            .is .memory {
              position: fixed;
              left: 0;
              top: 0;
              z-index: 2147483647;
            }

            .is .body {
              width: 16px;
              height: 22px;
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
            <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgJy0vL1czQy8vRFREIFNWRyAxLjEvL0VOJyAnaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkJz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgdmVyc2lvbj0iMS4xIiB5PSIwcHgiIHg9IjBweCIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZpZXdCb3g9IjAgMCAxNiAyMiIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTYgMjIiPjxpbWFnZSBvcGFjaXR5PSIuMiIgeGxpbms6aHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFCSUFBQUFaQ0FZQUFBQThDWDZVQUFBQUNYQklXWE1BQUFzU0FBQUxFZ0hTM1g3OEFBQUEgR1hSRldIUlRiMlowZDJGeVpRQkJaRzlpWlNCSmJXRm5aVkpsWVdSNWNjbGxQQUFBQVpWSlJFRlVlTnFrbGMxTHcwQVF4YlBKcXJWVSBDNjFmMEJZL0Rub1ZQdzZlRlB6VDllQkpQWWpvUlFRVlViRm9wYWh0emZvRzNzcVlOdGl0Z1Y5TDA5MlhtWjAzRXhPRlh5YnoyOGxIIEVpZ1NnM0V3Q2NhVWtBc1JrclZGTUE4V1FRVjhnVStRSmdFaUVrVWRiSUVkc0FCYTRBVjBiSUJJQTJ5RFhiQU1yc0FsRUExakEwWDIgd1NaVGJQSzg1TndpR3lnaTN6WHd3ZitOcmtLSVNJUFI5TzJ6STRqayt1SmZrUXdTR2xsRUM4WEtKOEVpWHNEUTdqTmdIZXpSZEhXSyB4OFAyVGtRL3pJRTFzQUxLM21qRDlvOVZqZGVqNVcrVTBhcU0xZ3dyMUFIMzRBZzhnZzB3QWFaVWwvK01qRHdoSDAyVDNlellTMTAvIEl0U2FsUHZTdkloU3RYQ2FiVkJoaW82alFoN1VaZ0ZTOWRBK1p5ZE1wY2F5bDNsUEluc0FaK0NXMVozMTQ4TkhaOVg0bEUwRlVPTDkgTGlOcGMyUWNnQXRHdWdSZXdUTXorVFVoWXg1c2tZS0dpK1R3VDhBaE9HZFV3alc0QTI4U2xja0lGZWduOGRLcU92UlRjTXpLT2o3USBNYlZlVmtoSFZXSUtWVzZRTTNvQzd3TXM0S0ljb3hrS1dsYk4rNnc3cU94NTc2Zy8zMTk1MTdjQUF3QlJabU1PRlQ0U0lBQUFBQUJKIFJVNUVya0pnZ2c9PSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMikiIGhlaWdodD0iMjUiIHdpZHRoPSIxOCIgb3ZlcmZsb3c9InZpc2libGUiPjwvaW1hZ2U+PHBvbHlnb24gcG9pbnRzPSI5LjI0MTcgMTguNDc4IDcuMzc4OSAxNy40NzUgNS43NjQyIDE2LjYzNSA4LjMzMiAxMS44MiA0IDExLjgyIDE1LjM3OSAwLjQxMTcgMTUuMzc5IDE2LjQyNyAxMi4wNjMgMTMuMjA2IiBmaWxsPSIjZmZmIi8+PHJlY3QgeT0iOS4wMDU1IiB4PSI4LjY2MzkiIGhlaWdodD0iNy45OTg5IiB0cmFuc2Zvcm09Im1hdHJpeCgtLjg4MjUgLS40NzA0IC40NzA0IC0uODgyNSAxMi4wNzUgMjkuMDI3KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iMTQuMDk1IDIuODE5IDE0LjA5NSAxNC4wMDcgMTAuODM4IDEwLjg2MiA2LjA3MDUgMTAuODYyIi8+PC9zdmc+">
            <div class="landscape is-hidden"></div>
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
            x: 0
            y: 0
            windowWidth: 0
            windowHeight: 0
            landscape: ""
        )

        # ============================================================
        # MODEL - MEMORY
        MemoryModel = Backbone.Model.extend(
          # ------------------------------------------------------------
          defaults:
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
            Extension.vent.on "connectChangeUsers", @_changeUsersHandler.bind @

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#model
          #  */
          # --------------------------------------------------------------
          model: LoverModel

          # --------------------------------------------------------------
          # /**
          #  * LoversCollection#_changeUsersHandler
          #  */
          # --------------------------------------------------------------
          _changeUsersHandler: (users) ->
            console.log "%c[Extension] LoversCollection -> _changeUsersHandler", debug.style, users

            # socket.id をベースにデータを追加する

            # Todoチェックアウト作る
            for user, index in users
              @add
                id: user

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
            console.log "[ExtensionModule] LoverItemView -> initialize"

          # ------------------------------------------------------------
          tagName: "div"
          
          # ------------------------------------------------------------
          className: "lover"

          # ------------------------------------------------------------
          template: _.template(isElShadowRoot.querySelector("#lover-template").innerHTML)
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