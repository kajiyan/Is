# ============================================================
# HEADER
module.exports = (sn, $, _) ->
  class Header extends Backbone.View

    # ------------------------------------------------------------
    constructor: () ->
      console.log "Header -> Constructor"

      super

    # ------------------------------------------------------------
    el: "#header"

    # ------------------------------------------------------------
    events: 
      'click .btn-fullScreen': '_clickFullScreenHandler'

    # ------------------------------------------------------------
    initialize: () ->
      console.log "Header -> initialize"

    # ------------------------------------------------------------
    _toggleFullScreen: () ->
      console.log "Header -> _toggleFullScreen"

    # ------------------------------------------------------------
    _clickFullScreenHandler: () ->
      console.log "Header -> _clickFullScreenHandler"




# define([
# 	'../models/context',
# 	'backbone'
# ], function(
# 	context,
# 	Backbone){
		
# 	return Backbone.View.extend({
# 		el: '#header',
# 		events: {
# 			'click .btn-fullScreen': '_clickFullScreenHandler'
# 		},
# 		_toggleFullScreen: function(){
# 			var doc= document,
# 				docElem= doc.documentElement;
				
# 			if(	(doc.fullScreenElement && doc.fullScreenElement!==null)||
# 				(!doc.mozFullScreen && !doc.webkitIsFullScreen)){
# 				if(docElem.requestFullScreen){
# 					docElem.requestFullScreen();
# 				} else if(docElem.mozRequestFullScreen){
# 					docElem.mozRequestFullScreen();
# 				} else if(docElem.webkitRequestFullscreen){
# 					docElem.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
# /*
# 				} else if(docElem.webkitRequestFullScreen){
# 					docElem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
# */
# 				}
# 			} else {
# 				if (doc.cancelFullScreen) {
# 					doc.cancelFullScreen();
# 				} else if (doc.mozCancelFullScreen) {
# 					doc.mozCancelFullScreen();
# 				} else if (doc.webkitCancelFullScreen) {
# 					doc.webkitCancelFullScreen();
# 				}
# 			}
# 		},
# 		_clickFullScreenHandler: function(){
# 			this._toggleFullScreen();
# 			return false;
# 		}
# 	});
# });