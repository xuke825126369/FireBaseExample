local SlotsGameLua = {}

function SlotsGameLua:InitVariable()
    self.m_enumLevelType = enumThemeType.enumReturnType_None

    self.m_GameResult = {}
    self.m_TestGameResult = {} --仿真专用
    self.m_transform = nil

    self.m_listLineLua = {} ---配了多少根线 1开始
    self.m_listSymbolLua = {} ----有哪些元素 数组 索引从1开始 里面存的元素ID也是从1开始的
    self.SymbolNameIdHashTable = {}

    self.m_listReelLua = {} -----有多少reel 以及信息 索引从0开始。。。
    self.m_nRowCount = 0 --用来计算deck-Key等用途 所以。。在不规则棋盘上 这个值就是最长一列的元素个数
    self.m_nReelCount = 0

    self.m_bSplashFlags = {} ----这是个map。。。以前的SplashCount 这个不是从1开始的，里面元素的key是SplashType值
    self.m_bInSplashShow = false
    self.m_nSplashActive = SplashType.None
    self.m_bInSpin = false -- reel滚动过程中

    self.m_bSplashEnd = true -- 开始滚动置为false 结算结束并且展示结果结束 置为true
    self.m_bCheckWinEnd = true -- 开始滚动置为false 结算结束 展示结果前 置为true

    self.m_bAnimationTime = false   -- preCheckWin期间的动画时间
    self.m_bInResult = false -- checkWinEnd之后的展示结果状态
    self.m_bInSplashShowAllWinLines = false

    self.m_bShowAllWins = false -- 是否在显示全部中奖信息了。。2018-9-5
    self.m_nPreWinOffset = 0 -- payLine payWay 是否该切换线展示了的时候用得到 2018-9-5

    self.m_nWinOffset = 1
    self.m_fWinShowAge = 0.0
    self.m_fWinShowPeriod = 1.9

    self.m_fSpinAge = 0.0
    self.m_nActiveReel = -1 --当前正在等待stop的reel
    self.m_fRotateDistance = 3000.0

    self.m_fCentBoardX = 0.0
    self.m_fCentBoardY = 0.0
    self.m_fAllReelsWidth = 0.0
    self.m_fReelHeight = 0.0
    self.m_fSymbolHeight = 0.0
    self.m_fSymbolWidth = 0.0
    self.m_listDeck = {} --从0开始。。。key为索引

    self.m_bPlayingSlotFireSound = false -- 记录是不是在播放等待scatter中奖的特效
    self.m_goStickySymbolsDir = nil --固定符号的父节点
    self.mPerSpinCancelLeanTweenIDs = {}

    self.m_bShowLineFlag = false -- 2018--05--21 控制线展示的bool值 以前的splashLine就不用了
    self.m_bPayWayLevelFlag = false -- payway 关卡
    self.m_fCoinTime = 0.0 -- spin结束后涨金币时间 即使没中奖也置一个数 让auto下有个间隔再开始下一次
    self.m_bReelPauseFlag = false
    self.m_bAutoSpinFlag = false
    self.m_nAutoSpinNum = 0
end

SlotsGameLua.m_FuncGetDeck = {param = nil, func = nil}
SlotsGameLua.m_FuncPreCheckWin = {param = nil, func = nil}
SlotsGameLua.m_FuncCheckWinEndPost = {param = nil, func = nil}
SlotsGameLua.m_FuncCreateReelRandomSymbolList = {param = nil, func = nil}
SlotsGameLua.m_FuncCheckSpinWinPayLines = {param = nil, func = nil}
SlotsGameLua.m_FuncCheckSpinWinPayWays = {param = nil, func = nil}
SlotsGameLua.m_FuncSimulation = {param = nil, func = nil}
SlotsGameLua.m_FuncOnStartSpin = {param = nil, func = nil}
SlotsGameLua.m_FuncOnSpinEnd = {param = nil, func = nil}
SlotsGameLua.m_FuncAllReelStopAudioHandle = {param = nil, func = nil}

function SlotsGameLua:setGetDeckFunc(param, GetDeckCallback)
    if not self.m_FuncGetDeck then
        self.m_FuncGetDeck = {}
    end

    self.m_FuncGetDeck.param = param
    self.m_FuncGetDeck.func = GetDeckCallback
end

function SlotsGameLua:setPreCheckWinFunc(param, PreCheckWinCallback)
    if not self.m_FuncPreCheckWin then
        self.m_FuncPreCheckWin = {}
    end

    self.m_FuncPreCheckWin.param = param
    self.m_FuncPreCheckWin.func = PreCheckWinCallback
end

function SlotsGameLua:setCheckWinEndPostFunc(param, CheckWinEndPostCallback)
    if not self.m_FuncCheckWinEndPost then
        self.m_FuncCheckWinEndPost = {}
    end

    self.m_FuncCheckWinEndPost.param = param
    self.m_FuncCheckWinEndPost.func = CheckWinEndPostCallback
end

function SlotsGameLua:setCreateReelRandomSymbolListFunc(param, CreateReelRandomSymbolListCallback)
    if not self.m_FuncCreateReelRandomSymbolList then
        self.m_FuncCreateReelRandomSymbolList = {}
    end
    self.m_FuncCreateReelRandomSymbolList.param = param
    self.m_FuncCreateReelRandomSymbolList.func = CreateReelRandomSymbolListCallback
end

function SlotsGameLua:setCheckSpinWinPayLinesFunc(param, CheckSpinWinPayLinesCallback)
    if not self.m_FuncCheckSpinWinPayLines then
        self.m_FuncCheckSpinWinPayLines = {}
    end

    self.m_FuncCheckSpinWinPayLines.param = param
    self.m_FuncCheckSpinWinPayLines.func = CheckSpinWinPayLinesCallback
end

function SlotsGameLua:setCheckSpinWinPayWaysFunc(param, CheckSpinWinPayWaysCallback)
    if not self.m_FuncCheckSpinWinPayWays then
        self.m_FuncCheckSpinWinPayWays = {}
    end

    self.m_FuncCheckSpinWinPayWays.param = param
    self.m_FuncCheckSpinWinPayWays.func = CheckSpinWinPayWaysCallback
end

function SlotsGameLua:setSimulationFunc(param, SimulationCallback)
    if not self.m_FuncSimulation then
        self.m_FuncSimulation = {}
    end

    self.m_FuncSimulation.param = param
    self.m_FuncSimulation.func = SimulationCallback
end

function SlotsGameLua:setOnStartSpinFunc(param, OnStartSpinCallback)
    if not self.m_FuncOnStartSpin then
        self.m_FuncOnStartSpin = {}
    end

    self.m_FuncOnStartSpin.param = param
    self.m_FuncOnStartSpin.func = OnStartSpinCallback
end

function SlotsGameLua:setOnSpinEndFunc(param, OnSpinEndCallback)
    if not self.m_FuncOnSpinEnd then
        self.m_FuncOnSpinEnd = {}
    end

    self.m_FuncOnSpinEnd.param = param
    self.m_FuncOnSpinEnd.func = OnSpinEndCallback
end

function SlotsGameLua:setAllReelStopAudioHandleFunc(param, OnAllReelStopAudioHandleCallback)
    if not self.m_FuncAllReelStopAudioHandle then
        self.m_FuncAllReelStopAudioHandle = {}
    end

    self.m_FuncAllReelStopAudioHandle.param = param
    self.m_FuncAllReelStopAudioHandle.func = OnAllReelStopAudioHandleCallback
