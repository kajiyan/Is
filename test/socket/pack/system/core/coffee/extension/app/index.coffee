do (window=window, document=document, $=jQuery) ->
  "use strict"

  sn = {}

  require "backbone.validation"
  require "backbone.marionette"
  require "backbone.stickit/backbone.stickit"

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

    App.start()

    # # ============================================================
    # # BackBone
    # # ============================================================
    # sn.bb =
    #   models: null
    #   collections: null
    #   views: null

    # # ============================================================
    # # BackBone MODEL

    # # ============================================================
    # # BackBone COLLECTION

    # # ============================================================
    # # BackBone - VIEW
    # sn.bb.views =
    #   "stage": do ->
    #     Stage = require("./views/stage")(sn, $, _)
    #     return new Stage()

    # # --------------------------------------------------------------
    # sn.tf.setup ->
    #   # util = require("./helper/util")(sn)

    #   $.when(
    #     for key, model of sn.bb.models
    #       model.setup?()
    #   ).then( =>
    #     $.when(
    #       for key, view of sn.bb.views
    #         view.setup?()
    #     )
    #   ).then( =>
    #     $.when(
    #       console.log "%cPopup Setup Complete", "color: #d9597b"
    #     )
    #   )


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