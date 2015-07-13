# ============================================================
# View | Images
# 
# Depends
#
# Model
# - context
# 
# Collection
# - images
#
# View
# - image
module.exports = (sn, $, _) ->
  class Images extends Backbone.View

    # ------------------------------------------------------------
    constructor: () ->
      console.log "View | Images -> Constructor"

      super

    # ------------------------------------------------------------
    collection: sn.__viewer__.collections.images

    # ------------------------------------------------------------
    el: $("#images")

    # ------------------------------------------------------------
    events: {}

    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | Images -> initialize"

      @_modes = {}
        # layered: new Layered(@collection)
        # grid: new Grid(@collection) 

      @_views = []


    # ------------------------------------------------------------
    setup: () ->
      console.log "View | Images -> setup"

      @listenTo @collection, "add", @_addHandler
      @listenTo @collection, "reset", @_resetHandler
      @listenTo @collection, "change:visible", @_changeVisibleHandler
      @listenTo sn.__viewer__.models.mode, "change:mode", @_changeModeHandler


    # ------------------------------------------------------------
    _append: (image) ->
      console.log "View | Images -> _append"

      view = new sn.__viewer__.views.image
        model: image

      @$el.append view.render()
      @_views.push view


    # ------------------------------------------------------------
    _addHandler: (image) ->
      console.log "View | Images -> _addHandler"

      @_append image
      _.invoke @_modes, "addHandler"


    # ------------------------------------------------------------
    _resetHandler: (collection) ->
      console.log "View | Images -> _resetHandler"


    # ------------------------------------------------------------
    _changeVisibleHandler: () ->
      console.log "View | Images -> _changeVisibleHandler"


    # ------------------------------------------------------------
    _changeModeHandler: (model, mode) ->
      console.log "View | Images -> _changeModeHandler"


    # ------------------------------------------------------------
    _resizeHandler: () ->
      console.log "View | Images -> _resizeHandler"

