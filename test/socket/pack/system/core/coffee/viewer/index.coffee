# ============================================================
# VIEWER
module.exports = (sn, $, _) ->
  # ============================================================
  # Librarys

  class Viewer
    constructor: (options) ->
      console.log "Viewer -> constructor"

      # ============================================================
      # BackBone Models
      sn.__viewer__ =
        models: null
        collections: null
        views: null

      # MODEL
      sn.__viewer__.models =
        image: do ->
          return Image = require("./models/image")(sn, $, _)
        mode: do ->
          Mode = require("./models/mode")(sn, $, _)
          return new Mode()
        room: do ->
          Room = require("./models/room")(sn, $, _)
          return new Room()
        socket: do ->
          Socket = require("./models/socket")(sn, $, _)
          return new Socket()
        context: do ->
          Context = require("./models/context")(sn, $, _)
          return new Context()

      # COLLECTION
      sn.__viewer__.collections = 
        images: do ->
          Images = require("./collection/images")(sn, $, _)
          return new Images()

      # VIEW
      sn.__viewer__.views =
        header: do ->
          Header = require("./views/header")(sn, $, _)
          return new Header()
        footer: do ->
          Footer = require("./views/footer")(sn, $, _)
          return new Footer()
        image: do ->
          return Image = require("./views/image")(sn, $, _)
          # return new Image()
        images: do ->
          Images = require("./views/images")(sn, $, _)
          return new Images()


    setup: () ->
      console.log "Viewer -> setup"

      for key of sn.__viewer__.models
        sn.__viewer__.models[key].setup?()

      for key of sn.__viewer__.collections
        sn.__viewer__.collections[key].setup?()

      for key of sn.__viewer__.views
        sn.__viewer__.views[key].setup?()

  return Instance = new Viewer(sn, $, _)