# ============================================================
# INDEX
module.exports = (sn, $, _) ->
  class sn.Router extends Backbone.Router
    constructor: (options) ->
      super

      # ルーターで処理する要素
      defaults =
        module: {}
        pages: {}
        popup: {}

      @$window = $(window)
      @$body = $("body")

      @viewPage = null
      @viewAfterPage = null
      @transition = false

    initialize: () ->
      console.log "Router -> initialize"

    routes:
      "client(/)(:roomid)": () ->
        client = require("../client")(sn, $, _)
        client.setup()
      "bridge(/)": () ->
        bridge = require("../bridge")(sn, $, _)
        bridge.setup()
      "*default": () ->
        viewer = require("../viewer")(sn, $, _)
        viewer.setup()

    setup: () ->
      return $.Deferred (defer) =>
        onDone = =>
          console.log "Router -> setup"
          defer.resolve()

        Backbone.history.start
          pushState: true
          root: SETTING.BASE_PATH

        onDone()
      .promise()

    request: (param) ->
      # console.log "Router -> request -> (#{param})"
      # @options.pages[param].setup(true)

# URLを切り替える
# @navigate param, trigger: false