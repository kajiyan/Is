module.exports = (window=window, document=document, $=jQuery) ->
  # ============================================================
  # IMPORT MODULE
  # ============================================================
  require("./typeEvent.wp")(window)
  require("./typeThread.wp")(window, document, $)