end

function SlotsGameLua:OnStartSpin()
    self.m_bSplashEnd = false -- 开始滚动置为false 结算结束并且展示结果结束 置为true
    self.m_bCheckWinEnd = false -- 结算结束 开始展示结果前。。

    self.m_bShowLineFlag = false

    if self.m_FuncOnStartSpin.func ~= nil then
        self.m_FuncOnStartSpin.func(self.m_FuncOnStartSpin.param)
        return
    end

end

function SlotsGameLua:OnSpinEnd()
    SceneSlotGame:OnSpinEnd()

    self.m_bCheckWinEnd = true
    
    if self.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief or
        self.m_enumLevelType == enumThemeType.enumLevelType_FuXing or
        self.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo or
        self.m_enumLevelType == enumThemeType.enumLevelType_Aladdin or
        self.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean or
        self.m_enumLevelType == enumThemeType.enumLevelType_HotPot or
        self.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch or
        self.m_enumLevelType == enumThemeType.enumLevelType_HappyChristmas or
        self.m_enumLevelType == enumThemeType.enumLevelType_DoggyAndDiamond or
        self.m_enumLevelType == enumThemeType.enumLevelType_CrazyDollar or
        self.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover or
        self.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure or
        self.m_enumLevelType == enumThemeType.enumLevelType_FortuneFarm or
        self.m_enumLevelType == enumThemeType.enumLevelType_MoneyPig or
        self.m_enumLevelType == enumThemeType.enumLevelType_IrishBingo or
        self.m_enumLevelType == enumThemeType.enumLevelType_Alice or
        self.m_enumLevelType == enumThemeType.enumLevelType_Pixie or
        self.m_enumLevelType == enumThemeType.enumLevelType_RedHat or
        self.m_enumLevelType == enumThemeType.enumLevelType_Troy or
        self.m_enumLevelType == enumThemeType.enumLevelType_TigerDragon or
        self.m_enumLevelType == enumThemeType.enumLevelType_Animal then
        -- 在自己的关卡里去判断。。
    else
        self.m_bShowLineFlag = true
    end 

    if self.m_FuncOnSpinEnd.func ~= nil then
        self.m_FuncOnSpinEnd.func(self.m_FuncOnSpinEnd.param)
        return
    end

end

function SlotsGameLua:Init()
    self:InitVariable()

    self.m_bReelPauseFlag = false
    self.m_GameResult = GameResult:create()
    self.m_TestGameResult = GameResult:create()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelData")
    self.m_goSlotsGame = self.m_transform.gameObject
    
    local bindObj = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelInfo").gameObject
    LuaAutoBindMonoBehaviour.Bind(bindObj, self)
    
    self:initLevelParam()
end

function SlotsGameLua:initLevelParam()
    ThemePlayData:Init()
    ThemePlayData:SetCFGBasicInfo()
    ThemePlayData:SetCFGReelInfo()
    ThemePlayData:SetCFGSymbolsInfo()
    ThemePlayData:SetCFGLineInfo()

    self:initPositionParam()
    
    self.m_goStickySymbolsDir = self.m_transform:FindDeepChild("StickySymbolsDir").gameObject
    SymbolObjectPool:reset()
    for i = 1, #self.m_listSymbolLua do
        SymbolObjectPool:AddPoolItem(self.m_listSymbolLua[i], 15)
    end
    SymbolObjectPool:CreateStartupPools()
    
    ReturnRateManager:InitGameSetReturnRate()
    ChoiceCommonFunc:InitChoice()
    self:CreateReelRandomSymbolList()
    self:SetRandomSymbolToReel()
    
    self.m_bSplashEnd = true
    for k, v in pairs(SplashType) do
        self.m_bSplashFlags[v] = false
    end
    PayLinePayWaysEffectHandler:LoadLine()
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    self.m_bPayWayLevelFlag = GameLevelUtil:isPayWaysLevel()
    self.m_GameResult:ResetGame(false)
    self:CheckRecoverInfo()

    ReturnRateManager:PrintActualReturnRate()
end 

function SlotsGameLua:reset()
    Unity.GameObject.Destroy(self.m_transform.gameObject)

    self.m_bAutoSpinFlag = false
    self.m_bInSplashShow = false 
    self.m_nSplashActive = SplashType.None
    self.m_bInSplashShowAllWinLines = false

    self.m_nRowCount = 0 --用来计算deck-Key等用途 所以。。在不规则棋盘上 这个值就是最长一列的元素个数
    self.m_nReelCount = 0
    self.m_bSplashFlags = {} ----这是个map。。。以前的SplashCount 这个不是从1开始的，里面元素的key是SplashType值
    self.m_bInSpin = false -- reel滚动过程中
    self.m_bAnimationTime = false   -- preCheckWin期间的动画时间
    self.m_bInResult = false -- checkWinEnd之后的展示结果状态
    self.m_fSpinAge = 0.0

    self.m_stackedChoices = {}
    self.m_randomChoices = {}

    self.m_listLineLua = {} ---配了多少根线 1开始
    self.m_listSymbolLua = {} ----有哪些元素 数组 索引从1开始 里面存的元素ID也是从1开始的
    self.SymbolNameIdHashTable = {}
    self.m_listReelLua = {} -----有多少reel 以及信息 索引从0开始。。。

    PayLinePayWaysEffectHandler:reset()
    self.m_enumLevelType = enumThemeType.enumLevelType_Null

    ------------------  委托方法重置 -----------------------
    self.m_FuncGetDeck = {param = nil, func = nil}
    self.m_FuncPreCheckWin = {param = nil, func = nil}
    self.m_FuncCheckWinEndPost = {param = nil, func = nil}
    self.m_FuncCreateReelRandomSymbolList = {param = nil, func = nil}
    self.m_FuncCheckSpinWinPayLines = {param = nil, func = nil}
    self.m_FuncCheckSpinWinPayWays = {param = nil, func = nil}
    self.m_FuncSimulation = {param = nil, func = nil}
    self.m_FuncOnStartSpin = {param = nil, func = nil}
    self.m_FuncOnSpinEnd = {param = nil, func = nil}
    self.m_FuncAllReelStopAudioHandle = {param = nil, func = nil}
    
end

function SlotsGameLua:RecoverFreeSpin()    
    if self.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
        GiantTreasureLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_ChiliLoco then
        ChiliLocoLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
        SantaManiaLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_SweetBlast then
        SweetBlastLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_DiaDeAmor then
        DiaDeAmorLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_Zues then
        ZuesLevelUI:RecoverFreeSpin()
        return
    elseif self.m_enumLevelType == enumThemeType.enumLevelType_FuXing then
        FuXingLevelUI:RecoverFreeSpin()
        return
    end 

    local nDBFreeSpins = LevelDataHandler:getFreeSpinCount(ThemeLoader.themeKey)
    local nTotalDBFreeSpins = LevelDataHandler:getTotalFreeSpinCount(ThemeLoader.themeKey)

    if nDBFreeSpins > nTotalDBFreeSpins then
        nDBFreeSpins = 0
        nTotalDBFreeSpins = 0

        LevelDataHandler:setFreeSpinCount(ThemeLoader.themeKey, 0)
        LevelDataHandler:setTotalFreeSpinCount(ThemeLoader.themeKey, 0)

        Debug.LogError("----------------------- 游戏数据异常 -----------------------")
    end

    if nDBFreeSpins > 0 then
        self.m_GameResult.m_nNewFreeSpinCount = nDBFreeSpins
        self.m_GameResult.m_nFreeSpinCount = nTotalDBFreeSpins - nDBFreeSpins
        self.m_GameResult.m_nFreeSpinTotalCount = nTotalDBFreeSpins
        self.m_GameResult.m_fFreeSpinTotalWins = LevelDataHandler:getFreeSpinTotalWin(ThemeLoader.themeKey)
        self.m_GameResult.m_fGameWin = self.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:End(self.m_GameResult.m_fFreeSpinTotalWins)  --//更新界面显示。。。
        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin

        SceneSlotGame:ShowFreeSpinUI(true)
        AudioHandler:LoadFreeGameMusic()
    else
        if nTotalDBFreeSpins > 0 then
            SceneSlotGame:collectFreeSpinTotalWins()
        end
    end

    if nDBFreeSpins == 0 then
        AudioHandler:LoadBaseGameMusic()
    end
