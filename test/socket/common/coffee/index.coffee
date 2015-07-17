do (window=window, document=document, $=jQuery) ->
  "use strict"

  window.SETTING = require("setting")() # option {m: "production"}
  
  # window.sn = $.typeApp = {}
  window.common = {}

  # ============================================================
  # TypeFrameWork
  require("./typeFrameWork/typeFrameWork.wp")(window, document, $)
  common.tf = new $.TypeFrameWork()


  # ============================================================
  # Library
  require "imports?this=>window!modernizr/modernizr"
  require "devicejs/lib/device.min.js"

  # ============================================================
  # Detect / Normalize event names


  $ ->
    # ============================================================
    # Module

    # --------------------------------------------------------------
    common.tf.setup ->
      $.when(
        console.log "- SETUP COMMON JAVA SCRIPT -"
      )

    # --------------------------------------------------------------
    common.tf.update ->

    # --------------------------------------------------------------
    common.tf.draw ->
   
    # --------------------------------------------------------------
    common.tf.hover ->
   
    # --------------------------------------------------------------
    common.tf.keyPressed (key) ->
   
    # --------------------------------------------------------------
    common.tf.keyReleased (key) ->
   
    # --------------------------------------------------------------
    common.tf.click ->
   
    # --------------------------------------------------------------
    common.tf.pointerDown ->

    # --------------------------------------------------------------
    common.tf.pointerEnter ->

    # --------------------------------------------------------------
    common.tf.pointerLeave ->

    # --------------------------------------------------------------
    common.tf.pointerMoved ->

    # --------------------------------------------------------------
    common.tf.pointerOut ->

    # --------------------------------------------------------------
    common.tf.pointerOver ->

    # --------------------------------------------------------------
    common.tf.pointerUp ->
    
    # --------------------------------------------------------------
    common.tf.windowScroll (top) ->
   
    # --------------------------------------------------------------
    common.tf.windowResized (width, height) ->
      # window.common.stage.windowResized()
   
    # --------------------------------------------------------------
    common.tf.fullScreenChange (full) ->