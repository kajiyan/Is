bg = chrome.extension.getBackgroundPage()
console.log bg
console.log bg.test()

# click = (e) ->
#   console.log("test");

# alert ""

# document.addEventListener "DOMContentLoaded", () ->
#   divs = document.querySelectorAll 'div'
#   for i in [0...divs.length]
#     divs[i].addEventListener 'click', click

do (window=window, document=document, $=jQuery) ->
  "use strict"

  # alert "click"
  
    # for i in [0...divs.length]
      # alert i
      # divs[i].addEventListener('click', click);


  # chrome.browserAction.onClicked.addListener () ->
  # alert "click"

  console.log io


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

    # --------------------------------------------------------------
    sn.tf.setup ->
      util = require("./helper/util")(sn)
      console.log util

      chrome.tabs.onActivated.addListener ( e ) ->
        console.log( e );
        

      chrome.windows.onFocusChanged.addListener ( e ) ->
        console.log( e );
      
      chrome.tabCapture.capture
        audio: false
        video: true
        videoConstraints:
          mandatory:
            maxWidth: 1000
            minWidth: 1000
            maxHeight: 1000
            minHeight: 1000
        ,
        ( stream ) ->
          video = document.createElement "video"
          $("body").append(video)
          video.src = window.URL.createObjectURL stream
          video.play();


      # chrome.tabCapture.capture(
      #   {
      #     audio:false,
      #     video:true,
      #     videoConstraints:{
      #       mandatory: {
      #         chromeMediaSource: 'tab',
      #         minWidth: tabW,
      #         maxWidth: tabW,
      #         minHeight: tabH,
      #         maxHeight: tabH
      #       }
      #     }
      #   },function(stream){
      #     that.stream = stream;
      #     var video = document.createElement('video');
      #     that.video = video;
      #     video.src = window.URL.createObjectURL(stream);
      #     video.addEventListener('canplay',function(event){
      #       deferred.resolve();
      #     });
      #     video.play();
      #   });


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