connect = ( ob ) ->
  console.log "[stage] connect", ob

  chrome.tabs.query
    active: true
    currentWindow: true
    ,
    ( tabs ) ->
      console.log tabs

      # 送信先のタブ
      # 送信するメッセージ
      # レスポンス
      chrome.tabs.sendMessage tabs[0].id
        ,
        ob
        ,
        ( response ) ->
          if response?
            unconnectedData = ob;
          else
            unconnectedData = null;





# chrome.tabs.onCreated.addListener ( e ) ->
#   console.log "onCreated", e

# chrome.tabs.onUpdated.addListener ( e ) ->
#   console.log "onUpdated", e

# chrome.tabs.onSelectionChanged.addListener ( e ) ->
#   console.log "onSelectionChanged", e

# chrome.tabs.onActiveChanged.addListener ( e ) ->
#   console.log "onActiveChanged", e

# chrome.tabs.onActivated.addListener ( e ) ->
#   connect()
#   console.log "onActivated", e

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

do (window=window, document=document, $=jQuery) ->
  "use strict"

  $html = $("<div>Background Hello World</div>")
  $("body").append($html)

  window.test = () ->
    return "bg test"

  # ============================================================
  # TypeFrameWork
  sn.tf = new TypeFrameWork()

  # ============================================================
  # BackBone
  sn.bb =
    models: null
    collections: null
    views: null

  # ============================================================
  # BackBone MODEL
  sn.bb.models =
    stage: do ->
      Stage = require("./models/stage")(sn, $, _)
      return new Stage()



  # ============================================================
  # BackBone COLLECTION


  # ============================================================
  # BackBone VIEW  


  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->
      $.when(
        for key, model of sn.bb.models
          model.setup?()
      ).then( =>
        $.when(
          console.log "Background Setup Complete"
        )
      )

      

      # chrome.tabCapture.capture
      #   audio: false
      #   video: true
      #   videoConstraints:
      #     mandatory:
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



      # chrome.tabs.onCreated.addListener ( e ) ->
      #   console.log "onCreated", e

      # chrome.tabs.onUpdated.addListener ( e ) ->
      #   console.log "onUpdated", e

      # chrome.tabs.onSelectionChanged.addListener ( e ) ->
      #   console.log "onSelectionChanged", e

      # chrome.tabs.onActiveChanged.addListener ( e ) ->
      #   console.log "onActiveChanged", e

      # chrome.tabs.onActivated.addListener ( e ) ->
      #   console.log "onActivated", e

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


      # content scriptと通信
      chrome.extension.onConnect.addListener ( port ) ->
        console.assert(port.name == "knockknock")
        port.onMessage.addListener ( msg ) ->
          if msg.joke is "Knock knock"
            port.postMessage question: "Who's there?"
          else if msg.answer is "Madame"
            port.postMessage question: "Madame who?"
          else if msg.answer is "Madame... Bovary"
            port.postMessage question: "I don't get it."  

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