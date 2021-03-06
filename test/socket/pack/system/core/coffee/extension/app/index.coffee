do (window=window, document=document, $=jQuery) ->
  "use strict"

  sn = {}

  require "backbone.validation"
  require "backbone.marionette"
  require "backbone.stickit/backbone.stickit"
  require "velocity/velocity.min"
  require "velocity/velocity.ui.min"
  require "pepjs/dist/pep.min"

  # ============================================================
  # background script
  # ============================================================
  try
    window.bg = chrome.extension.getBackgroundPage()
  catch error
    console.log error

    bg = {}
    bg.appRun = (roomId) ->
      console.log "%c[index] APP RUN", "color: #d9597b", roomId

    bg.appStop = () ->
      console.log "%c[index] APP STOP", "color: #d9597b"

    window.bg = bg

  # ============================================================
  # TypeFrameWork
  # ============================================================
  sn.tf = new TypeFrameWork()

  # ============================================================
  # APPLICATION
  # ============================================================
  App = new Backbone.Marionette.Application()

  # ============================================================
  # Library
  # ============================================================

  $ ->
    console.log SETTING

    # ============================================================
    # MODULES
    # ============================================================
    sn.modules =
      stage: require("./modules/stage/index")(App, sn, $, _)
      connect: require("./modules/connect/index")(App, sn, $, _)

    App.start()

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