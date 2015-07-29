# popupとの連携
chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
  console.log(msg, sender, sendResponse)
  
  ret = $('title').text()
  dev = $('title').text()
  sendResponse { title: ret }

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
  require "pepjs/dist/pep.min"

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
      console.log "- SETUP CONTENT SCRIPT -"

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