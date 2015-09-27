# popupとの連携
# chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
#   console.log(msg, sender, sendResponse)
  
#   ret = $('title').text()
#   dev = $('title').text()
#   sendResponse { title: ret }

do (window=window, document=document, $=jQuery) ->
  "use strict"

  window.sn = {}

  console.log SETTING

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
  
  sn.moment = require "moment"

  # do ->
  #   loadQueue = new createjs.LoadQueue()

  #   loadQueue.addEventListener "fileload", (e) -> console.log e
  #   loadQueue.addEventListener "complete", (e) ->
  #     console.log e
  #     # createjs.Sound.play "signal"

  #   # createjs.Sound.alternateExtensions = ["mp3"]
  #   loadQueue.installPlugin createjs.Sound
  #   loadQueue.loadManifest [
  #     { id: "signal", src: "chrome-extension://kcondcikicihkpnhhohgdngemopbdjmi/public/sounds/extension/content-script/sound-effect-signal-0.ogg" }
  #     { id: "noise", src: "chrome-extension://kcondcikicihkpnhhohgdngemopbdjmi/public/sounds/extension/content-script/sound-effect-noise-0.ogg" }
  #   ]



    # createjs.Sound.addEventListener "fileload", (e) -> console.log "Preloaded:", e.id, e.src
    # createjs.Sound.registerSounds([
    #   { id: "signal", src: "sound-effect-signal-0.ogg" }
    #   { id: "noise", src: "sound-effect-noise-0.ogg" }
    # ], soundAssetsPath)
  # console.log require "PreloadJS/lib/preloadjs-0.6.1.min.js"
  # console.log require "PreloadJS/lib/preloadjs-0.6.1.combined.js"

  require "pepjs/dist/pep.min"
  require "backbone.marionette/lib/backbone.marionette.min"
  require "velocity/velocity.min"
  require "velocity/velocity.ui.min"
  require "jquery.imgloader"

  # ============================================================
  # APPLICATION
  # ============================================================
  App = new Backbone.Marionette.Application()

  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->

      debug = style: "background-color: DarkBlue; color: #ffffff;"

      # App のベースになるDOM を生成する
      isEl = document.createElement "div"
        
      # App のView にID をつける
      isEl.id = chrome.runtime.id

      isElShadowRoot = isEl.createShadowRoot()

      isElShadowRoot.innerHTML = """
        <style>
          @import url(https://fonts.googleapis.com/css?family=Roboto+Condensed);

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

          .is-roboto {
            font-family: 'Roboto Condensed', sans-serif;   
          }

          .is {}

          .is .lover {
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483647;
          }

          .is .lover .location {
            width: 0;
            height: 0;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483646;
            cursor: default;
          }

          .is .lover .body {
            vertical-align: top;
            width: 16px;
            height: 22px;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483647;
          }

          .is .lover .landscape {
            background-color: #ffffff;
            background-repeat: no-repeat;
            background-position: center;
            width: 100%;
            height: 100%;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483646;
          }

          .is .memory {
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483646;
          }

          .is .memory .location {
            width: 0;
            height: 0;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483646;
            cursor: default;
          }

          .is .memory .body {
            height: 22px;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483647;
          }

          .is .memory .body-img {
            display: inline-block;
            vertical-align: middle;
            width: 16px;
            height: 22px;
            opacity: 0.0;
          }

          .is .memory .create-at {
            display: inline-block;
            vertical-align: middle;
            color: #ffffff;
            font-size: 12px;
            font-weight: normal;
            line-height: 18px;
            margin: 0 0 0 10px;
            overflow: hidden;
            /* opacity: 0.0; */
          }

          .is .memory .create-at--inner {
            display: inline-block;
            background-color: #000000;
            padding: 0 8px;
          }

          .is .memory .landscape {
            background-color: #ffffff;
            background-repeat:
              repeat,
              no-repeat;
            background-position:
              center,
              center;
            background-blend-mode:
              multiply,
              normal;
            width: 100%;
            height: 100%;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 2147483646;
            -webkit-filter: grayscale(100%);
               -moz-filter: grayscale(100%);
                -ms-filter: grayscale(100%);
                 -o-filter: grayscale(100%);
                    filter: grayscale(100%);
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
          <a class="location" href="<%- link %>" target="_blank">
            <div class="body" style="transform: translate(<%- positions[0].x %>px, <%- positions[0].y %>px);">
              <img class="body-img" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgJy0vL1czQy8vRFREIFNWRyAxLjEvL0VOJyAnaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkJz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgdmVyc2lvbj0iMS4xIiB5PSIwcHgiIHg9IjBweCIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZpZXdCb3g9IjAgMCAxNiAyMiIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTYgMjIiPjxpbWFnZSBvcGFjaXR5PSIuMiIgeGxpbms6aHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFCSUFBQUFaQ0FZQUFBQThDWDZVQUFBQUNYQklXWE1BQUFzU0FBQUxFZ0hTM1g3OEFBQUEgR1hSRldIUlRiMlowZDJGeVpRQkJaRzlpWlNCSmJXRm5aVkpsWVdSNWNjbGxQQUFBQVpWSlJFRlVlTnFrbGMxTHcwQVF4YlBKcXJWVSBDNjFmMEJZL0Rub1ZQdzZlRlB6VDllQkpQWWpvUlFRVlViRm9wYWh0emZvRzNzcVlOdGl0Z1Y5TDA5MlhtWjAzRXhPRlh5YnoyOGxIIEVpZ1NnM0V3Q2NhVWtBc1JrclZGTUE4V1FRVjhnVStRSmdFaUVrVWRiSUVkc0FCYTRBVjBiSUJJQTJ5RFhiQU1yc0FsRUExakEwWDIgd1NaVGJQSzg1TndpR3lnaTN6WHd3ZitOcmtLSVNJUFI5TzJ6STRqayt1SmZrUXdTR2xsRUM4WEtKOEVpWHNEUTdqTmdIZXpSZEhXSyB4OFAyVGtRL3pJRTFzQUxLM21qRDlvOVZqZGVqNVcrVTBhcU0xZ3dyMUFIMzRBZzhnZzB3QWFaVWwvK01qRHdoSDAyVDNlellTMTAvIEl0U2FsUHZTdkloU3RYQ2FiVkJoaW82alFoN1VaZ0ZTOWRBK1p5ZE1wY2F5bDNsUEluc0FaK0NXMVozMTQ4TkhaOVg0bEUwRlVPTDkgTGlOcGMyUWNnQXRHdWdSZXdUTXorVFVoWXg1c2tZS0dpK1R3VDhBaE9HZFV3alc0QTI4U2xja0lGZWduOGRLcU92UlRjTXpLT2o3USBNYlZlVmtoSFZXSUtWVzZRTTNvQzd3TXM0S0ljb3hrS1dsYk4rNnc3cU94NTc2Zy8zMTk1MTdjQUF3QlJabU1PRlQ0U0lBQUFBQUJKIFJVNUVya0pnZ2c9PSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtMikiIGhlaWdodD0iMjUiIHdpZHRoPSIxOCIgb3ZlcmZsb3c9InZpc2libGUiPjwvaW1hZ2U+PHBvbHlnb24gcG9pbnRzPSI5LjI0MTcgMTguNDc4IDcuMzc4OSAxNy40NzUgNS43NjQyIDE2LjYzNSA4LjMzMiAxMS44MiA0IDExLjgyIDE1LjM3OSAwLjQxMTcgMTUuMzc5IDE2LjQyNyAxMi4wNjMgMTMuMjA2IiBmaWxsPSIjZmZmIi8+PHJlY3QgeT0iOS4wMDU1IiB4PSI4LjY2MzkiIGhlaWdodD0iNy45OTg5IiB0cmFuc2Zvcm09Im1hdHJpeCgtLjg4MjUgLS40NzA0IC40NzA0IC0uODgyNSAxMi4wNzUgMjkuMDI3KSIgd2lkdGg9IjIuMDAwMiIvPjxwb2x5Z29uIHBvaW50cz0iMTQuMDk1IDIuODE5IDE0LjA5NSAxNC4wMDcgMTAuODM4IDEwLjg2MiA2LjA3MDUgMTAuODYyIi8+PC9zdmc+"><!--
              --><div class="create-at"><!-- is-hidden -->
                <span class="create-at--inner is-roboto"><%- createAt %></span>
              </div>
            </div>
            <div class="landscape is-hidden" style="background-size: auto, <%- window.width %>px <%- window.height %>px;"></div>
          </a>
        <\/script>
      """

      # Node の複製
      isTemplateCloneNode = document.importNode(isTemplate.content, true)
   
      # 生成したエレメントをDOMツリーに追加
      document.body.appendChild isEl
      isElShadowRoot.appendChild isTemplateCloneNode



      # ============================================================
      # MODULES
      # ============================================================
      sn.modules =
        stage: require("./modules/stage/index")(App, sn, $, _)
        connect: require("./modules/connect/index")(App, sn, $, _)
        lover: require("./modules/lover/index")(App, sn, $, _, isElShadowRoot)
        memory: require("./modules/memory/index")(App, sn, $, _, isElShadowRoot)


      # ============================================================
      # REGION
      # ============================================================
      appRegion = new Backbone.Marionette.Region
        el: $(isElShadowRoot).find("#is")
        # el: "##{chrome.runtime.id} /deep/ #is"



      # ============================================================
      # LAYOUT VIEW
      # ============================================================
      AppLayoutView = Backbone.Marionette.LayoutView.extend
        # ------------------------------------------------------------
        tagName: "div"
          
        # ------------------------------------------------------------
        className: "is-layout"

        # ------------------------------------------------------------
        initialize: () ->
          console.log "AppLayoutView -> initialize"

        # ------------------------------------------------------------
        template: isElShadowRoot.querySelector("#is-template")

        # ------------------------------------------------------------
        # el: isElShadowRoot.querySelector("#is")

        # ------------------------------------------------------------
        # ui:
        #   lovers: "#is-region__lovers"
        #   memorys: "#is-region__memorys"

        # ------------------------------------------------------------
        regions: 
          lovers: "#is-region__lovers"
          memorys: "#is-region__memorys"


      # 最終的にアプリ起動タイミング（connect setup）に移す
      $.when(
        $.Deferred (defer) =>
          loadQueue = new createjs.LoadQueue()
          loadQueue.setMaxConnections 10

          # loadQueue.addEventListener "fileload", (e) -> console.log e
          loadQueue.addEventListener "complete", (e) ->
            defer.resolve()  

          # createjs.Sound.alternateExtensions = ["mp3"]
          loadQueue.installPlugin createjs.Sound
          loadQueue.loadManifest [
            { id: "imageNoise0", src: "chrome-extension://kcondcikicihkpnhhohgdngemopbdjmi/public/images/extension/noise-0.gif" }
            { id: "soundSignal0", src: "chrome-extension://kcondcikicihkpnhhohgdngemopbdjmi/public/sounds/extension/content-script/sound-effect-signal-0.ogg" }
            { id: "soundNoise0", src: "chrome-extension://kcondcikicihkpnhhohgdngemopbdjmi/public/sounds/extension/content-script/sound-effect-noise-0.ogg" }
          ]
        .promise()
      )
      .then(
        () ->
          App.addRegions
            content: appRegion

          App.content.show(new AppLayoutView())

          App.start()
      )

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