end

function SlotsGameLua:CheckRecoverInfo()
    SlotsGameLua:RecoverFreeSpin()
    
	local strKey = ThemeLoader.themeKey.."LevelUI"
	if _G[strKey] and _G[strKey].CheckRecoverInfo then
		_G[strKey]:CheckRecoverInfo()
		return
    end
end

function SlotsGameLua:Start()
    Debug.Log("-----SlotsGameLua:Start()-------")
end

function SlotsGameLua:OnEnable()
    Debug.Log("-----SlotsGameLua:OnEnable()-------")
end

function SlotsGameLua:OnDisable()
    Debug.Log("-----SlotsGameLua:OnDisable()-------")
end

function SlotsGameLua:OnDestroy()
    self:reset()
end

function SlotsGameLua:DisplayAllMatchWaysInfo()
    if not self.m_bShowLineFlag then
        return false
    end

    if not self.m_bInSplashShowAllWinLines then
        return false
    end

    local nTotalWins = LuaHelper.tableSize(self.m_GameResult.m_mapWinItemPayWays)
    if nTotalWins == 0 then
        self.m_bInSplashShowAllWinLines = false
        return false
    end

    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        self.m_fWinShowAge = 0.0
        self.m_bInSplashShowAllWinLines = false
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        self.m_bShowAllWins = false
        return
    end

    if self.m_bShowAllWins then
        return true -- 在展示过程中。。
    end

    self.m_bShowAllWins = true
    for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
        local nSymolID = k
        local item = v
        PayLinePayWaysEffectHandler:ShowPayWayEffect(item)
    end

    LevelCommonFunctions:SetWinSymbolWhenShowAndHide(true)
    return true
end

function SlotsGameLua:DisplayMatchWaysInfo()
    if not self.m_bShowLineFlag then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return
    end

    local cnt = LuaHelper.tableSize(self.m_GameResult.m_mapWinItemPayWays)
    if cnt == 0 then
        return
    end

    local nPayWays = #self.m_GameResult.m_listWinItemPayWays
    if nPayWays == 0 then
        for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
            table.insert(self.m_GameResult.m_listWinItemPayWays, self.m_GameResult.m_mapWinItemPayWays[k])
        end
    end

    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        self.m_fWinShowAge = 0.0
        self.m_nWinOffset = self.m_nWinOffset + 1
        if self.m_nWinOffset > #self.m_GameResult.m_listWinItemPayWays then
            self.m_nWinOffset = 1
        end
    end

    if self.m_nPreWinOffset == self.m_nWinOffset then -- spin结束初始化的时候是不等的
        return
    end
    
    self.m_nPreWinOffset = self.m_nWinOffset
    
    local item = self.m_GameResult.m_listWinItemPayWays[self.m_nWinOffset]
    PayLinePayWaysEffectHandler:ShowPayWayEffect(item)
    PayLinePayWaysEffectHandler:InitCurPayWayEffectKeys(item)
    
    PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()
end

function SlotsGameLua:ShowAllMatchLines()
    if not self.m_bShowLineFlag then
        return false
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HotPot then
        return
    end
    
    if not self.m_bInSplashShowAllWinLines then
        return false
    end

    self.m_fWinShowAge = self.m_fWinShowAge + self.m_fDeltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod * 1.35 then
        self.m_fWinShowAge = 0.0
        self.m_bInSplashShowAllWinLines = false
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        --//绕框特效如果这次播放的线和接下来播放的线有相同元素，那么这些相同的不要reuse 否则会有卡顿感觉。

        --//这个不能和hitLineEffect一样 不管相同不相同的都要重置。。要让动画播放时间完全一致。。
        PayLinePayWaysEffectHandler:resetHighLightEffects()

        self.m_bShowAllWins = false
        return true
    --    Debug.Log("-----self.m_fWinShowAge > self.m_fWinShowPeriod * 1.35---- ")
    end

    if self.m_bShowAllWins then
        return true -- 在展示过程中。。
    end
    self.m_bShowAllWins = true

    LevelCommonFunctions:SetWinSymbolWhenShowAndHide(true)

    local nTotalWinLines = #self.m_GameResult.m_listWins -- 有多少根线中奖了
    local bNeedShowLines = false -- todo 有些3X3关卡需要画出中奖线条。。。 todo
    local bShowHighLightEffectFlag = false -- 3x3关卡给中奖元素播高光特效。。。

    local fElemScale = 1.05
    for nWinIndex = 1, nTotalWinLines do
        local wi = self.m_GameResult.m_listWins[nWinIndex]
        local ld = self:GetLine(wi.m_nLineID)

        PayLinePayWaysEffectHandler:ShowWinLine(wi, true)
        if bShowHighLightEffectFlag then
            PayLinePayWaysEffectHandler:ShowHighLightWinLine(wi.m_nLineID, wi.m_nMatches - 1) --一般是3x3关卡用
        else
            PayLinePayWaysEffectHandler:ShowPayLineEffect(wi.m_nLineID, wi.m_nMatches - 1)
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
        FortunesOfGoldFunc:ShowAllMatchLines2()
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
        IrishTwoFunc:ShowExtraAllPayLineEffect()
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch then
        CharmWitchFunc:ShowExtraAllPayLineEffect()
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HappyChristmas then
        HappyChristmasFunc:ShowExtraAllPayLineEffect()
    end

    if self.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
        GiantTreasureFunc:showCollectElem3Effect()
    end

    return true
end

