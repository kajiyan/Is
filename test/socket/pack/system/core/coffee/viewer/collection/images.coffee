# ============================================================
# IMAGES
module.exports = (sn, $, _) ->
  class Images extends Backbone.Collection

    # ------------------------------------------------------------
    constructor: () ->
      console.log "Collection | Images -> Constructor"

      # クラスの継承
      super

      @_config = SETTING
      @_host = @_config.HOST

      console.log "---------"
      console.log SETTING
      console.log "---------"

      @_port = @_config.PORT
      @_maxNumberOfImages = @_config.CONFIG.IMAGES.MAX_NUMBER_OF_IMAGES
      @_stubs = @_config.CONFIG.IMAGES.STUBS


    # ------------------------------------------------------------
    initialize: () ->
      console.log "Collection | Images -> Initialize"

    # ------------------------------------------------------------
    # model: require("../models/image")
    model: sn.__viewer__.models.image
      # console.log "==========="
      # console.log require("../models/image")
      # console.log "==========="
    #   console.log "Collection | Images -> model"
      
    #   Image = require("../models/image")
    #   return new Image()
      
      # Image = require("../models/image")
      # return new Image()


    # ------------------------------------------------------------
    setup: () ->
      console.log "Collection | Images -> setup"
      # イベントリスナーの登録
      @_events()

    # ------------------------------------------------------------
    url: () ->
      console.log "Collection | Images -> url"
      return "//#{@_host}:#{@_port}/rooms/#{sn.__viewer__.models.room.get("id")}/images"


    # ------------------------------------------------------------
    parse: (response) ->
      return response.results.splice(response.results.length - @_maxNumberOfImages)


    # ------------------------------------------------------------
    addStubImage: () ->
      console.log "Collection | Images -> addStubImage"

      stub = _(@_stubs).shuffle().pop()
      
      model = new sn.__viewer__.models.image
        id: "stub" + (new Date()).getTime()
        width: stub.width
        height: stub.height
        data: stub.data
      
      @add model
      
      setTimeout =>
        model.set "visible", true
      , 0


    # ------------------------------------------------------------
    _addHandler: () ->
      console.log "Collection | Images -> _addHandler"

      if @length > @_maxNumberOfImages
        @remove @at(0)


    # ------------------------------------------------------------
    _events: ->
      console.log "Collection | Images -> _events"

      @listenTo @, "add", @_addHandler
        
      @listenTo sn.__viewer__.models.room, 'decide', @_decideHandler
      @listenTo sn.__viewer__.models.socket, 'post', @_postHandler
      @listenTo sn.__viewer__.models.socket, 'trigger', @_triggerHandler
      @listenTo sn.__viewer__.models.context, 'clear', @_clearHandler


    # ------------------------------------------------------------
    _decideHandler: () ->
      console.log "Collection | Images -> _decideHandler"

      @fetch reset: true


    # ------------------------------------------------------------
    _postHandler: (data) ->
      console.log "Collection | Images -> _postHandler"

      console.log sn.__viewer__.models.image

      model = new sn.__viewer__.models.image
        id: data.id
        width: data.width
        height: data.height
        data: data.data
        userInfo: data.userInfo
      @add model


    # ------------------------------------------------------------
    _triggerHandler: (id) ->
      console.log "Collection | Images -> _triggerHandler"
      item = @get(id)
      item.set "visible", true  

    # ------------------------------------------------------------
    _clearHandler: () ->
      console.log "Collection | Images -> _clearHandler"
