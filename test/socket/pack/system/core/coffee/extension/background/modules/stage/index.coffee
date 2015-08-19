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
        selsectedTabId: null

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
        # ブラウザアクションが発生した時に呼び出される
        # 初回は起動時のtab idが設定される
        @listenTo @, "change:selsectedTabId", @_changeSectedTabIdHandler

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
            @set "selsectedTabId", tab.id

      # ------------------------------------------------------------
      # /**
      #  * StageModel#_changeSectedTabIdHandler
      #  * @param {Object} Model - BackBone Model Object
      #  */
      # ------------------------------------------------------------
      _changeSectedTabIdHandler: (stageModel, selsectedTabId) ->
        console.log "%c[Stage] StageModel -> _changeSectedTabIdHandler", debug.style, selsectedTabId

        # stageSelsectedTabId イベントを発火させる
        App.vent.trigger "stageSelsectedTabId", selsectedTabId


      # ------------------------------------------------------------
      # /**
      #  * StageModel#_onActivatedHandler 
      #  * @param {Object} activeInfo
      #  */
      # ------------------------------------------------------------
      _onActivatedHandler: (activeInfo) ->
        console.log "%c[Stage] StageModel -> _onActivatedHandler", debug.style, activeInfo

        @set "selsectedTabId", activeInfo.tabId





    # ============================================================
    StageModule.addInitializer (options) ->
      console.log "%c[Stage] addInitializer", debug.style, options

      @models = 
        stage: new StageModel()

      # ============================================================
      # COMMANDS
      App.commands.setHandler "stageAppRun", () =>
        console.log "%c[Socket] SocketModel | stageAppRun", debug.style
        @models.stage.set "isRun", true


      App.commands.setHandler "stopAppRun", (isRun) =>
        console.log "%c[Socket] SocketModel | stopAppRun", debug.style
        @models.stage.set "isRun", false

      # App.execute "stageAppRun"


    # ============================================================
    StageModule.addFinalizer (options) ->
      console.log "%c[Stage] addFinalizer", debug.style, options





