function SlotsGameLua:DisplayMatchLinesInfo()
    if not self.m_bShowLineFlag then
        return
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HotPot then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return
    end

    if self.m_nWinOffset < 0 then -- 类似魔豆关处于展示魔豆中奖这种情况。。
        return -- 2018-9-1
    end

    local nTotalWinLines = #self.m_GameResult.m_listWins
    local nTotalWinLines2 = 0
    if self.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
        nTotalWinLines2 = #FortunesOfGoldFunc.m_listWins2
    end

    if nTotalWinLines + nTotalWinLines2 < 1 then
        if self.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
            self.m_nWinOffset = 0 -- 看看有没有豆子中奖。。
        else
            return
        end
    end

    if self.m_nWinOffset == 0 then --正式正常的线从1开始
        -- 不在中奖线上的元素中奖。。。比如arab关的钻石等。。 GiantTreasure 的3个或3个以上收集元素

        self.m_nPreWinOffset = 0

        -- 只会进来一次

        if self.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then

            if nTotalWinLines + nTotalWinLines2 > 0 then --假如只有魔豆中奖 就不用隐藏了
                PayLinePayWaysEffectHandler:MatchLineHide(false)
            end
            
            self.m_bShowLineFlag = true
            local bres = GiantTreasureFunc:showCollectElem3Effect()

            if not bres then
                self.m_nWinOffset = 1
            else
                self.m_nWinOffset = -1

                local id = LeanTween.delayedCall(self.m_fWinShowPeriod, function()
                    self.m_nWinOffset = 1
                end).id
                
                table.insert(self.mPerSpinCancelLeanTweenIDs, id)
                
                return
            end
        elseif self.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch then
            CharmWitchFunc:ShowExtraPayLineEffect()
        end
    end

    self.m_fWinShowAge = self.m_fWinShowAge + self.m_fDeltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        PayLinePayWaysEffectHandler:resetHighLightEffects()

        self.m_fWinShowAge = 0.0

        self.m_nWinOffset = self.m_nWinOffset + 1
        if self.m_nWinOffset > nTotalWinLines + nTotalWinLines2 then
            self.m_nWinOffset = 1

            if self.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
                self.m_nWinOffset = 0
            elseif self.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch then
                self.m_nWinOffset = 0
            end

        end

    end
    
    if self.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch and self.m_nWinOffset == 0 then
        PayLinePayWaysEffectHandler:InitCurPayLineEffectKeys(0)
        PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()
    end
    
    if self.m_nWinOffset == 0 then -- 0是特殊用途的。。
        return
    end

    if self.m_nPreWinOffset == self.m_nWinOffset then
        return
    end

    self.m_nPreWinOffset = self.m_nWinOffset

    if self.m_nWinOffset <= nTotalWinLines then
        local wi = self.m_GameResult.m_listWins[self.m_nWinOffset] -- 从1开始的。。
        local ld = self:GetLine(wi.m_nLineID)
    
        local bShowHighLightEffectFlag = false

        PayLinePayWaysEffectHandler:ShowWinLine(wi, false)

        if bShowHighLightEffectFlag then
            PayLinePayWaysEffectHandler:ShowHighLightWinLine(wi.m_nLineID, wi.m_nMatches - 1) --一般是3x3关卡用
        else
            PayLinePayWaysEffectHandler:ShowPayLineEffect(wi.m_nLineID, wi.m_nMatches - 1)
            -- 转圈的粒子特效、spine动画、unity动画或者放大缩小...
        end 

        -- 中奖线上的元素播放特效处理。。--- 目的是找出共同的。。下次不用切换线的不要改变这个相同的特效
        PayLinePayWaysEffectHandler:InitCurPayLineEffectKeys(wi.m_nLineID, false, wi)
        PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()
    else
        if self.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
            local nIndex = self.m_nWinOffset - nTotalWinLines
            FortunesOfGoldFunc:ShowMatchLinesEffect(nIndex)
        end
    end
end

function SlotsGameLua:DisplaySplashInfo()
    if not self.m_bInResult or self.m_bInSplashShow or self.m_bAnimationTime then
        return false
    end

    if self.m_nSplashActive == SplashType.None then
        return false
    end

    if self.m_nSplashActive >= SplashType.Max then
        self.m_bInResult = false
        SceneSlotGame:OnSplashEnd()
    else
        if self.m_nSplashActive == SplashType.Line then
            SceneSlotGame:AllReelStopAudioHandle()
        end

        if not self.m_bSplashFlags[self.m_nSplashActive] then
            self.m_nSplashActive = self.m_nSplashActive + 1
        else
            self.m_bInSplashShow = true
            SceneSlotGame:OnSplashShow(self.m_nSplashActive)
        end
    end

    return true
end

function SlotsGameLua:ApplyResult()
    local bFreeSpinFlag = self.m_GameResult:InFreeSpin()
    self.m_listDeck = self:GetDeck()
end

function SlotsGameLua:GetDeck()
    if self.m_FuncGetDeck.func ~= nil then
        local param = self.m_FuncGetDeck.param
        local deck = self.m_FuncGetDeck.func(param)
        return deck
    end

    local deck = self:GetTestDeck()
    return deck
end

function SlotsGameLua:GetTestDeck()
    local deck = {}
    for x = 0, self.m_nReelCount - 1 do
        for y = 0, self.m_nRowCount do
            local nkey = self.m_nRowCount * x + y
            local nSymbolId = self.m_randomChoices:ChoiceSymbolId(x)
            deck[nkey] = nSymbolId
        end
    end

    return deck
end

function SlotsGameLua:ModifyTestDeck(deck)
   if not GameConst.PLATFORM_EDITOR then
        return
   end

   deck[0] = 1
   deck[3] = 1
   deck[6] = 1

   deck[1] = 2
   deck[4] = 2
   deck[7] = 2

end

function SlotsGameLua:Update()
    local dt = Unity.Time.deltaTime
    self.m_fDeltaTime = dt

    if self.m_bShowLineFlag then
        local bPayWaysFlag = self.m_bPayWayLevelFlag
        if bPayWaysFlag then
            self:DisplayAllMatchWaysInfo()
            self:DisplayMatchWaysInfo()
        else
            self:ShowAllMatchLines()
            self:DisplayMatchLinesInfo()
        end
    end

    local bFlag = self:DisplaySplashInfo()
    if bFlag then
        return
    end

    if not self.m_bInSpin then
        return
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy then
        return
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GreatZeus then
        GreatZeusFunc:ReelRunStop()
        return
    elseif  SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
        IrishTwoFunc:ReelRunStop()
        return
    elseif  SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean then
        KingOfOceanFunc:ReelRunStop()
        return
    elseif  SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HotPot then
        HotPotFunc:ReelRunStop()
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover then
        LuckyCloverFunc:ReelRunStop()
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GrannyWolf then
        if SlotsGameLua.m_GameResult:InReSpin() then
            GrannyWolfFunc:ReelRunStopInReSpin()
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SweetBlast then
        if not SlotsGameLua.m_GameResult:InFreeSpin() then
            SweetBlastFunc:UpdateReelRunStop(dt) -- basegame respin 才改写下面的逻辑
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
        AztecAdventureFunc:ReelRunStop()
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ScarabGem then
        if SlotsGameLua.m_GameResult:InFreeSpin() then
            ScarabGemFunc:ReelRunStopInFreeSpin(dt)
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortuneFarm then
        FortuneFarmFunc:ReelRunStop()
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LightningSeven
        or SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FrankensteinRising 
        or SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ThreeKingdoms
        or SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy
        then 
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_StoryOfMedusa then
        if SlotsGameLua.m_GameResult:InReSpin() then
            StoryOfMedusaFunc:ReelRunStopInReSpin(dt)
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DragonFortune then
        if SlotsGameLua.m_GameResult:InReSpin() then
            DragonFortuneFunc:ReelRunStopInReSpin(dt)
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_TigerGrand then
        if SlotsGameLua.m_GameResult:InReSpin() then
            TigerGrandFunc:ReelRunStopInReSpin(dt)
            return
        end
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Spartacus then
        SpartacusFunc:ReelRunStop()
        return
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishBingo then
        IrishBingoFunc:ReelRunStop()
        return
    end
    
    if self.m_nActiveReel == -1 then
        self.m_fSpinAge = self.m_fSpinAge + dt
        if self.m_fSpinAge > 0.5 then -- spin开始后0.5s可以允许停
            self.m_nActiveReel = 0
            self:ApplyResult()
            self.m_listReelLua[self.m_nActiveReel]:Stop()
            
            SceneSlotGame:OnSpinToStop()
            self.m_fSpinAge = 0.0
        end
    else
        local nMaxReelID = self.m_nReelCount - 1

        if self.m_nActiveReel <= nMaxReelID and self.m_listReelLua[self.m_nActiveReel]:Completed() then
            SceneSlotGame:OnReelStop(self.m_nActiveReel)
            self.m_nActiveReel = self.m_nActiveReel + 1
            if self.m_nActiveReel > nMaxReelID then
                self:PreCheckWin()
            else
                self.m_listReelLua[self.m_nActiveReel]:Stop() -- 2020-11-17
            end
        end
    end

