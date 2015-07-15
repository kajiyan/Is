


# document.addEventListener "DOMContentLoaded", () ->
#   divs = document.querySelectorAll 'div'
#   for i in [0...divs.length]
#     divs[i].addEventListener 'click', click

do (window=window, document=document, $=jQuery) ->
  "use strict"

  # background scriptを取得
  bg = chrome.extension.getBackgroundPage()

  bg.sn.bb.models.stage.set "isBrowserAction", true

  # alert "click"
  
    # for i in [0...divs.length]
      # alert i
      # divs[i].addEventListener('click', click);


  # chrome.browserAction.onClicked.addListener () ->
  # alert "click"
  

  # console.log io



  # ============================================================
  # TypeFrameWork
  sn.tf = new TypeFrameWork()

  # ============================================================
  # Library


  # ============================================================
  # Detect / Normalize event names

  # ============================================================
  # Module
  # sn.router = do ->
  #   Router = require("./router/index")(sn, $, _)
  #   return new Router()

  $(window).load ->
    console.log SETTING

    $console = $("#js__console")

    # --------------------------------------------------------------
    sn.tf.setup ->
      util = require("./helper/util")(sn)
      # console.log util

      # # タブの一覧を取り出す
      # chrome.tabs.query
      #   active: true
      #   # active: false
      #   # lastFocusedWindow: false
      #   # currentWindow: false
      #   ,
      #   ( tabs ) ->
      #     console.log tabs

      #     for tab, index in tabs
      #       $console.text(index)
      #       # console.log a,b

      #     $console.text(tabs[0].id)

      #     chrome.tabs.sendMessage tabs[0].id
      #       ,
      #       text: "popup"
      #       ,
      #       ( response ) ->
      #         $console.text(response)
      #         url = tabs[0].url
      #         $('#place').text(response.title + ' ' + url)

      # $('#place').text('test')


    # --------------------------------------------------------------
    sn.tf.update ->

    # --------------------------------------------------------------
    sn.tf.draw ->
   
    # --------------------------------------------------------------
    sn.tf.hover ->
   
    # --------------------------------------------------------------
    sn.tf.keyPressed (key) ->
   
    # --------------------------------------------------------------
    sn.tf.keyReleased (key) ->
   
    # --------------------------------------------------------------
    sn.tf.click ->
   
    # --------------------------------------------------------------
    sn.tf.pointerDown ->

    # --------------------------------------------------------------
    sn.tf.pointerEnter ->

    # --------------------------------------------------------------
    sn.tf.pointerLeave ->

    # --------------------------------------------------------------
    sn.tf.pointerMoved ->

    # --------------------------------------------------------------
    sn.tf.pointerOut ->

    # --------------------------------------------------------------
    sn.tf.pointerOver ->

    # --------------------------------------------------------------
    sn.tf.pointerUp ->
    
    # --------------------------------------------------------------
    sn.tf.windowScroll (top) ->
      # sn.stage.windowScroll top

    # --------------------------------------------------------------
    sn.tf.windowResized (width, height) ->
      # common.stage.windowResized()
      # sn.stage.windowResized width, height
   
    # --------------------------------------------------------------
    sn.tf.fullScreenChange (full) ->