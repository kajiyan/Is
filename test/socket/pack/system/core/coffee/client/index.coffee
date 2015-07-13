# ============================================================
# CLIENT
module.exports = (sn, $, _) ->
  # ============================================================
  # Librarys
  # require("./libraries/binaryajax")
  # require("./libraries/exif")
  # require("./libraries/canvasResize")

  # console.log canvasResize

  class Client
    constructor: (options) ->
      console.log "http://#{SETTING.HOST}:#{SETTING.PORT}/"

      console.log "Client -> constructor"

      # ============================================================
      # BackBone Models
      sn.__client__ =
        models: null
        collections: null
        views: null

      # ============================================================
      # Models
      # MODEL
      sn.__client__.models =
        socket: do ->
          Socket = require("./models/socket")(sn, $, _)
          return new Socket()
        devicemotion: do ->
          Devicemotion = require("./models/devicemotion")(sn, $, _)
          return new Devicemotion()
        deviceOrientation: do ->
          DeviceOrientation = require("./models/deviceOrientation")(sn, $, _)
          return new DeviceOrientation()
        deviceSensor: do ->
          DeviceSensor = require("./models/deviceSensor")(sn, $, _)
          return new DeviceSensor()
        image: do ->
          Image = require("./models/image")(sn, $, _)
          return new Image()
        resize: do ->
          Resize = require("./models/resize")(sn, $, _)
          return new Resize()
        context: do ->
          Context = require("./models/context")(sn, $, _)
          return new Context()
        visual: do ->
          Visual = require("./models/visual")(sn, $, _)
          return new Visual()

      # COLLECTION


      # VIEW
      sn.__client__.views =
        image: do ->
          Image = require("./views/image")(sn, $, _)
          return new Image()
        select: do ->
          Select = require("./views/select")(sn, $, _)
          return new Select()
        readText: do ->
          ReadText = require("./views/readText")(sn, $, _)
          return new ReadText()
        readLightValue: do ->
          ReadLightValue = require("./views/readLightValue")(sn, $, _)
          return new ReadLightValue()


      # ============================================================
      # Views

    setup: () ->
      console.log "Client -> setup"

      # sn.__client__.models.socket.setup()
      # sn.__client__.models.context.setup()

      for key of sn.__client__.models
        sn.__client__.models[key].setup?()

  return Instance = new Client(sn, $, _)





# # console.log TypeEvent
# # console.log $.TypeFrameWork
# # console.log $.TypeThread

# # console.log $
# # console.log _
# # console.log Backbone

# # $(window).load (window, document, $=jQuery) ->
# # do (window, document, $=jQuery) ->

# # $(window).load ->
# # do () ->
# (data) ->
#   "use strict"

#   # sn = $.typeApp = {}
#   # sn.SETTING = require "setting"

#   # # ============================================================
#   # # TypeFrameWork
#   # require("./typeFrameWork.wp")(window, document, $)
#   # sn.tf = new $.TypeFrameWork()

#   # # ============================================================
#   # # Library

#   # # ============================================================
#   # # Models
#   # sn.context = do ->
#   #   Context = require("./models/context")
#   #   return new Context(sn, $, _)
#   # sn.images = do ->
#   #   Images = require("./collection/images")(sn, $, _)
#   #   return new Images()


#   # # ============================================================
#   # # Views
#   # sn.views =
#   #   header: do ->
#   #     Header = require("./views/header")(sn, $, _)
#   #     return new Header()
#   #   footer: do ->
#   #     Footer = require("./views/footer")(sn, $, _)
#   #     return new Footer()


#   # # ============================================================
#   # # Router
#   # sn.router = do ->
#   #   Router = require("./router/index")(sn, $, _)
#   #   return new Router()
    

#   $ ->
#     # ============================================================
#     # StageClass ( Test Class )
#     class sn.Stage extends TypeEvent
#       constructor: () ->
#         super
#         @
 
#     # ============================================================
#     # Module

#     # ============================================================
#     # PAGE

#     # ============================================================
#     # POPUP
 
#     # --------------------------------------------------------------
#     sn.tf.setup ->
#       # $.when(
#       #   sn.router.setup()
#       # ).then( =>
#       #   # sn.context.setup()
#       #   # sn.images.setup()
#       # ).then( =>
#       #   # sn.context.run()
#       #   console.log "- SETUP APP -"
#       # )

#     # --------------------------------------------------------------
#     sn.tf.update ->

#     # --------------------------------------------------------------
#     sn.tf.draw ->
   
#     # --------------------------------------------------------------
#     sn.tf.hover ->
   
#     # --------------------------------------------------------------
#     sn.tf.keyPressed (key) ->
   
#     # --------------------------------------------------------------
#     sn.tf.keyReleased (key) ->
   
#     # --------------------------------------------------------------
#     sn.tf.click ->
   
#     # --------------------------------------------------------------
#     sn.tf.pointerDown ->

#     # --------------------------------------------------------------
#     sn.tf.pointerEnter ->

#     # --------------------------------------------------------------
#     sn.tf.pointerLeave ->

#     # --------------------------------------------------------------
#     sn.tf.pointerMoved ->

#     # --------------------------------------------------------------
#     sn.tf.pointerOut ->

#     # --------------------------------------------------------------
#     sn.tf.pointerOver ->

#     # --------------------------------------------------------------
#     sn.tf.pointerUp ->
    
#     # --------------------------------------------------------------
#     sn.tf.windowScroll (top) ->
   
#     # --------------------------------------------------------------
#     sn.tf.windowResized (width, height) ->
   
#     # --------------------------------------------------------------
#     sn.tf.fullScreenChange (full) ->