end

function SlotsGameLua:PreCheckWin()
    self.m_bInSpin = false
    SceneSlotGame:ButtonEnable(false)
    
    if self.m_FuncPreCheckWin.func ~= nil then
        self.m_FuncPreCheckWin.func(self.m_FuncPreCheckWin.param)
        return
    end

    --走流程。。
    self:CheckWinEnd()
end

function SlotsGameLua:CheckWinEnd()
    local bPayWaysFlag = GameLevelUtil:isPayWaysLevel()
    if bPayWaysFlag then
        self:CheckSpinWinPayWays(self.m_listDeck, self.m_GameResult)
    else
        self:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult)
    end

    self:CheckWinEndPost()
end

function SlotsGameLua:CheckWinEndPost()
    local fCurSpinWins = SceneSlotGame.m_fCurSpinWinCoins
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fSpinWin
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fJackPotBonusWin
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fNonLineBonusWin

    if self.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
        fCurSpinWins = fCurSpinWins + CashRespinsFunc.m_fRespinTotalWin
    end
    SceneSlotGame.m_fCurSpinWinCoins = fCurSpinWins

    local bInFreeSpinFlag = self.m_GameResult:InFreeSpin()
    if bInFreeSpinFlag then
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fCurSpinWins)
    end

    local bInReSpinFlag = self.m_GameResult:InReSpin()
    if fCurSpinWins < 0.0 and not bInReSpinFlag then
        self.m_nWin0Count = self.m_nWin0Count + 1
    else
        self.m_nWin0Count = 0
    end

    self.m_nPreWinOffset = 0
    self.m_bShowAllWins = false -- 在显示全部中奖信息了就置为true

    self.m_nWinOffset = 1
    self.m_fWinShowAge = 0.0
    self.m_bInSplashShowAllWinLines = true

    self:ShowSpinResult()
    self:OnSpinEnd()
    self:ShowCurFreeSpinWinInfo()
end

function SlotsGameLua:ShowCurFreeSpinWinInfo(fSumMoneyCount)
    if not self.m_GameResult:InFreeSpin() then
        return
    end

    local fCurWin = self.m_GameResult.m_fSpinWin + self.m_GameResult.m_fNonLineBonusWin
    if fSumMoneyCount then
        fCurWin = fSumMoneyCount
    end

    if fCurWin > 0.0 then
        local strInfo = MoneyFormatHelper.numWithCommas(fCurWin) -- 只会是整数。。
        strInfo = "+" .. strInfo 
        SceneSlotGame:setTotalWinTipInfo(strInfo, true)
    end
    
end

function SlotsGameLua:CreateReelRandomSymbolList()
    if self.m_FuncCreateReelRandomSymbolList.func ~= nil then
        local param = self.m_FuncCreateReelRandomSymbolList.param
        self.m_FuncCreateReelRandomSymbolList.func(param)
        return
    end
    
    for x = 0, self.m_nReelCount - 1 do
        self.m_listReelLua[x].m_listRandomSymbolID = {}
        for i = 1, 40 do
            local nSymbolId = self.m_randomChoices:ChoiceSymbolId(x)
            self.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

end

function SlotsGameLua:onFinalReport(data)
    
end

