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
  # BackBone
  # ============================================================
  sn.bb =
    models: null
    collections: null
    views: null

  # ============================================================
  # BackBone - MODEL
  sn.bb.models =
    stage: do ->
      Stage = require("./models/stage")(sn, $, _)
      return new Stage()
    connect: do ->
      Connect = require("./models/connect")(sn, $, _)
      return new Connect()

  # ============================================================
  # BackBone - COLLECTION


  # ============================================================
  # BackBone - VIEW
  sn.bb.views =
    "stage": do ->
      Stage = require("./views/stage")(sn, $, _)
      return new Stage
        "model": sn.bb.models.stage


  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->

      # ============================================================
      #  EXTENSION MODULE
      # ============================================================
      Extension.module "ExtensionModule", (ExtensionModule, Extension, Backbone, Marionette, $, _) ->
        # Extension のベースになるDOM を生成する
        isEl = document.createElement "div"
        
        # Extension のView にID をつける
        isEl.id = chrome.runtime.id

        isElShadowRoot = isEl.createShadowRoot()

        isElShadowRoot.innerHTML = """
          <style>
            .is .body {
              width: 16px;
              height: 22px;
              left: 0;
              top: 0;
              z-index: 2147483647;
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
            <div class="landscape"></div>
          <\/script>

          <script id="memory-template" type="text/html">
            <div class="memory__inner">
              <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgJy0vL1czQy8vRFREIFNWRyAxLjEvL0VOJyAnaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkJz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgdmVyc2lvbj0iMS4xIiB5PSIwcHgiIHg9IjBweCIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZpZXdCb3g9IjAgMCAxNiAyMiIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTYgMjIiPjxpbWFnZSBvcGFjaXR5PSIuMiIgeGxpbms6aHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFCSUFBQUFaQ0FZQUFBQThDWDZVQUFBQUNYQklXWE1BQUFzU0FBQUxFZ0hTM1g3OEFBQUEgR1hSRldIUlRiMlowZDJGeVpRQkJaRzlpWlNCSmJXRm5aVkpsWVdSNWNjbGxQQUFBQVpWSlJFRlVlTnFrbGMxTHcwQVF4YlBKcXJWVSBDNjFmMEJZL0Rub1ZQdzZlRlB6VDllQkpQWWpvUlFRVlViRm9wYWh0emZvRzNzcVlOdGl0Z1Y5TDA5MlhtWjAzRXhPRlh5YnoyOGxIIEVpZ1NnM0V3Q2NhVWtBc1JrclZGTUE4V1FRVjhnVStRSmdFaUVrVWRiSUVkc0FCYTRBVjBiSUJJQTJ5RFhiQU1yc0FsRUExakEwWDIgd1NaVGJQSzg1TndpR3lnaTN6WHd3ZitOcmtLSVNJUFI5TzJ6STRqayt1SmZrUXdTR2xsRUM4WEtKOEVpWHNEUTdqTmdIZXpSZEhXSyB4OFAyVGtRL3pJRTFzQUxLM21qRDlvOVZqZGVqNVcrVTBhcU0xZ3dyMUFIMzRBZzhnZzB3QWFaVWwvK01qRHdoSDAyVDNlellTMTAvIEl0U2FsUHZTdkloU3RYQ2FiVkJoaW82alFoN1VaZ0ZTOWRBK1p5ZE1wY2F5bDNsUEluc0FaK0NXMVozMTQ4TkhaOVg0bEUwRlVPTDkgTGlOcGMyUWNnQXRHdWdSZXdUTXorVFVoWXg1c2tZS0dpK1R3VDhBaE9HZFV3alc0QTI4U2xja0lGZWduOGRLcU92UlRjTXpLT2o3USBNYlZlVmtoSFZXSUtWVzZRTTNvQzd3TXM0S0ljb3hrS1dsYk4rNnc3cU94NTc2Zy8zMTk1MTdjQUF3QlJabU1PRlQ0U0lBQUFBQUJKIFJVNUVya0pnZ2c9PSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMikiIGhlaWdodD0iMjUiIHdpZHRoPSIxOCIgb3ZlcmZsb3c9InZpc2libGUiPjwvaW1hZ2U+PHBvbHlnb24gcG9pbnRzPSI5LjI0MTcgMTguNDc4IDcuMzc4OSAxNy40NzUgNS43NjQyIDE2LjYzNSA4LjMzMiAxMS44MiA0IDExLjgyIDE1LjM3OSAwLjQxMTcgMTUuMzc5IDE2LjQyNyAxMi4wNjMgMTMuMjA2IiBmaWxsPSIjZmZmIi8+PHJlY3QgeT0iOS4wMDU1IiB4PSI4LjY2MzkiIGhlaWdodD0iNy45OTg5IiB0cmFuc2Zvcm09Im1hdHJpeCgtLjg4MjUgLS40NzA0IC40NzA0IC0uODgyNSAxMi4wNzUgMjkuMDI3KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iMTQuMDk1IDIuODE5IDE0LjA5NSAxNC4wMDcgMTAuODM4IDEwLjg2MiA2LjA3MDUgMTAuODYyIi8+PC9zdmc+">
              <div class="landscape"></div>
            </div>
            <div class="landscape"></div>
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
            landscape: ""
        )

        # ============================================================
        # MODEL - MEMORY
        MemoryModel = Backbone.Model.extend(
          # ------------------------------------------------------------
          defaults:
            x: 0
            y: 0
            landscape: ""
            time: ""
        )



        # ============================================================
        # COLLECTION
        # ============================================================
        # ============================================================
        # COLLECTION - LOVERS
        LoversCollection = Backbone.Collection.extend(
          model: LoverModel
        )

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

          loversCollection = new LoversCollection([{}])
          memorysCollection = new MemorysCollection([{}])

          loversCollectionView = new LoversCollectionView(
            collection: loversCollection
          )

          memorysCollectionView = new MemorysCollectionView(
            collection: memorysCollection
          )

          Extension.content.currentView.lovers.show(loversCollectionView)
          Extension.content.currentView.memorys.show(memorysCollectionView)


        Extension.start()

          # loverItemView = new LoverItemView(
          #   model: new LoverModel()
          # )
          # # console.log loverItemView.template
          # console.log loverItemView.render()
          # console.log loverItemView.el

          # # console.log isElShadowRoot.querySelector("#is-template")
          # # console.log isElShadowRoot.querySelector("#lover-template")

          # loverItemView = new LoverItemView(
          #   model: new LoverModel()
          # )
          # console.log isElShadowRoot.querySelector("#lover-template")
          # console.log loverItemView.template
          # console.log loverItemView.render()
          # console.log loverItemView.el



          # layouts = extension: new ExtensionLayoutView()

          # layouts.extension.render()

          # # extensionRegion.show(layouts.extension)

          # # new LoversCollection([{}, {}])

          # layouts.extension.lovers.show(
          #   new LoversCollectionView({
          #     collection: new LoversCollection([{}, {}])
          #   })
          # )

          # layouts.extension.getRegion("lovers").show(new LoversCollectionView(
          #   collection: loversCollection
          # ))

          # # extensionRegion.show(layouts.extension)


          # loversCollectionView = new LoversCollectionView collection: loversCollection
          # loversCollectionView.render()
          # console.log loversCollectionView.el


          # loverItemView = new LoverItemView(
          #   model: new LoverModel()
          # )
          # console.log isElShadowRoot.querySelector("#lover-template")
          # console.log loverItemView.template
          # console.log loverItemView.render()
          # console.log loverItemView.el



          # Layout
          # layouts.extension.getRegion("lovers")
          #   .show new LoversCollectionView(
          #     collection: loversCollection
          #   )




          # layouts.extension.render()

          # layouts.extension.test()

          # loverItemView = new LoverItemView(
          #   model: new LoverModel()
          # )
          # console.log loverItemView.template
          # console.log loverItemView.render()
          # console.log loverItemView.el

          # layouts.extension.getRegion("lovers").show(new LoversCollectionView(
          #   collection: loversCollection
          # ))

          
          # shadowRoot.innerHTML = $(shadowRoot.querySelector("#is-#{chrome.runtime.id}")).text()

          # test = $(shadowRoot.querySelector("#region__lovers"))

          # console.log test.find("#test").size()

          # console.log  layouts.extension.getRegion("lovers").$el.size()
          # extensionRegion.show(layouts.extension)
          

      # Extension.start()


      # console.log ExtensionRegion

      # # ベースになるShadow DOMを作る
      # Is = Object.create(HTMLElement.prototype)
      # shadowDom = null

      # # /** 
      # #  *  createdCallback
      # #  *  要素のインスタンスが生成されるたびに呼ばれる
      # #  */
      # Is.createdCallback = () ->
      #   console.log 'createdCallback'

      #   shadowDom = @createShadowRoot()
      #   shadowDom.innerHTML = '<div>Is</div>'

      # # ドキュメントにカスタム要素を登録する
      # document.registerElement 'x-is',
      #   prototype: Is

      # # カスタム要素を生成する
      # isEl = document.createElement('x-is');

      # document.body.appendChild(isEl);


      ###
      # ============================================================
      # CONTENT MODULE
      Extension.module 'ContentModule', (ContentModule, App, Backbone, Marionette, $, _) ->
        # ============================================================
        # CONTENT MODULE - Controller
        ContentModule.Controller = Backbone.Marionette.Controller.extend
          initialize: () ->
            console.log "[ContentModule] Controller | initialize"


        # ============================================================
        # CONTENT MODULE - Model
        LoverModel = Backbone.Model.extend(
          defaults: {}
        )


        # ============================================================
        # CONTENT MODULE - Collection
        LoverCollection = Backbone.Collection.extend(
          model: LoverModel
        )


        # ============================================================
        # CONTENT MODULE - View
        IsView = Backbone.Marionette.ItemView.extend(
          # --------------------------------------------------------------
          initialize: () ->
            console.log "[ContentModule] IsView | initialize"

            # Extension のView になるDOM を生成する
            isEl = document.createElement "div"
            $isEl = $(isEl)
            
            # Extension のView にID をつける
            $isEl.attr "id", chrome.runtime.id

            # サイトのCSSに影響を受けないようにShadow DOM を生成する
            @shadowRoot = isEl.createShadowRoot()

            @shadowRoot.innerHTML = """
              <style>
                .is__debug, .is__debug * {
                  -moz-box-shadow: black 0px 0px 0px 1px inset;
                  -webkit-box-shadow: black 0px 0px 0px 1px inset;
                  box-shadow: black 0px 0px 0px 1px inset;
                  background-color: rgba(204, 204, 204, 0.5);
                }

                .is__hidden {
                  position: fixed;
                  top: 0;
                  left: 0;
                  visibility: hidden;
                  clip: rect(0 0 0 0);
                }

                .is {}

                  .is .lovers {
                    position: fixed;
                    z-index: 2147483647;
                  }

                    .is .lovers .body {
                      width: 16px;
                      height: 22px;
                      position: fixed;
                      left: 0;
                      top: 0;
                      z-index: 2147483647;
                    }
              </style>
              
              <div id="js-is" class="is is__debug">
                <div id="js-lovers" class="lovers">
                  <div class="people">
                      <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyAgUFVCTElDICctLy9XM0MvL0RURCBTVkcgMS4xLy9FTicgICdodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQnPjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWw6c3BhY2U9InByZXNlcnZlIiB2ZXJzaW9uPSIxLjEiIHk9IjBweCIgeD0iMHB4IiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmlld0JveD0iMCAwIDE2IDIyIiBlbmFibGUtYmFja2dyb3VuZD0ibmV3IDAgMCAxNiAyMiI+PGltYWdlIG9wYWNpdHk9Ii4yIiB4bGluazpocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQUJJQUFBQVpDQVlBQUFBOENYNlVBQUFBQ1hCSVdYTUFBQXNTQUFBTEVnSFMzWDc4QUFBQUdYUkZXSFJUYjJaMGQyRnlaUUJCWkc5aVpTQkpiV0ZuWlZKbFlXUjVjY2xsUEFBQUFZbEpSRUZVZU5xY2xWdEx3ekFZaHBNdXJrNDhiNTVBOGNwTEwvei8xN3Z3U2dVUkVRVEJ3enlqV0hXck52R052SkVzdGpaMThNRGFway9mSk4vWENqSCtrK0tmdjVZbm1DQk9acHFLbkdRT0xJRVVGRUEza1RuUkZOZ0UyNkFIUHNFN2hWRXk1U1d5YVhaQUc4eURCSng3d2xxUjRFMDIxVHFUTGZLY2lKVXA3NytUYlFTaUtKa0tqcDBzRk5YS1ZNazVQNW1JbGFtS3BJMWw2by8xYXlSVE5ic2FMVk1SdFdabEhaYUdZY1U3TGlqVEtySURYTkV1Z0Mzd0NKNUFCbklyU2lKRk52NExHSUJidHBDZDhxUnJzN0pFeHNNWFBZTmpzQXRPd1NYUGZmZGpLTktNbXZGSmJhNWp3cWxaK1EwNEFYZmdqZW5HRmx2endvQlBzVGV1c2NydHVHbXdBcm9VajhDSFMrNWVJeWxmSHoydXdUNmpkN2pBS1cvT21lUU1QUEQ0cDQ0TXpYYkFIaGlDZTdBTVpwZ2k1WmljVXpGVkxUSmlnb3lpSWJkNGxjVW9PZTBEY01qVWVkazdXL09KVnZSS2NVRkJpN3R6QlBwTWZjMHhwdXFySVhsUmNzZTZURFRMUkZkY2dsOU5LMnRhUTNsRlYzZzdwVVhENzVnTWtsWitwcjRFR0FDMm5vRWdQN2tNN3dBQUFBQkpSVTVFcmtKZ2dnPT0iIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAgLTIpIiBoZWlnaHQ9IjI1IiB3aWR0aD0iMTgiIG92ZXJmbG93PSJ2aXNpYmxlIi8+PHBvbHlnb24gcG9pbnRzPSIxMC4xMzcgMTguNDczIDEyIDE3LjQ3IDEzLjYxNSAxNi42MyAxMS4wNDcgMTEuODE0IDE1LjM3OSAxMS44MTQgNCAwLjQwNjcgNCAxNi40MjIgNy4zMTU5IDEzLjIwMSIgZmlsbD0iI2ZmZiIvPjxyZWN0IHk9IjkuMDAwNiIgeD0iOC40MzEzIiBoZWlnaHQ9IjcuOTk4OSIgdHJhbnNmb3JtPSJtYXRyaXgoLjg4MjUgLS40NzA0IC40NzA0IC44ODI1IC01LjAwNjYgNS45NjQ2KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iNSAyLjgxNCA1IDE0LjAwMiA4LjI1NzggMTAuODU3IDEzLjAyNSAxMC44NTciLz48L3N2Zz4=">
                      <div class="memory"></div>
                    </div>
                    <div class="people">
                      <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyAgUFVCTElDICctLy9XM0MvL0RURCBTVkcgMS4xLy9FTicgICdodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQnPjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWw6c3BhY2U9InByZXNlcnZlIiB2ZXJzaW9uPSIxLjEiIHk9IjBweCIgeD0iMHB4IiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmlld0JveD0iMCAwIDE2IDIyIiBlbmFibGUtYmFja2dyb3VuZD0ibmV3IDAgMCAxNiAyMiI+PGltYWdlIG9wYWNpdHk9Ii4yIiB4bGluazpocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQUJJQUFBQVpDQVlBQUFBOENYNlVBQUFBQ1hCSVdYTUFBQXNTQUFBTEVnSFMzWDc4QUFBQUdYUkZXSFJUYjJaMGQyRnlaUUJCWkc5aVpTQkpiV0ZuWlZKbFlXUjVjY2xsUEFBQUFZbEpSRUZVZU5xY2xWdEx3ekFZaHBNdXJrNDhiNTVBOGNwTEwvei8xN3Z3U2dVUkVRVEJ3enlqV0hXck52R052SkVzdGpaMThNRGFway9mSk4vWENqSCtrK0tmdjVZbm1DQk9acHFLbkdRT0xJRVVGRUEza1RuUkZOZ0UyNkFIUHNFN2hWRXk1U1d5YVhaQUc4eURCSng3d2xxUjRFMDIxVHFUTGZLY2lKVXA3NytUYlFTaUtKa0tqcDBzRk5YS1ZNazVQNW1JbGFtS3BJMWw2by8xYXlSVE5ic2FMVk1SdFdabEhaYUdZY1U3TGlqVEtySURYTkV1Z0Mzd0NKNUFCbklyU2lKRk52NExHSUJidHBDZDhxUnJzN0pFeHNNWFBZTmpzQXRPd1NYUGZmZGpLTktNbXZGSmJhNWp3cWxaK1EwNEFYZmdqZW5HRmx2endvQlBzVGV1c2NydHVHbXdBcm9VajhDSFMrNWVJeWxmSHoydXdUNmpkN2pBS1cvT21lUU1QUEQ0cDQ0TXpYYkFIaGlDZTdBTVpwZ2k1WmljVXpGVkxUSmlnb3lpSWJkNGxjVW9PZTBEY01qVWVkazdXL09KVnZSS2NVRkJpN3R6QlBwTWZjMHhwdXFySVhsUmNzZTZURFRMUkZkY2dsOU5LMnRhUTNsRlYzZzdwVVhENzVnTWtsWitwcjRFR0FDMm5vRWdQN2tNN3dBQUFBQkpSVTVFcmtKZ2dnPT0iIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAgLTIpIiBoZWlnaHQ9IjI1IiB3aWR0aD0iMTgiIG92ZXJmbG93PSJ2aXNpYmxlIi8+PHBvbHlnb24gcG9pbnRzPSIxMC4xMzcgMTguNDczIDEyIDE3LjQ3IDEzLjYxNSAxNi42MyAxMS4wNDcgMTEuODE0IDE1LjM3OSAxMS44MTQgNCAwLjQwNjcgNCAxNi40MjIgNy4zMTU5IDEzLjIwMSIgZmlsbD0iI2ZmZiIvPjxyZWN0IHk9IjkuMDAwNiIgeD0iOC40MzEzIiBoZWlnaHQ9IjcuOTk4OSIgdHJhbnNmb3JtPSJtYXRyaXgoLjg4MjUgLS40NzA0IC40NzA0IC44ODI1IC01LjAwNjYgNS45NjQ2KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iNSAyLjgxNCA1IDE0LjAwMiA4LjI1NzggMTAuODU3IDEzLjAyNSAxMC44NTciLz48L3N2Zz4=">
                      <div class="memory"></div>
                    </div>
                  <script type="text/template" id="people-template">
                    <div class="people">
                      <img class="body" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyAgUFVCTElDICctLy9XM0MvL0RURCBTVkcgMS4xLy9FTicgICdodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQnPjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWw6c3BhY2U9InByZXNlcnZlIiB2ZXJzaW9uPSIxLjEiIHk9IjBweCIgeD0iMHB4IiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmlld0JveD0iMCAwIDE2IDIyIiBlbmFibGUtYmFja2dyb3VuZD0ibmV3IDAgMCAxNiAyMiI+PGltYWdlIG9wYWNpdHk9Ii4yIiB4bGluazpocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQUJJQUFBQVpDQVlBQUFBOENYNlVBQUFBQ1hCSVdYTUFBQXNTQUFBTEVnSFMzWDc4QUFBQUdYUkZXSFJUYjJaMGQyRnlaUUJCWkc5aVpTQkpiV0ZuWlZKbFlXUjVjY2xsUEFBQUFZbEpSRUZVZU5xY2xWdEx3ekFZaHBNdXJrNDhiNTVBOGNwTEwvei8xN3Z3U2dVUkVRVEJ3enlqV0hXck52R052SkVzdGpaMThNRGFway9mSk4vWENqSCtrK0tmdjVZbm1DQk9acHFLbkdRT0xJRVVGRUEza1RuUkZOZ0UyNkFIUHNFN2hWRXk1U1d5YVhaQUc4eURCSng3d2xxUjRFMDIxVHFUTGZLY2lKVXA3NytUYlFTaUtKa0tqcDBzRk5YS1ZNazVQNW1JbGFtS3BJMWw2by8xYXlSVE5ic2FMVk1SdFdabEhaYUdZY1U3TGlqVEtySURYTkV1Z0Mzd0NKNUFCbklyU2lKRk52NExHSUJidHBDZDhxUnJzN0pFeHNNWFBZTmpzQXRPd1NYUGZmZGpLTktNbXZGSmJhNWp3cWxaK1EwNEFYZmdqZW5HRmx2endvQlBzVGV1c2NydHVHbXdBcm9VajhDSFMrNWVJeWxmSHoydXdUNmpkN2pBS1cvT21lUU1QUEQ0cDQ0TXpYYkFIaGlDZTdBTVpwZ2k1WmljVXpGVkxUSmlnb3lpSWJkNGxjVW9PZTBEY01qVWVkazdXL09KVnZSS2NVRkJpN3R6QlBwTWZjMHhwdXFySVhsUmNzZTZURFRMUkZkY2dsOU5LMnRhUTNsRlYzZzdwVVhENzVnTWtsWitwcjRFR0FDMm5vRWdQN2tNN3dBQUFBQkpSVTVFcmtKZ2dnPT0iIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAgLTIpIiBoZWlnaHQ9IjI1IiB3aWR0aD0iMTgiIG92ZXJmbG93PSJ2aXNpYmxlIi8+PHBvbHlnb24gcG9pbnRzPSIxMC4xMzcgMTguNDczIDEyIDE3LjQ3IDEzLjYxNSAxNi42MyAxMS4wNDcgMTEuODE0IDE1LjM3OSAxMS44MTQgNCAwLjQwNjcgNCAxNi40MjIgNy4zMTU5IDEzLjIwMSIgZmlsbD0iI2ZmZiIvPjxyZWN0IHk9IjkuMDAwNiIgeD0iOC40MzEzIiBoZWlnaHQ9IjcuOTk4OSIgdHJhbnNmb3JtPSJtYXRyaXgoLjg4MjUgLS40NzA0IC40NzA0IC44ODI1IC01LjAwNjYgNS45NjQ2KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iNSAyLjgxNCA1IDE0LjAwMiA4LjI1NzggMTAuODU3IDEzLjAyNSAxMC44NTciLz48L3N2Zz4=">
                      <div class="memory"></div>
                    </div>
                  </script>
                </div>
              </div>
              """

            # 生成したエレメントをDOMツリーに追加
            document.body.appendChild isEl

            @el = @shadowRoot.querySelector(".is")

            # これで取得できる
            # console.log @shadowRoot.querySelector('.people')

            console.log @el

            Extension.reqres.setHandler "getShadowRoot", () =>
              return @$el
        )


        # Lover View
        LoverView = Backbone.Marionette.ItemView.extend(
          # --------------------------------------------------------------
          # tagName: 'div'
          
          # --------------------------------------------------------------
          # className: 'people'

          # --------------------------------------------------------------
          template: ->
            $shadowRoot = Extension.request "getShadowRoot"
            template = $shadowRoot.find("#people-template")
            return template

          # --------------------------------------------------------------
          initialize: () ->
            console.log "[ContentModule] LoverView | initialize"

            $shadowRoot = Extension.request "getShadowRoot"
            # console.log shadowRoot.querySelector('.iosSlider')
            # template = $shadowRoot.find("#js-is")

            # console.log $shadowRoot.find("#js-is")[0]
            # console.log $shadowRoot
        )

        # Lover Collection View
        LoverCollectionView = Backbone.Marionette.CollectionView.extend({
          tagName: 'div'
          className: 'lovers'
          childView: LoverView
        })

        ContentModule.addInitializer () ->


          ContentModule.controller = new ContentModule.Controller()

          itemViews =
            is: new IsView()

          loverCollection = new LoverCollection([{}, {}])

          loverCollectionView = new LoverCollectionView({
            collection: loverCollection
          })

          loverCollectionView.render()
          console.log loverCollectionView.el


      Extension.start()
      ###

      $.when(
        for key, model of sn.bb.models
          model.setup?()
      ).then( =>
        $.when(
          sn.bb.views.stage.setup()
        )
      ).then( =>
        console.log "- SETUP CONTENT SCRIPT -"
      )

      # events = [
      #   'click',
      #   'pointermove'
      # ]

      # events.forEach (eventName) ->
      #   console.log eventName
      #   document.body.addEventListener eventName, (e) ->
      #     console.log(e.clientX + ' : ' + e.clientY);

      # # popupとの連携
      # chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
      #   console.log(msg, sender, sendResponse)
        
      #   ret = $('title').text()
      #   dev = $('title').text()
      #   sendResponse { title: ret }

      

      # $html = $("<div>Hello World</div>")
      # $("body").prepend($html)

      # backgroundScriptReceiver
      # backgroundScriptReceiver = {}

      # chrome.runtime.onConnect.addListener (port) ->
      #   console.log "port.name", port.name
      #   if port.name is "contentScriptSender"
      #     backgroundScriptReceiver = port
          
      #     backgroundScriptReceiver.onMessage.addListener ( message ) ->
          
      # backgroundScriptSender = {}
      # backgroundScriptSender = chrome.extension.connect name: "fromContentScript"
      # backgroundScriptSender.postMessage joke: "fromContentScript"



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
          #     $("body").prepend(video)
          #     video.src = window.URL.createObjectURL stream
          #     video.play();


      #   # port.onMessage.addListener ( message ) ->
      #     # console.log message

      # chrome.tabs.onConnect.addListener ( port ) ->
        # console.log port

      # chrome.extension.onConnect.addListener ( port ) ->
        # console.log port

      # chrome.runtime.onMessage.addListener (message) ->
      #   $("body").prepend($html)
      #   console.log message

      # chrome.runtime.sendMessage 'from content script'

      # chrome.runtime.onConnect.addListener ( port ) ->
      #   console.log port
      #   port.onMessage.addListener (msg) -> 
      #     console.log msg

      # port = chrome.extension.connect name: "contentScript"
      # # # port.postMessage joke: "Knock knock"
      # port.onMessage.addListener (msg) ->
      #   console.log msg
      #   if msg.question is "Who's there?"
      #     port.postMessage answer: "Madame"
      #   else if msg.question is "Madame who?"
      #     port.postMessage answer: "Madame... Bovary"

      # console.log port

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