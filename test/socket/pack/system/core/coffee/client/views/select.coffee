# ============================================================
# Image
module.exports = (sn, $, _) ->
	class Image extends Backbone.View

		# ------------------------------------------------------------
    constructor: () ->
      console.log "View | Select -> Constructor"

      super

		
    # ------------------------------------------------------------
    el: ".image-select"


    # ------------------------------------------------------------
    events: 
      "touchstart input[type=\"file\"]":      "_pointerdown"
      "mousedown input[type=\"file\"]":       "_pointerdown"
      "MSPointerDown input[type=\"file\"]":   "_pointerdown"
      "pointerdown input[type=\"file\"]":     "_pointerdown"
      "touchend input[type=\"file\"]":        "_pointercancel"
      "touchcancel input[type=\"file\"]":     "_pointercancel"
      "mouseup input[type=\"file\"]":         "_pointercancel"
      "MSPointerUp input[type=\"file\"]":     "_pointercancel"
      "MSPointerCancel input[type=\"file\"]": "_pointercancel"
      "pointerUp input[type=\"file\"]":       "_pointercancel"
      "pointercancel input[type=\"file\"]":   "_pointercancel"
      "change input[type=\"file\"]":          "_change"

    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | Select -> initialize"

      @listenTo sn.__client__.models.image, "select", @_selectHandler
      @listenTo sn.__client__.models.image, "clear", @_clearHandler

    # ------------------------------------------------------------
    _pointerdown: () ->
      console.log "View | Select -> _pointerdown"
      @$el.addClass "highlighted"


    # ------------------------------------------------------------
    _pointercancel: () ->
      console.log "View | Select -> _pointercancel"
      @$el.removeClass "highlighted"


    # ------------------------------------------------------------
    _change: (e) ->
      console.log "View | Select -> _change"

      file = e.target.files[0]
      sn.__client__.models.image.set "file", file


    # ------------------------------------------------------------
    _selectHandler: () ->
      console.log "View | Select -> _selectHandler"
      @$el.hide()
    

    # ------------------------------------------------------------
    _clearHandler: () ->
      console.log "View | Select -> _clearHandler"
      @$el.show()


# define([
#   'backbone',
#   'models/image'
# ], function(
#   Backbone,
#   image){
  
#   return new (Backbone.View.extend({
#     el: '.image-select',
#     events: {
#       'touchstart input[type="file"]': 'touchstart',
#       'touchend input[type="file"]': 'touchend',
#       'touchcancel input[type="file"]': 'touchend',
#       'change input[type="file"]': 'change'
#     },
#     initialize: function(){
#       this.listenTo(image, 'select', this.selectHandler);
#       this.listenTo(image, 'clear', this.clearHandler);
#     },
#     touchstart: function(){
#       this.$el.addClass('highlighted');
#     },
#     touchend: function(){
#       this.$el.removeClass('highlighted');
#     },
#     change: function(event){
#       var file= event.target.files[0];
#       image.set('file', file);
#     },
#     selectHandler: function(){
#       this.$el.hide();
#     },
#     clearHandler: function(){
#       this.$el.show();
#     }
#   }))();
# });