function SlotsGameLua:ShowSpinResult()
    local bClassicLevelFlag = GameLevelUtil:isClassicLevel()

    local bRespinFlag = self.m_GameResult:InReSpin()
    if not bClassicLevelFlag and not bRespinFlag then
        for i=1, #self.m_GameResult.m_listWins do
            if self.m_GameResult.m_listWins[i].m_nMatches == self.m_nReelCount and self.m_nReelCount >= 5 then
                if not self.m_GameResult.m_listWins[i].m_bAny3CombFlag then --类似luckyVegas关卡的混合中奖就不弹窗了
                    self.m_bSplashFlags[SplashType.FiveInRow] = true
                    break
                end
            end
        end

        --Ways的情况
        for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
            if v.m_nMatches == self.m_nReelCount and self.m_nReelCount >= 5 then
                self.m_bSplashFlags[SplashType.FiveInRow] = true
                break
            end
        end
    end

    --领取jackpot的情况
    if self.m_GameResult.m_enumJackpotType ~= JackpotTYPE.enumJackpotType_NULL then
        self.m_bSplashFlags[SplashType.BonusGameEnd] = true
    end

    self.m_bSplashFlags[SplashType.Line] = true
    local bInFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local fTotalBets = SceneSlotGame.m_nTotalBet
    local fWins = SlotsGameLua.m_GameResult.m_fSpinWin
    if SlotsGameLua.m_GameResult:InReSpin() then
        if SlotsGameLua.m_GameResult:HasReSpin() then
            fWins = 0
        else
            if bInFreeSpinFlag then
                fWins = SlotsGameLua.m_GameResult.m_fReSpinTotalWins
            else
                fWins = SlotsGameLua.m_GameResult.m_fGameWin
            end
        end
    end
    
    local fWinCoef = fWins / fTotalBets
    local bTriggerBigWin, nBigWinType = self:orTriggerBigWin(fWins, fTotalBets)
    if bTriggerBigWin then
        self.m_bSplashFlags[nBigWinType] = true
    end

    if self.m_GameResult.m_nNewFreeSpinCount > 0 then
        SceneSlotGame.m_bFreeSpinRetrigger = false
        if self.m_GameResult.m_nFreeSpinCount == 0 then
            
        else
            SceneSlotGame.m_bFreeSpinRetrigger = true
        end
        
        LevelDataHandler:addNewFreeSpinCount(ThemeLoader.themeKey, self.m_GameResult.m_nNewFreeSpinCount)
        LevelDataHandler:addTotalFreeSpinCount(ThemeLoader.themeKey, self.m_GameResult.m_nNewFreeSpinCount)

        self.m_bSplashFlags[SplashType.FreeSpin] = true
        Debug.Log("==========FreeSpin Begin==============")
    end

    if self.m_GameResult.m_bRespinResetFlag then
        self.m_GameResult.m_bRespinResetFlag = false
    end

    if self.m_GameResult.m_bReSpinStartFlag then
        self.m_GameResult.m_bReSpinStartFlag = false
    end

    if self.m_GameResult.m_bRespinCompletedFlag then
        self.m_GameResult.m_bRespinCompletedFlag = false

        if self.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
            self.m_bSplashFlags[SplashType.ReSpinEnd] = true
        end
    end

    if self.m_GameResult.m_nFreeSpinTotalCount > 0 and
        self.m_GameResult.m_nFreeSpinCount >= self.m_GameResult.m_nFreeSpinTotalCount and
        not self.m_GameResult:HasReSpin()
    then
        self:FreeSpinEndFunc()
    end

    LevelCommonFunctions:InitCustomWindowInfo()
    if self.m_bSplashFlags[SplashType.FiveInRow] then
        local bShow5OfKindFlag = false
        if SceneSlotGame.m_uiSplash5ofKind ~= nil then
            bShow5OfKindFlag = SceneSlotGame.m_uiSplash5ofKind.m_goUISplash.activeSelf
        end
        if not bShow5OfKindFlag and SceneSlotGame.m_uiSplash6ofKind ~= nil then
            bShow5OfKindFlag = SceneSlotGame.m_uiSplash6ofKind.m_goUISplash.activeSelf
        end
        if bShow5OfKindFlag then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
        end
    end

    for k,v in pairs(SplashType) do
        if self.m_bSplashFlags[v] then -- true 这一项有弹窗再去做检查
            if v == SplashType.BigWin or v == SplashType.MegaWin or v == SplashType.EpicWin  then
                self.m_bSplashFlags[SplashType.FiveInRow] = false
            end
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
        if self.m_GameResult:InReSpin() then
            self:clearBigWinSplashFlag()
        elseif self.m_GameResult:InFreeSpin() then
            if not SceneSlotGame.m_bFreeSpinRetrigger then
                self.m_bSplashFlags[SplashType.FreeSpin] = false
            end
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
        if self.m_GameResult:InReSpin() then
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Smitten then
        if self.m_GameResult:InReSpin() then
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ChiliLoco then
        if self.m_GameResult:InReSpin() then
            self:clearBigWinSplashFlag()
        end
    end
    
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas then
        if self.m_GameResult:InReSpin() then
            self:clearBigWinSplashFlag()
        end
        
        if self.m_bSplashFlags[SplashType.CustomWindow] then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DiaDeAmor then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_VesuvianForture then
        if VesuvianFortureFunc.bInVolcanoFeature1 then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Wolf then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            
            self:clearBigWinSplashFlag()
        end
    end
    
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BierMania then
        if BierManiaLevelUI:orHaveRapidFireCustomSplash() or BierManiaLevelUI:orMiniGameTriggerJackPot() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HappyChristmas then
        if not (SlotsGameLua.m_GameResult:InFreeSpin() or SlotsGameLua.m_GameResult:InReSpin()) then
            if not (self.m_bSplashFlags[SplashType.CustomWindow] or self.m_bSplashFlags[SplashType.Jackpot] or self.m_bSplashFlags[SplashType.BigWin] or self.m_bSplashFlags[SplashType.MegaWin] or self.m_bSplashFlags[SplashType.EpicWin]) then
                SlotsGameLua.m_bAnimationTime = false
            end
        end
    end 

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DoggyAndDiamond then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MaYa then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldenVegas then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end 

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
        if self.m_GameResult:InReSpin() then
            self.m_bSplashFlags[SplashType.FiveInRow] = false
            self:clearBigWinSplashFlag()
        end
    end
    
    if self.m_bSplashFlags[SplashType.Jackpot] then
        self.m_bSplashFlags[SplashType.FiveInRow] = false
        self:clearBigWinSplashFlag()
    end

    local bres1 = self.m_bSplashFlags[SplashType.BigWin] or self.m_bSplashFlags[SplashType.MegaWin] or
                self.m_bSplashFlags[SplashType.EpicWin] or self.m_bSplashFlags[SplashType.FiveInRow] or self.m_bSplashFlags[SplashType.Jackpot]

    local bres2 = self.m_bSplashFlags[SplashType.Bonus] or self.m_bSplashFlags[SplashType.FreeSpin] or
                    self.m_bSplashFlags[SplashType.FreeSpinEnd] or self.m_bSplashFlags[SplashType.BonusGameEnd] or
                    self.m_bSplashFlags[SplashType.ReSpin] or self.m_bSplashFlags[SplashType.CustomWindow]

    bres2 = bres2 or self.m_bSplashFlags[SplashType.ReSpinEnd]

    if bres2 then
        SceneSlotGame.m_bPlayReelStopAudio = false
    else
        SceneSlotGame.m_bPlayReelStopAudio = true
    end
    
    if bres1 or bres2 then
        if SpinButton.m_SpinButton.interactable then
            SpinButton.m_SpinButton.interactable = false
        end
    end

    self.m_bInResult = true
    self.m_nSplashActive = 1
end

function SlotsGameLua:clearBigWinSplashFlag()
    self.m_bSplashFlags[SplashType.BigWin] = false
    self.m_bSplashFlags[SplashType.MegaWin] = false
    self.m_bSplashFlags[SplashType.EpicWin] = false
end

function SlotsGameLua:FreeSpinEndFunc()
    self.m_bSplashFlags[SplashType.FreeSpinEnd] = true
end

function SlotsGameLua:CheckSpinWinPayWays(deck, result)
    if self.m_FuncCheckSpinWinPayWays.func ~= nil then
        return self.m_FuncCheckSpinWinPayWays.func(self.m_FuncCheckSpinWinPayWays.param,deck,result)
    end
    Debug.Assert(false)
end

function SlotsGameLua:CheckSpinWinPayLines(deck, result)
    if self.m_FuncCheckSpinWinPayLines.func ~= nil then
        return self.m_FuncCheckSpinWinPayLines.func(self.m_FuncCheckSpinWinPayLines.param,deck,result)
    end
    Debug.Assert(false)
end

function SlotsGameLua:SetRandomSymbolToReel()
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy then
        return
    end
    
    for i = 0, self.m_nReelCount - 1 do
        local nTotal = self.m_listReelLua[i].m_nReelRow + self.m_listReelLua[i].m_nAddSymbolNums
        for y = 0, nTotal - 1 do
            self.m_listReelLua[i].m_curSymbolIds[y] = 0
        end
        self.m_listReelLua[i]:SetSymbolRandom()
    end
        
    SceneSlotGame:SetScreenSpinZoneRect()
end

function SlotsGameLua:GetSymbol(nSymbolID) --//从1开始
    Debug.Assert(nSymbolID ~= nil, "nSymbolID == nil")
    Debug.Assert(nSymbolID > 0, "nSymbolID <= 0")
    local symbollua = self.m_listSymbolLua[nSymbolID]
    Debug.Assert(symbollua ~= nil, "symbollua == nil: "..nSymbolID)
    return symbollua
end

function SlotsGameLua:GetSymbolIdByObjName(strObjName) --//从1开始
    if not self.SymbolNameIdHashTable[strObjName] then
        for i = 1, #self.m_listSymbolLua do
            if self.m_listSymbolLua[i].prfab.name == strObjName then
                self.SymbolNameIdHashTable[strObjName] = i
                return i
            end
        end
        
        Debug.Assert(false, strObjName)
    end
    return self.SymbolNameIdHashTable[strObjName]
end

function SlotsGameLua:GetSymbolIdxByType(symbolType)
    for i = 1, #self.m_listSymbolLua do
        local type = self.m_listSymbolLua[i].type
        if type == symbolType then
            return i
        end
    end
        
    return -1
end

function SlotsGameLua:CancelPerSpinLeanTween()
	local count = #self.mPerSpinCancelLeanTweenIDs
	for i=1, count do
		local id = self.mPerSpinCancelLeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.mPerSpinCancelLeanTweenIDs = {}
end

