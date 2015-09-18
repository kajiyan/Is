# ============================================================
# Stage
# 
# EVENT
#   - stageChangeIsRun
#   - stageChangeActiveInfo
# 
# COMMANDS
#   - stageAppRun
#   - stopAppRun
#
# REQUEST RESPONSE
#   - stageGetActiveInfo
#
# ============================================================
module.exports = (App, sn, $, _) ->
  debug = 
    style: "background-color: Black; color: #ffffff;"

  App.module "StageModule", (StageModule, App, Backbone, Marionette, $, _) ->
    console.log "%c[Stage] StageModule", debug.style

    @models = {}

    # ============================================================
    # Controller
    # ============================================================

    # ============================================================
    # Model
    # ============================================================
    StageModel = Backbone.Model.extend
      # ------------------------------------------------------------
      # /** 
      #  * StageModel#defaults
      #  * このクラスのインスタンスを作るときに引数にdefaults に指定されている 
      #  * オブジェクトのキーと同じものを指定すると、その値で上書きされる。 
      #  * @type {Object}
      #  * @prop {boolean} isRun - エクステンションの起動状態
      #  * @prop {string} roomId - 入室する部屋のID
      #  * @prop {Object} activeInfo - 選択されているタブのID
      #  * @prop {number} tabId - 選択されているタブID
      #  * @prop {number} windowId - 選択されているウインドウID
      #  */
      # ------------------------------------------------------------
      defaults:
        isRun: false
        roomId: null
        activeInfo:
          tabId: null
          windowId: null

      # --------------------------------------------------------------
      # /**
      #  * StageModel#initialize
      #  * @constructor
      #  */
      # --------------------------------------------------------------
      initialize: () ->
        console.log "%c[Stage] StageModel -> initialize", debug.style

        # ブラウザアクションが発生した時に呼び出される
        @listenTo @, "change:isRun", @_changeIsRunHandler
        # ブラウザアクションが発生した時にも呼び出される
        # 初回は起動時のtabId, windowIdが設定される
        @listenTo @, "change:activeInfo", @_changeActiveInfoHandler
        
        # chrome.tabs.onCreated.addListener (tab) -> console.log "onCreated", tab
        # chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) -> console.log "onUpdated", tabId, changeInfo, tab

        # アクティブなウインドウが変わった時に呼び出される
        chrome.windows.onFocusChanged.addListener @_onFocusChangedHandler.bind(@)
        # アクティブなタブが変わった時に呼び出される
        chrome.tabs.onActivated.addListener @_onActivatedHandler.bind(@)

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeIsRunHandler
      #  * stageChangeIsRun イベントを発火させる
      #  * @param {Object} Model - BackBone Model Object
      #  */
      # ------------------------------------------------------------
      _changeIsRunHandler: (stageModel, isRun) ->
        console.log "%c[Stage] StageModel -> _changeIsRunHandler", debug.style, isRun
        # console.log chrome.extension.getViews type: "popup"

        App.vent.trigger "stageChangeIsRun", isRun

        if isRun
          chrome.tabs.getSelected (tab) =>
            @set "activeInfo",
              tabId: tab.id
              windowId: tab.windowId

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeActiveInfoHandler
      #  * @param {number} windowId - フォーカスがあったウインドウID
      #  */
      # -----------------------------------------------------------
      _onFocusChangedHandler: (windowId) ->
        console.log "%c[Stage] StageModel -> _onFocusChangedHandler", debug.style, windowId

        chrome.tabs.getSelected (tab) =>
          @set "activeInfo",
            tabId: tab.id
            windowId: tab.windowId

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeActiveInfoHandler
      #  * @param {Object} stageModel - BackBone Model Object
      #  * @param {Object} activeInfo
      #  * @prop {number} tabId - アクティブなタブのID
      #  * @prop {number} windowId - アクティブなウインドウのID
      #  */
      # -----------------------------------------------------------
      _changeActiveInfoHandler: (stageModel, activeInfo) ->
        console.log "%c[Stage] StageModel -> _changeActiveInfoHandler", debug.style, activeInfo
        App.vent.trigger "stageChangeActiveInfo", activeInfo

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_onActivatedHandler 
      #  * @param {Object} activeInfo
      #  */
      # ------------------------------------------------------------
      _onActivatedHandler: (activeInfo) ->
        console.log "%c[Stage] StageModel -> _onActivatedHandler", debug.style, activeInfo

        @set "activeInfo": activeInfo



    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      @models = 
        stage: new StageModel()

      # ============================================================
      # COMMANDS
      # App.commands.setHandler "stageAppRun", (isRun) =>
      #   console.log "%c[Stage] StageModel | stageAppRun", debug.style
      #   @models.stage.set "isRun", true

      # App.commands.setHandler "stopAppRun", (isRun) =>
      #   console.log "%c[Stage] SocketModel | stopAppRun", debug.style
      #   @models.stage.set "isRun", false

      # App.execute "stageAppRun"

      # ============================================================
      # REQUEST RESPONSE
      App.reqres.setHandler "stageAppRun", (roomId) =>
        console.log "%c[Stage] Request Response | stageAppRun", debug.style, roomId
        @models.stage.set
          isRun: true
          roomId: roomId

      App.reqres.setHandler "stageStopApp", () =>
        console.log "%c[Stage] Request Response | stageStopApp", debug.style
        @models.stage.set
          isRun: false

      App.reqres.setHandler "stageGetRoomId", () =>
        console.log "%c[Stage] Request Response | stageGetRoomId", debug.style
        return @models.stage.get "roomId"

      App.reqres.setHandler "stageGetActiveInfo", () =>
        console.log "%c[Stage] Request Response | stageGetActiveInfo", debug.style
        return @models.stage.get "activeInfo"


    # ============================================================
    StageModule.addFinalizer (options) ->
      console.log "%c[Stage] addFinalizer", debug.style, options





























