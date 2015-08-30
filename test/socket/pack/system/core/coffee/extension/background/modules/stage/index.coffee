# ============================================================
# Stage
# 
# EVENT
#   - stageChangeIsRun
#   - stageSelsectedTabId
# 
# COMMANDS
#   - stageAppRun
#   - stopAppRun
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
      #  * @prop {number} selsectedTabId - 選択されているタブのID
      #  */
      # ------------------------------------------------------------
      defaults:
        isRun: false
        activeInfo:
          tabId: null
          windowId: null
        # selsectedTabId: null

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
        @listenTo @, "change:activeInfo", @_changeActiveInfoHandler
        #(model, activeInfo) -> console.log activeInfo
        # ブラウザアクションが発生した時に呼び出される
        # 初回は起動時のtab idが設定される
        # @listenTo @, "change:selsectedTabId", @_changeSectedTabIdHandler

        # chrome.tabs.onCreated.addListener (tab) -> console.log "onCreated", tab
        # chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) -> console.log "onUpdated", tabId, changeInfo, tab

        # アクティブなウインドウが変わった時に呼び出される
        chrome.windows.onFocusChanged.addListener @_onFocusChangedHandler.bind(@)
        # アクティブなタブが変わった時に呼び出される
        chrome.tabs.onActivated.addListener @_onActivatedHandler.bind(@)

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeIsRunHandler
      #  * @param {Object} Model - BackBone Model Object
      #  */
      # ------------------------------------------------------------
      _changeIsRunHandler: (stageModel, isRun) ->
        console.log "%c[Stage] StageModel -> _changeIsRunHandler", debug.style, isRun

        # stageChangeIsRun イベントを発火させる
        App.vent.trigger "stageChangeIsRun", isRun

        if isRun
          chrome.tabs.getSelected (tab) =>
            @set "activeInfo",
              tabId: tab.id
              windowId: tab.windowId
            # @set "selsectedTabId", tab.id

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
        # App.vent.trigger "stageSelsectedTabId", activeInfo.tabId

      # # ------------------------------------------------------------
      # # /**
      # #  * StageModel#_changeSectedTabIdHandler
      # #  * @param {Object} Model - BackBone Model Object
      # #  */
      # # ------------------------------------------------------------
      # _changeSectedTabIdHandler: (stageModel, selsectedTabId) ->
      #   console.log "%c[Stage] StageModel -> _changeSectedTabIdHandler", debug.style, selsectedTabId
      #   # stageSelsectedTabId イベントを発火させる
      #   App.vent.trigger "stageSelsectedTabId", selsectedTabId


      # ------------------------------------------------------------
      # /**
      #  * StageModel#_onActivatedHandler 
      #  * @param {Object} activeInfo
      #  */
      # ------------------------------------------------------------
      _onActivatedHandler: (activeInfo) ->
        console.log "%c[Stage] StageModel -> _onActivatedHandler", debug.style, activeInfo

        @set "activeInfo": activeInfo
        # @set "selsectedTabId", activeInfo.tabId





    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      @models = 
        stage: new StageModel()

      # ============================================================
      # COMMANDS
      App.commands.setHandler "stageAppRun", () =>
        console.log "%c[Stage] StageModel | stageAppRun", debug.style
        @models.stage.set "isRun", true


      App.commands.setHandler "stopAppRun", (isRun) =>
        console.log "%c[Stage] SocketModel | stopAppRun", debug.style
        @models.stage.set "isRun", false

      # App.execute "stageAppRun"

      # ============================================================
      # REQUEST RESPONSE
      App.reqres.setHandler "stageGetActiveInfo", () =>
        console.log "%c[Stage] Request Response | stageGetActiveInfo", debug.style
        return @models.stage.get "activeInfo"

      # App.reqres.setHandler "stageGetSelsectedTabId", () =>
      #   console.log "%c[Stage] Request Response | stageGetSelsectedTabId", debug.style
      #   return @models.stage.get "selsectedTabId"
      # App.reqres.request

    # ============================================================
    StageModule.addFinalizer (options) ->
      console.log "%c[Stage] addFinalizer", debug.style, options





