function SlotsGameLua:Spin()
    if self.m_bInSpin then
        return SlotsReturnCode.InSpin
    end
    
    self.m_bInResult = false
    self:CancelPerSpinLeanTween()

    local bFreeSpinFlag = self.m_GameResult:HasFreeSpin()
    local bReSpinFlag = self.m_GameResult:HasReSpin()
    local fPlayerCoins = PlayerHandler.nGoldCount
    if not bFreeSpinFlag and not bReSpinFlag then
        if fPlayerCoins < SceneSlotGame.m_nTotalBet then
            return SlotsReturnCode.NoGold
        end
    end
        
    ReturnRateManager:PrintActualReturnRate()
    if bFreeSpinFlag then
        Debug.Assert(SlotsGameLua.m_GameResult.m_fGameWin == SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins, SlotsGameLua.m_GameResult.m_fGameWin.." | "..SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins)
    end

    local bHasStickySymbolLevel = false
    local bLastReSpin  = SlotsGameLua.m_GameResult:InReSpin()
    local bFlag = SlotsGameLua.m_GameResult:Spin()
    if bFlag and bHasStickySymbolLevel then
	    self:resetStickySymbols()
    end

    if not bFreeSpinFlag and not bReSpinFlag then
        local nNowLevel = PlayerHandler.nLevel
        PlayerHandler:AddCoin(-SceneSlotGame.m_nTotalBet)
        local nTotalBetIndex = ThemeHelper:GetTotalBetIndex(FormulaHelper:GetTotalBetList(), SceneSlotGame.m_nTotalBet)
        local nAddExp = FormulaHelper:GetAddLevelExp(nTotalBetIndex)
        PlayerHandler:AddLevelExp(nAddExp)
        LevelDataHandler:AddPlayerUseCoins(SceneSlotGame.m_nTotalBet)

        if nNowLevel ~= PlayerHandler.nLevel then
            GlobalAudioHandler:PlaySound("levelup")
        end
    end
    
    local bIsZero = false
    if not self.m_GameResult:InFreeSpin() and not self.m_GameResult:InReSpin() then
        bIsZero = true
    else
        local bFirstFreeSpinOrResetGameWinTo0 = true
        if self.m_enumLevelType == enumThemeType.enumLevelType_CashRespins or
            self.m_enumLevelType == enumThemeType.enumLevelType_Phoenix or
            self.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold or
            self.m_enumLevelType == enumThemeType.enumLevelType_GoldenEgypt or
            self.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas or
            self.m_enumLevelType == enumThemeType.enumLevelType_SafariKing or
            self.m_enumLevelType == enumThemeType.enumLevelType_Zues or
            self.m_enumLevelType == enumThemeType.enumLevelType_LegendOfCleopatra or
            self.m_enumLevelType == enumThemeType.enumLevelType_TarzanBingo then
            
            bFirstFreeSpinOrResetGameWinTo0 = false
        end
        
        if self.m_GameResult:InFreeSpin() and self.m_GameResult.m_nFreeSpinCount == 0 and bFirstFreeSpinOrResetGameWinTo0 then
           bIsZero = true
        end
    end

    if bIsZero then
        SceneSlotGame.m_SlotsNumberWins:End(self.m_GameResult.m_fGameWin)
    end
    local id = LeanTween.delayedCall(0.5, function()
        if bIsZero then
            self.m_GameResult.m_fGameWin = 0.0
            SceneSlotGame.m_SlotsNumberWins:End(self.m_GameResult.m_fGameWin)
        end

        SceneSlotGame:setTotalWinTipInfo("WIN", false)
    end).id

    table.insert(SceneSlotGame.m_listLeanTweenIDs, id)

    for k, v in pairs(SplashType) do
        self.m_bSplashFlags[v] = false
    end

    PayLinePayWaysEffectHandler:MatchLineHide(true)
    for i = 0, self.m_nReelCount - 1 do
        self.m_listReelLua[i]:Spin()
    end

    self.m_fSpinAge = 0.0
    self.m_nActiveReel = -1
    self.m_bInSpin = true

    local bInFreeSpinFlag = self.m_GameResult:InFreeSpin()
    local bInReSpinFlag = self.m_GameResult:InReSpin()

    self:OnStartSpin()
    return SlotsReturnCode.Success
end

function SlotsGameLua:Spinable()
    if self.m_bInSpin or not self.m_bSplashEnd then
        return false
    end

    if SceneSlotGame.m_bUIState then
        return false
    end

	local bFlag1 = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SnowWhite
	if bFlag1 then
        bFlag1 = SnowWhiteFunc.m_bPlayMultiBonusAniFlag
        
        if bFlag1 then
            return false
        end
	end

    local bHasSplash = SceneSlotGame:hasSplashUI()
    if bHasSplash then
        return false
    end

    return true
end

function SlotsGameLua:getSymbolOffsetY(nReelID) --从0开始
    local nRow = self.m_listReelLua[nReelID + 1]
    local fcoef = (nRow - 1.0) / 2.0
    return fcoef
end

function SlotsGameLua:initPositionParam()
    local strPrePath = "NewGameNode/LevelInfo/LevelBG"
    local strBiaoChiDir = strPrePath .. "/BiaoChi"
    local TopObj = Unity.GameObject.Find(strBiaoChiDir .. "/TOP")
    local BottomObj = Unity.GameObject.Find(strBiaoChiDir .. "/BOTTOM")
    local RightObj = Unity.GameObject.Find(strBiaoChiDir .. "/RIGHT")
    local LeftObj = Unity.GameObject.Find(strBiaoChiDir .. "/LEFT")
    TopObj:SetActive(false)
    BottomObj:SetActive(false)
    RightObj:SetActive(false)
    LeftObj:SetActive(false)

    local posRight = RightObj.transform.position
    local posLeft = LeftObj.transform.position
    local posTop = TopObj.transform.position
    local posBottom = BottomObj.transform.position

    self.m_fBoardPosLeft = posLeft.x
    self.m_fBoardPosRight = posRight.x
    self.m_fBoardPosTop = posTop.y
    self.m_fBoardPosBottom = posBottom.y
    
    self.m_fCentBoardX = (posRight.x + posLeft.x) / 2.0
    self.m_fCentBoardY = (posTop.y + posBottom.y) / 2.0
    self.m_fCentBoardZ = (posTop.z + posBottom.z) / 2.0

    self.m_fAllReelsWidth = posRight.x - posLeft.x
    self.m_fReelHeight = posTop.y - posBottom.y

    self.m_fSymbolHeight = self.m_fReelHeight / self.m_nRowCount
    self.m_fSymbolWidth = self.m_fAllReelsWidth / self.m_nReelCount

    self:RepositionSymbols()
end

function SlotsGameLua:RepositionSymbols()
    local nOutSideCount = 1
    local fReelWidth = self.m_fAllReelsWidth / self.m_nReelCount

    self.m_transform.position = Unity.Vector3(self.m_fCentBoardX, self.m_fCentBoardY, self.m_fCentBoardZ)
    local fMidReelIndex = (self.m_nReelCount - 1) / 2.0
    local fMidRow = (self.m_nRowCount - 1) / 2.0

    for i = 0, self.m_nReelCount - 1 do
        local reelLua = self.m_listReelLua[i]
        local fPosX = (i - fMidReelIndex) * fReelWidth + self.m_fCentBoardX
        reelLua.m_transform.position = Unity.Vector3(fPosX, self.m_fCentBoardY, self.m_fCentBoardZ)

        local nSymbolNum = reelLua.m_nReelRow + reelLua.m_nAddSymbolNums
        for y = 0, nSymbolNum - 1 do
            local fPosY = (y - fMidRow) * self.m_fSymbolHeight
            reelLua.m_listSymbolPos[y] = Unity.Vector3(0, fPosY, 0)
        end

        reelLua.m_nOutSideCount = nOutSideCount
    end

    if self.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
        FortunesOfGoldFunc:initSymbolPosReel2()
    end
        
