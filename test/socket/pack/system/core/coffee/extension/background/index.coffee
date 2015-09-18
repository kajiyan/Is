do (window=window, document=document, $=jQuery) ->
  "use strict"

  console.log SETTING

  window.sn = {}

  # ============================================================
  # TypeFrameWork
  sn.tf = new TypeFrameWork()

  # ============================================================
  # Library
  # ============================================================
  require "backbone.marionette/lib/backbone.marionette.min"

  # ============================================================
  # APPLICATION
  # ============================================================
  Background = new Backbone.Marionette.Application()

  # ============================================================
  # MODULES
  sn.modules =
    stage: require("./modules/stage/")(Background, sn, $, _)
    connect: require("./modules/connect/")(Background, sn, $, _)
    socket: require("./modules/socket/")(Background, sn, $, _)


  window.appRun = (roomId=null) ->
    console.log "APP RUN"
    Background.reqres.request "stageAppRun", roomId
    # Background.execute "stageAppRun"

  window.appStop = () ->
    console.log "APP STOP"
    Background.reqres.request "stageStopApp"
    # Background.execute "stopAppRun"

  $ ->
    # --------------------------------------------------------------
    sn.tf.setup ->
      # $.when(
      #   for key, model of sn.bb.models
      #     model.setup?()
      # ).then( =>
      #   $.when(
      #     console.log "Background Setup Complete"
      #   )
      # )



      Background.addInitializer () ->
        console.log "[Background] addInitializer"


      Background.start()

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
    sn.tf.windowResized ( width, height ) ->
      # console.log width, height

    # --------------------------------------------------------------
    sn.tf.fullScreenChange (full) ->





