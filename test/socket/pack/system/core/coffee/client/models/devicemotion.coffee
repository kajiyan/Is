# ============================================================
# DeviceMotion
module.exports = (sn, $, _) ->
	class DeviceMotion extends Backbone.Model

		# ------------------------------------------------------------
		constructor: () ->
			console.log "DeviceMotion -> Constructor"

			super

			@THRESHOLD = 1.5 * 9.8

		# ------------------------------------------------------------
		initialize: () ->
			console.log "DeviceMotion -> initialize"

			# オリジナルはここでthisを固定している
			# _.bindAll(this, 'devicemotionHandler');

		# ------------------------------------------------------------
		start: () ->
			console.log "DeviceMotion -> start"

			# モデルから属性を削除
			@unset "maxKey"
			@unset "maxVal"
			@unset "throwable"

			window.addEventListener "devicemotion", @_devicemotionHandler, false


		# ------------------------------------------------------------
		_devicemotionHandler: (e) =>
			console.log "DeviceMotion -> _devicemotionHandler"

			# デバック用
			# setTimeout =>
			# 	@trigger "devicemotion", @
			# 	@unset "throwable"
			# 	window.removeEventListener "devicemotion", @_devicemotionHandler, false
			# , 4000
			# return

			if not @get "throwable" then return
			
			thres = @THRESHOLD
			acceleration = e.accelerationIncludingGravity
			x = acceleration.x
			y = acceleration.y
			z = acceleration.z
			maxKey = null
			maxVal = null

			if x > thres or y > thres or z > thres
				if not @has "maxKey"
					maxKey = if x > (if y > z then y else z) then "x" else if y > z then "y" else "z"
					maxVal = acceleration[@maxKey]

					@set
						"maxKey": maxKey
						"maxVal": maxVal
				else
					maxKey = @get "maxKey"
					maxVal = acceleration[maxKey]

					if @get "maxVal" < maxVal
						@set "maxVal", maxVal
					else
						@trigger "devicemotion", @
						@unset "throwable"
						window.removeEventListener "devicemotion", @_devicemotionHandler, false
			else
				@unset "maxKey"
				@unset "maxVal"


		# ------------------------------------------------------------


# define([
# 	"backbone"
# ], function(
# 	Backbone){
			
# 	return new (Backbone.Model.extend({
# 		THRESHOLD: 1.5*9.8,
# 		initialize: function(){
# 			_.bindAll(this, 'devicemotionHandler');
# 		},
# 		start: function(){

# 			this.unset('maxKey');
# 			this.unset('maxVal');
# 			this.unset('throwable');

# 			window.addEventListener("devicemotion", this.devicemotionHandler, false);
# 		},
# 		devicemotionHandler: function(event){

# 			if(!this.get('throwable')){
# 				return;
# 			}
	
# 			var thres= this.THRESHOLD,
# 				acceleration= event.accelerationIncludingGravity,
# 				x= acceleration.x,
# 				y= acceleration.y,
# 				z= acceleration.z,
# 				maxKey,
# 				maxVal;
	
# 			if(	x>thres || y>thres || z>thres){
						
# 				if(!this.has('maxKey')){
						
# 					maxKey= x>(y>z?y:z) ? "x" : (y>z?"y":"z");
# 					maxVal= acceleration[this.maxKey];
					
# 					this.set({
# 						maxKey: maxKey,
# 						maxVal: maxVal
# 					});
							
# 				} else {

# 					maxKey= this.get('maxKey');
# 					maxVal= acceleration[maxKey];

# 					if(this.get('maxVal')<maxVal){
					
# 						this.set('maxVal', maxVal);

# 					} else {

# 						this.trigger('devicemotion', this);
						
# 						this.unset('throwable');
# 						window.removeEventListener("devicemotion", this.devicemotionHandler, false);
# 					}
# 				}
						
# 			} else {
			
# 				this.unset('maxKey');
# 				this.unset('maxVal');
# 			}
# 		}
# 	}))();
	
# });