end

function SlotsGameLua:getReelBGPosByReelID(nReelIndex) --从0开始。。
    local pos = self.m_listReelLua[nReelIndex].m_transform.position
    return Unity.Vector3(pos.x, self.m_fCentBoardY, pos.z)
end

--sticky元素的重置 有弹窗的在respinEnd弹窗时候reset 没弹窗的在SlotsGameLua:Spin()时reset
function SlotsGameLua:resetStickySymbols()
    if self.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
        WildBeastLevelUI:resetStickySymbols()
        return
    end
    if self.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
        CashRespinsLevelUI:resetStickySymbols()
        return
    end

    if self.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
        return -- 以后的关卡都不要在这里调用了，都写到自己的关卡逻辑去
    end

    -- 每关各自写各自的。。
    local nReelCount = self.m_nReelCount
    for i=0, nReelCount-1 do
        local reel = self.m_listReelLua[i]
        local cnt = #reel.m_listStickySymbol
        for j=1, cnt do
            local goSymbol = reel.m_listStickySymbol[j].m_goSymbol
            if goSymbol ~= nil then
                SymbolObjectPool:Unspawn(goSymbol)
            end
        end

        reel.m_listStickySymbol = {}
    end
end

function SlotsGameLua:onSimulationFunc(m_enumSimRateType, m_SimulationCount)
    self.m_enumSimRateType = m_enumSimRateType
    self.m_SimulationCount = m_SimulationCount
    
    Debug.Log("仿真Count: "..self.m_SimulationCount)
    Debug.Log("仿真类型: "..ReturnRateManager:GetReturnRateName(self.m_enumSimRateType))
    
    if self.m_FuncSimulation.func ~= nil then
        self.m_FuncSimulation.func(self.m_FuncSimulation.param)
        return
    end
end

function SlotsGameLua:GetLine(index)---从1开始
    return self.m_listLineLua[index]
end

function SlotsGameLua:delayCallCheckWinEndFun(fDelay)
    self.m_bAnimationTime = true
    local id = LeanTween.delayedCall(fDelay, function()
        self.m_bAnimationTime = false
        self:CheckWinEnd()
    end).id
    table.insert(SceneSlotGame.m_listLeanTweenIDs, id)

end

function SlotsGameLua:orTriggerBigWin(fWins, fTotalBets)
	local fWinCoef = fWins / fTotalBets
	if fWinCoef >= 50.0 then
		return true, SplashType.EpicWin
    elseif fWinCoef >= 20.0 then
		return true, SplashType.MegaWin
    elseif fWinCoef >= 10.0 then
		return true, SplashType.BigWin
	end
    
	return false
end

function SlotsGameLua:GetDeckKey(nReelId, nRowIndex)
    local nCount = 0
    for i = 0, nReelId - 1 do
        nCount = nCount + SlotsGameLua.m_listReelLua[i].m_nReelRow
    end
    
    nCount = nCount + nRowIndex
    return nCount
end

function SlotsGameLua:GetDeckReelIdAndRowIndex(nDeckKey)
    for nReelId = 0, SlotsGameLua.m_nReelCount - 1 do
        local nRowCount = SlotsGameLua.m_listReelLua[nReelId].m_nReelRow
        for nRowIndex = 0, nRowCount - 1 do
            if self:GetDeckKey(nReelId, nRowIndex) == nDeckKey then
                return nReelId, nRowIndex
            end
        end
    end
    
    return -1, -1
end

function SlotsGameLua:GetDeckCount()
    local nCount = 0
    for i = 0, self.m_nReelCount - 1 do
        nCount = nCount + SlotsGameLua.m_listReelLua[i].m_nReelRow
    end
    
    return nCount
end

function SlotsGameLua:onFinalReportForReSpin(fSumMoneyCount)
    local rt = SlotsGameLua.m_GameResult
    local bFreeSpinFlag = rt:InFreeSpin()
    local data = {forBigWin = true, forWinExtra = true, bFreeSpinFlag = bFreeSpinFlag,
                    nTotalBet = SceneSlotGame.m_nTotalBet, fBigWin = fSumMoneyCount, 
                    fExtraWin = fSumMoneyCount}
    
    SlotsGameLua:onFinalReport(data)
end

function SlotsGameLua:onFinalReportForExtraBigWin(fSumMoneyCount)
    local rt = SlotsGameLua.m_GameResult
    local bFreeSpinFlag = rt:InFreeSpin()
    local data = {forBigWin = true, forWinExtra = true, bFreeSpinFlag = bFreeSpinFlag,
                    nTotalBet = SceneSlotGame.m_nTotalBet, fBigWin = fSumMoneyCount, 
                    fExtraWin = fSumMoneyCount}
     
    SlotsGameLua:onFinalReport(data)
end

function SlotsGameLua:onFinalReportForJackpotWin(fSumMoneyCount, nTotalBet)
    -- nTotalBet = SceneSlotGame.m_nTotalBet
end

-- 根据屏幕分辨率 进行插值
function SlotsGameLua:GetResultByScreenRatio(f1x2Value, f3x4Value)
    if f1x2Value == f3x4Value or math.abs(f1x2Value - f3x4Value) < 0.001 then
        return (f1x2Value + f3x4Value) / 2
    end

    local ratio = ScreenHelper:GetScreenWidthHeightRatio(false)
    local fMaxRatio = 3 / 4
    local fMinRatio = 1125 / 2436
    local fResult = -1
    if ratio < fMaxRatio and ratio > fMinRatio then
        fResult = f1x2Value + (ratio - fMinRatio) / (fMaxRatio - fMinRatio) * (f3x4Value - f1x2Value)
    elseif ratio >= fMaxRatio then
        fResult = f3x4Value
    elseif ratio <= fMinRatio then
        fResult = f1x2Value
    end
    
    return fResult
end

function SlotsGameLua:ShowCustomBigWin(nMoneyCount, hideCallBack)
    local bTrigger, nTriggerType = SlotsGameLua:orTriggerBigWin(nMoneyCount, SceneSlotGame.m_nTotalBet)
    if bTrigger then
        local m_uiSplashBigWin = nil
        if nTriggerType == SplashType.BigWin then
            m_uiSplashBigWin = SceneSlotGame.m_uiSplashBigWin
        elseif nTriggerType == SplashType.MegaWin then
            m_uiSplashBigWin = SceneSlotGame.m_uiSplashMegaWin
        elseif nTriggerType == SplashType.EpicWin then
            m_uiSplashBigWin = SceneSlotGame.m_uiSplashEpicWin
        end
        
        m_uiSplashBigWin.m_fLife = AudioHandler:PlayBigWinMusic() + 2.0
        m_uiSplashBigWin:ShowCustomBigWin(nTriggerType, nMoneyCount, hideCallBack)
    else
        if hideCallBack then
            hideCallBack()
        end
    end
end

return SlotsGameLua
