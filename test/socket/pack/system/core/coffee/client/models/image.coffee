# ============================================================
# Image
module.exports = (sn, $, _) ->
	class Image extends Backbone.Model
    # ------------------------------------------------------------
    defaults:
      file: null
      data: null
      id: null

		
    # ------------------------------------------------------------
    constructor: () ->
      console.log "Model | Image -> Constructor"

      super



    # ------------------------------------------------------------
    initialize: () ->
      console.log "Model | Image -> initialize"

      @on "change:file", @_changeFileHandler
      @on "change:data", @_changeDataHandler
      @on "change:id", @_changeIdHandler



    # ------------------------------------------------------------
    _changeFileHandler: (model, file) ->
      console.log "Model | Image -> _changeFileHandler"

      if file
        # listenFrom Model -> DeviceSensor
        # listenFrom View -> Image
        @trigger "select", @, file
      else
        # listenFrom View -> Image
        @trigger "clear", @



    # ------------------------------------------------------------
    _changeDataHandler: (model, data) ->
      console.log "Model | Image -> _changeDataHandler"

      if data
        @trigger "resize", @, data



    # ------------------------------------------------------------
    _changeIdHandler: (model, id) ->
      console.log "Model | Image -> _changeIdHandler"

      if id
        # listenFrom Model -> DeviceSensor
        @trigger "post", @, id
      


# define([
# 	"backbone",
# ], function(
# 	Backbone){

# 	return new (Backbone.Model.extend({
# 		initialize: function(){
# 			this.on('change:file', this._changeFileHandler);
# 			this.on('change:data', this._changeDataHandler);
# 			this.on('change:id', this._changeIdHandler);
# 		},
# 		_changeFileHandler: function(model, file){
# 			if(file){
# 				this.trigger('select', this, file);
# 			} else {
# 				this.trigger('clear', this);
# 			}
# 		},
# 		_changeDataHandler: function(model, data){
# 			if(data){
# 				this.trigger('resize', this, data);
# 			}
# 		},
# 		_changeIdHandler: function(model, id){
# 			if(id){
# 				this.trigger('post', this, id);
# 			}
# 		}
# 	}))();
# });