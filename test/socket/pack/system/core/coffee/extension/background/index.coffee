do (window=window, document=document, $=jQuery) ->
  "use strict"

  console.log SETTING

  sn = {}

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
      stage = new Stage
        "debug": true
      return stage
    # connect: do ->
    #   Connect = require("./models/connect")(sn, $, _)
    #   return new Connect()
    # socket: do ->
    #   Socket = require("./models/socket")(sn, $, _)
    #   return new Socket()


  # ============================================================
  # BackBone COLLECTION


  # ============================================================
  # BackBone VIEW  


  window.appRun = () ->
    console.log "%cAPP RUN", "color: #999999"
    Background.execute "stageAppRun"
    sn.bb.models.stage.set "isRun", true


  window.appStop = () ->
    console.log "%cAPP STOP", "color: #999999"
    Background.execute "stopAppRun"
    sn.bb.models.stage.set "isRun", false


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





