do (window=window, document=document, $=jQuery) ->
  "use strict"

  # ============================================================
  # TypeFrameWork
  sn.tf = new TypeFrameWork()

  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->
      console.log "setup content script"

      # chrome.tabs.onCreated.addListener ( e ) ->
      #   console.log "onCreated", e

      # chrome.tabs.onUpdated.addListener ( e ) ->
      #   console.log "onUpdated", e

      # chrome.tabs.onSelectionChanged.addListener ( e ) ->
      #   console.log "onSelectionChanged", e

      # chrome.tabs.onActiveChanged.addListener ( e ) ->
      #   console.log "onActiveChanged", e

      # chrome.tabs.onActivated.addListener ( e ) ->
        # console.log "onActivated", e

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


      dev = ""

      # popupとの連携
      chrome.runtime.onMessage.addListener (msg, sender, sendResponse ) ->
        ret = $('title').text()
        dev = $('title').text()
        sendResponse { title: ret }

      setInterval ->
        console.log dev
        # clearInterval(timer)
      , 1000

      # setTimeout ->
      #   console.log "timeout"
      #   chrome.tabCapture.capture
      #     audio: false
      #     video: true
      #     videoConstraints:
      #       mandatory:
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

      # , 4000
      

      $html = $("<div>Hello World</div>")
      $("body").append($html)
      
      port = chrome.extension.connect name: "knockknock"
      port.postMessage joke: "Knock knock"
      port.onMessage.addListener (msg) ->
        console.log msg
        if msg.question is "Who's there?"
          port.postMessage answer: "Madame"
        else if msg.question is "Madame who?"
          port.postMessage answer: "Madame... Bovary"

      console.log port

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