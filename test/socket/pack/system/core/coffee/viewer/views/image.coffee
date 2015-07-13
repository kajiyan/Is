# ============================================================
# View | Image
# 
# Depends
#
module.exports = (sn, $, _) ->
  class Image extends Backbone.View

    # ------------------------------------------------------------
    constructor: () ->
      console.log "View | Image -> Constructor"

      super


    # ------------------------------------------------------------
    tagName: "li"


    # ------------------------------------------------------------
    className: "image"


    # ------------------------------------------------------------
    initialize: () ->
      console.log "View | Image -> initialize"

      console.log "-"
      console.log @model
      console.log "-"

      @_config = SETTING.CONFIG.VIEWER.IMAGE

      @listenTo @model, "change:visible", @_changeVisibleHandler
      @listenTo @model, "change:delay", @_changeDelayHandler
      @listenTo @model, "change:position", @_changePositionHandler
      @listenTo @model, "change:scale", @_changeScaleHandler
      @listenTo @model, "remove", @remove


    # ------------------------------------------------------------
    template: _.template(
      '<div class="image-inner">'+
        '<div class="image-inner2">'+
          '<div class="image-inner3">'+
            '<div class="image-inner4">'+
              '<div class="image-inner5">'+
                '<% if(typeof(data)!="undefined"){ %>'+
                  '<img src="<%= data %>" />'+
                '<% } else if(typeof(url)!="undefined") { %>'+
                  '<img src="<%= url %>" />'+
                '<% } %>'+
                '<div class="image-flash"></div>'+
              '</div>'+
            '</div>'+
          '</div>'+
        '</div>'+
      '</div>'
    )

    # ------------------------------------------------------------
    render: () ->
      console.log "View | Image -> render"

      return @$el.html(@template(@model.attributes))










