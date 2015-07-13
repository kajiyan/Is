# ============================================================
# Resize
# 
# Depends
# models -> image
module.exports = (sn, $, _) ->
  class Resize extends Backbone.Model

    # ------------------------------------------------------------
    constructor: () ->
      console.log "Model -> Resize -> Constructor"

      super


    # ------------------------------------------------------------
    initialize: () ->
      console.log "Model -> Resize -> initialize"

      @_setting = SETTING

    # ------------------------------------------------------------
    setup: () ->
      console.log "Model -> Resize -> Setup"

      @_events()


    # ------------------------------------------------------------
    _events: () ->
      sn.__client__.models.image.on "select", (model, file) =>
        console.log "Model -> Resize -> Events -> select"        
        console.log file

        canvasResize file
          ,
            "width": @_setting.CONFIG.RESIZE.WIDTH
            "height": @_setting.CONFIG.RESIZE.HEIGHT
            crop: true
            callback: ( data, width, height ) ->
              sn.__client__.models.image.set
                "data": data
                "width": width
                "height": height


        # @_setting.CONFIG.RESIZE.WIDTH

        # fileReader = new FileReader()

        # fileReader.onload = (e) ->
        #   sn.__client__.models.image.set
        #     "data": e.target.result

        # fileReader.readAsDataURL file



# define([
# 	'module',
# 	'canvasResize',
# 	'./image'
# ], function(
# 	module,
# 	canvasResize,
# 	image){
	
# 	image.on('select', function(model, file){

# 		var config= module.config();
					
# 		canvasResize(file, {
# 			width: config.width,
# 			height: config.height,
# 			callback: function(data, width, height){

# 				image.set({
# 					data: data,
# 					width: width,
# 					height: height
# 				});
# 			}
# 		});
# 	});
# });