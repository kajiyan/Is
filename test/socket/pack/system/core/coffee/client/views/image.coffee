# ============================================================
# Image
module.exports = (sn, $, _) ->
  class Image extends Backbone.View
    # ------------------------------------------------------------
    constructor: () ->
      console.log "View | Image -> Constructor"

      super

    
    # ------------------------------------------------------------
    el: "#image"


    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | Image -> initialize"

      @model = sn.__client__.models.image
      
      @listenTo @model, "select", @_selectHandler
      @listenTo @model, "post", @_postHandler      
      
      @listenTo sn.__client__.models.deviceSensor, "throw", @_throwHandler


    # ------------------------------------------------------------
    _selectHandler: () ->
      console.log "View | Image -> _selectHandler"


    # ------------------------------------------------------------
    _postHandler: (model, id) ->
      console.log "View | Image -> _postHandler"

      console.log "------------------"
      console.log model.get "data"
      console.log "------------------"

      originalImageWidth = model.get "width"
      originalImageHeight = model.get "height"
      isLandscape = originalImageWidth > originalImageHeight
      imageWidth = if isLandscape then originalImageHeight else originalImageWidth
      imageHeight = if isLandscape then originalImageWidth else originalImageHeight
      
      $imageHolder = $("#js-image-holder")
      
      parentWidth = $imageHolder.width()
      parentHeight = $imageHolder.height()
      rx = parentWidth / imageWidth
      ry = parentHeight / imageHeight
      r = if rx < ry then rx else ry
      imageWidth = imageWidth * r
      imageHeight = imageHeight * r

      $imageHolder.find(".image-body").attr
        "src": model.get "data"

      $imageHolder
        .find ".image-holder-load-img"
        .addClass "is-hidden"

      $imageHolder
        .find ".image-holder-label"
        .removeClass "is-hidden"

      # console.log model.get "data"

      # @$el
      #   .queue (next) ->
      #     $(@)
      #       .find(".image-inner2")
      #       .css
      #         width: imageWidth + "px"
      #         height: imageHeight + "px"
      #     next()

      #   .waitTransition()
      #   .queue(function(next){
      #     var w= isLandscape ? imageHeight : imageWidth,
      #       h= isLandscape ? imageWidth : imageHeight;
      #     $(this)
      #       .addClass('throwable')
      #       .find('.image-img')
      #         .removeClass('hidden')
      #         .toggleClass('rotated', isLandscape)
      #         .attr({
      #           'width': w+'px',
      #           'height': h+'px',
      #           'src': model.get('data')
      #         })
      #       .end()
      #       .find('.image-mosaic')
      #         .addClass('hidden');
      #     next();
      #   });


    # ------------------------------------------------------------
    _throwHandler: () ->
      console.log "View | Image -> _throwHandler"

      @_clear()


    # ------------------------------------------------------------
    _fly: (callback, context) ->
      console.log "View | Image -> _fly"

      # @$el
      #   .queue (next) ->
      #     $(@).addClass "trigger"
      #     next()
      #   .waitAnimation()
      #   .queue(function(next){
      #     callback.call(context);
      #     next();
      #   });

      # this.$el
      #   .queue(function(next){
      #     $(this).addClass("trigger");
      #     next();
      #   })
      #   .waitAnimation()
      #   .queue(function(next){
      #     callback.call(context);
      #     next();
      #   });

    # ------------------------------------------------------------
    _clear: (callback, context) ->
      console.log "View | Image -> _clear"

      $imageHolder = $("#js-image-holder")

      # モデルの削除は Socket -> _devicesensorThrowHandler の
      # 処理が終わったタイミングで実行した方がいい
      $imageHolder
        .find ".image-body"
        .removeAttr "src"

      $imageHolder
        .find ".image-holder-load-img"
        .removeClass "is-hidden"

      $imageHolder
        .find ".image-holder-label"
        .addClass "is-hidden"


      
      # @model.clear()


    # ------------------------------------------------------------
    _restore: () ->
      console.log "View | Image -> _restore"


# define([
#   'module',
#   "backbone",
#   "models/image",
#   "models/devicesensor",
#   "jquery.css-animation-queue"
# ], function(
#   module,
#   Backbone,
#   model,
#   devicesensor){
  
#   return new (Backbone.View.extend({
#     el: "#image",
#     initialize: function(){
    
#       this.model= model;
#       this.listenTo(this.model, 'select', this._selectHandler);
#       this.listenTo(this.model, 'post', this._postHandler);
      
#       this.listenTo(devicesensor, 'throw', this._throwHandler);
#     },
#     _selectHandler: function(){
# /*      this.$('.image-img').addClass('hidden'); */
# /*      this.$el.addClass('loading'); */
#     }, 
#     _postHandler: function(model, id){

#       var originalImageWidth= model.get('width'),
#         originalImageHeight= model.get('height'),
#         isLandscape= originalImageWidth>originalImageHeight,
#         imageWidth= isLandscape ? originalImageHeight : originalImageWidth,
#         imageHeight= isLandscape ? originalImageWidth : originalImageHeight,
#         $inner= this.$('.image-inner'),
#         parentWidth= $inner.width(),
#         parentHeight= $inner.height(),
#         rx= parentWidth/imageWidth,
#         ry= parentHeight/imageHeight,
#         r= rx<ry ? rx : ry,
#         imageWidth= imageWidth*r,
#         imageHeight= imageHeight*r;

#       this.$el
#         .queue(function(next){
#           $(this).find('.image-inner2')
#             .css({
#               width: imageWidth+'px',
#               height: imageHeight+'px'
#             });
#           next();
#         })
#         .waitTransition()
#         .queue(function(next){
#           var w= isLandscape ? imageHeight : imageWidth,
#             h= isLandscape ? imageWidth : imageHeight;
#           $(this)
#             .addClass('throwable')
#             .find('.image-img')
#               .removeClass('hidden')
#               .toggleClass('rotated', isLandscape)
#               .attr({
#                 'width': w+'px',
#                 'height': h+'px',
#                 'src': model.get('data')
#               })
#             .end()
#             .find('.image-mosaic')
#               .addClass('hidden');
#           next();
#         });
#     },
#     _throwHandler: function(){
      
#       this._fly(function(){
#         this._clear(function(){
#           this._restore();
#         }, this);
#       }, this);
#     },
#     _fly: function(callback, context){
#       this.$el
#         .queue(function(next){
#           $(this).addClass("trigger");
#           next();
#         })
#         .waitAnimation()
#         .queue(function(next){
#           callback.call(context);
#           next();
#         });
#     },
#     _clear: function(callback, context){
#       this.model.clear();
      
#       this.$el
#         .removeClass('throwable')
#         .queue(function(next){
#           $(this).find('.image-inner2')
#             .css({
#               width: '',
#               height: ''
#             });
#           next();
#         })
#         .waitTransition()
#         .queue(function(next){
#           $(this)
#             .find('.image-img')
#               .addClass('hidden')
#               .removeClass('rotated')
#               .removeAttr('width height src')
#             .end()
#             .find('.image-mosaic')
#               .removeClass('hidden');
#           next();
#         })
#         .wait(0)
#         .queue(function(next){
#           callback.call(context);
#           next();
#         });
#     },
#     _restore: function(){
#       this.$el
#         .queue(function(next){
#           $(this).addClass("restore");
#           next();
#         })
#         .waitAnimation()
#         .queue(function(next){
#           $(this).removeClass("trigger restore");
#           next();
#         });
#     }
#   }))();
# });