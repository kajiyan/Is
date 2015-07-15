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
  sn.tf = new TypeFrameWork()


  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->
      console.log "setup content script"

      # # popupとの連携
      # chrome.runtime.onMessage.addListener ( msg, sender, sendResponse ) ->
      #   console.log(msg, sender, sendResponse)
        
      #   ret = $('title').text()
      #   dev = $('title').text()
      #   sendResponse { title: ret }

      

      $html = $("<div>Hello World</div>")
      $("body").prepend($html)
      
      backgroundScriptSender = {}
      backgroundScriptSender = chrome.extension.connect name: "fromContentScript"
      backgroundScriptSender.postMessage joke: "fromContentScript"

      # setTimeout ->
      #   console.log "timeout"
      #   port = chrome.runtime.connect "name": "contentScriptSender"
      #   console.log port
      #   port.onMessage.addListener ( msg ) ->
      #     console.log msg
      # , 10000

      # # backgroundScriptReceiver
      backgroundScriptReceiver = {}

      chrome.runtime.onConnect.addListener ( port ) ->
        console.log port.name
        if port.name is "contentScriptSender"
          backgroundScriptReceiver = port
          backgroundScriptReceiver.onMessage.addListener ( message ) ->
            console.log message

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