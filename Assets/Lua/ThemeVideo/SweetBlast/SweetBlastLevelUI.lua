require "Lua/ThemeVideo2020/SweetBlast/SweetBlastLevelParam"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastGummyBoardUI"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastBonusGameUI"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastFreeSpinCommon"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastBaseGameSymbolsPool"


SweetBlastLevelUI = {}

SweetBlastLevelUI.m_transform = nil -- LevelBG
SweetBlastLevelUI.m_LeanTweenIDs = {} -- 退出关卡时候要取消的leantween动画
SweetBlastLevelUI.m_mapScatterEffects = {} -- scatter bonus在播放动画的记录进来。。

SweetBlastLevelUI.m_goJackPotValueUI = nil -- JackPotValueUI 切换界面可能需要隐藏
SweetBlastLevelUI.m_goFreeSpinBG = nil -- FreeSpin 棋盘根节点
SweetBlastLevelUI.m_goBtnCanvas = nil -- 记下来 有可能在切换界面时候需要隐藏等..
-- SlotsDataInfo
SweetBlastLevelUI.m_goSlotsDataInfo = nil -- 切换界面的时候...freespin 下隐藏
SweetBlastLevelUI.m_goBaseGameBG = nil -- basegameBG -- freespin下要隐藏掉
--BaseGameBG

SweetBlastLevelUI.m_btnGummyBoard = nil -- 按钮可能有些时候需要控制是否允许点击。。。
SweetBlastLevelUI.m_posTargetGingermanLogo = nil -- 收集gingerman的时候的飞行目标点

SweetBlastLevelUI.m_goCollectTipAni = nil
SweetBlastLevelUI.m_aniCollectTipUI = nil -- 主界面右下角按钮上的tip界面动画

--SweetBlastLevelUI.m_nCollectNum = 0 -- 收集数
SweetBlastLevelUI.m_TextMeshProCollectNum = nil

SweetBlastLevelUI.m_aniBtnGummyBoard = nil -- 按钮上的动画控制器
-- 播放休闲动画、收集到姜饼人时候的动画等等。。。

SweetBlastLevelUI.m_listJackpotBaseCoef = {10, 20, 50, 200} -- 从小到大 Mini..Grand
SweetBlastLevelUI.m_listJackpotMultiCoef = {0.005, 0.006, 0.008, 0.01} -- 累加系数

--SweetBlastLevelUI.m_listJackpotValue = {} -- 4个累加值 写数据库

SweetBlastLevelUI.m_listTextJackpot = {} -- 4个textPro
SweetBlastLevelUI.m_listSlotsNumberJackpot = {}
--跳动的数字

-- 各种弹窗 (通用的除外)
SweetBlastLevelUI.m_goBonusGameBeginUI = nil -- 获得gummy bonus游戏
SweetBlastLevelUI.m_goFreeBeginUI = nil -- 从BonusGame里获得的、或是把一页里的所有礼盒都打开了奖励的
SweetBlastLevelUI.m_TextMeshProFreeSpinNum = nil
SweetBlastLevelUI.m_TextMeshProReelsNum = nil
SweetBlastLevelUI.m_goWILD4XLOGO = nil
SweetBlastLevelUI.m_goWILD3XLOGO = nil
SweetBlastLevelUI.m_listGoWildReel4X = {nil, nil, nil, nil, nil}
SweetBlastLevelUI.m_listGoWildReel3X = {nil, nil, nil, nil, nil}


SweetBlastLevelUI.m_goReSpinBegin = nil -- 6个或6个以上触发..
SweetBlastLevelUI.m_goReSpinAgain = nil -- play it again 。。。
SweetBlastLevelUI.m_goFreespinRespinEnd = nil -- 共用的
SweetBlastLevelUI.m_textMeshProWinCoins = nil -- TextMeshProWinCoins

SweetBlastLevelUI.m_goGrandRespinEnd = nil
SweetBlastLevelUI.m_textGrandRespinWinCoins = nil -- TextMeshProWinCoins
SweetBlastLevelUI.m_listGoJackpotEffect = {} -- jackpot栏的特效

SweetBlastLevelUI.m_goReSpinBG = nil  --Respinbg respin 期间显示的的倒计数牌
SweetBlastLevelUI.m_textMeshProReSpinCount = nil -- 剩余次数
SweetBlastLevelUI.m_aniRespinBG = nil -- animator -- 0默认 1数字变化时候播放 0.5秒

SweetBlastLevelUI.m_goRespinCollectMoneyAni = nil -- respin收集金币过程中棋盘中下方的闪光特效
--

SweetBlastLevelUI.m_mapGingermanEffectTextPro = {} -- 收集飞的特效 go : 上的数量textPro

-- bonus的休闲动画循环。。 animation2
SweetBlastLevelUI.m_LeanTweenIDBonusIdle = {} -- 如果触发了bonusgame要取消的leantween动画

--
SweetBlastLevelUI.m_trSymbolsPoolBaseGame = nil -- 单棋盘下的元素缓存父节点
--
SweetBlastLevelUI.m_bThreeBonusElemTriggerFlag = false
SweetBlastLevelUI.m_bGingermanStoreRespinFlag = false
SweetBlastLevelUI.m_nPreTotalBet = 0 -- 不记数据库了 恢复的时候如果发现是0就恢复成某个中间值吧
-- 触发respin / freespin的时候会修改掉ScenceSlotGame.m_nTotalBet respin freespin结束了要恢复。。

SweetBlastLevelUI.m_bPlayItAgainRespin = false

-- 断线重连从数据库取出的数.. 10-26
SweetBlastLevelUI.m_nRemainReSpinSpinCount = 0
SweetBlastLevelUI.m_bInReSpin = false

-- 把棋盘当成5列的 当前是在哪一列播放着火特效
SweetBlastLevelUI.m_nCurPlayFireEffectFakeReelID = -1 

SweetBlastLevelUI.m_goRespinTransitionEffect = nil
SweetBlastLevelUI.m_goFreespinTransitionEffect = nil
SweetBlastLevelUI.m_SpineEffectRedBear = nil
SweetBlastLevelUI.m_bRespinFromGummyStore = false

function SweetBlastLevelUI:initLevelUI()
    self.m_transform = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
        
    local tr = self.m_transform:FindDeepChild("RespinTransitionEffect")
    self.m_goRespinTransitionEffect = tr.gameObject
    self.m_goRespinTransitionEffect:SetActive(false)
    tr = self.m_transform:FindDeepChild("FreespinTransitionEffect")
    self.m_goFreespinTransitionEffect = tr.gameObject
    self.m_goFreespinTransitionEffect:SetActive(true)
    self.m_SpineEffectRedBear = SpineEffect:create(tr.gameObject)
    self.m_SpineEffectRedBear:Reset()
    self.m_SpineEffectRedBear:PlayAnimation("animation2", 0, false, 1)
    LeanTween.delayedCall(0.2, function()
        self.m_goFreespinTransitionEffect:SetActive(false)
    end)

    local trRespinBG = self.m_transform:FindDeepChild("Respinbg")
    self.m_goReSpinBG = trRespinBG.gameObject
    self.m_textMeshProReSpinCount = trRespinBG:GetComponentInChildren(typeof(Unity.TextMesh))
    self.m_aniRespinBG = trRespinBG:GetComponentInChildren(typeof(Unity.Animator))
    self.m_goReSpinBG:SetActive(false)
    
    local trFreeSpinBG = self.m_transform:FindDeepChild("SantaFreeSpinBG")
    self.m_goFreeSpinBG = trFreeSpinBG.gameObject
    self.m_goFreeSpinBG:SetActive(false)

    local trBaseGameBG = self.m_transform:FindDeepChild("BaseGameBG")
    self.m_goBaseGameBG = trBaseGameBG.gameObject
    self.m_goBaseGameBG:SetActive(true)
    
    --BtnGummyLandCanvas
    local trBtnCanvas = self.m_transform:FindDeepChild("BtnGummyLandCanvas")
    self.m_goBtnCanvas = trBtnCanvas.gameObject
    self.m_goBtnCanvas:SetActive(true)
    
    self.m_goSlotsDataInfo = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("SlotsDataInfo").gameObject
    self.m_goSlotsDataInfo:SetActive(true)
    
    -- 2018-9-1 各个棋盘的group不同。。 curveItem build。。。
    self.m_trSymbolsPoolBaseGame = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("SymbolsPoolBaseGame")
    SweetBlastBaseGameSymbolsPool.m_trSymbolsPool = self.m_trSymbolsPoolBaseGame
    --
    
    --CollectUIAni  --CollectTipAni
    local trCollectTipAni = trBtnCanvas:FindDeepChild("CollectTipAni")
    self.m_aniCollectTipUI = trCollectTipAni:GetComponent(typeof(Unity.Animator))

    self.m_goCollectTipAni = trCollectTipAni.gameObject
    self.m_goCollectTipAni:SetActive(true) -- 自动播放出场动画

    LeanTween.delayedCall(5.0, function()
        self.m_aniCollectTipUI:SetInteger("nPlayMode", 1) -- 退场动画
    end)

    LeanTween.delayedCall(7.0, function()
        self.m_goCollectTipAni:SetActive(false)
    end)

    local trCollectUIAni = trBtnCanvas:FindDeepChild("CollectUIAni")
    
    self.m_btnGummyBoard = trCollectUIAni:GetComponentInChildren(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(self.m_btnGummyBoard)
    self.m_btnGummyBoard.onClick:AddListener(function()
        self:onGummyBoardBtnClick()
    end)
    self.m_TextMeshProCollectNum = trCollectUIAni:GetComponentInChildren(typeof(Unity.TextMesh))

    -- 按钮位置。。飞gingerman特效的终点
    self.m_posTargetGingermanLogo = self.m_TextMeshProCollectNum.gameObject.transform.position

    self.m_aniBtnGummyBoard = trCollectUIAni:GetComponent(typeof(Unity.Animator))
    self.m_aniBtnGummyBoard:SetInteger("nPlayMode", 0)

    local trJackPotValueUI = self.m_transform:FindDeepChild("JackPotValueUI")
    self.m_goJackPotValueUI = trJackPotValueUI.gameObject
    local listNodeNames = {"MiniValue", "MinorValue", "MajorValue", "GrandValue"}
    for i=1, 4 do
        local strName = listNodeNames[i]
        local trNode = trJackPotValueUI:FindDeepChild(strName)
        local textJackpot = trNode:GetComponentInChildren(typeof(Unity.TextMesh))

        self.m_listTextJackpot[i] = textJackpot
        
        local goJackpotEffect = trNode:FindDeepChild("goJackpotEffect").gameObject
        goJackpotEffect:SetActive(false)
        self.m_listGoJackpotEffect[i] = goJackpotEffect
    end
    
    self.m_bRespinFromGummyStore = false
    self.m_goJackPotValueUI:SetActive(true)

    SweetBlastGummyBoardUI:initUI()
    SweetBlastBonusGameUI:initUI()

    self:initFreeSpinRespinUI() -- 界面以及对应的textmeshpro等..
    self:initLevelParam() -- UI上的数据初始化
    self:LoadCollectMoneyAni()

    SweetBlastFreeSpinCommon:init()
end

function SweetBlastLevelUI:OnEnable()
end

function SweetBlastLevelUI:Start()
end

function SweetBlastLevelUI:Update()
    
    -- jackpot 跳动的累加值
    for i=1, 4 do
        self.m_listSlotsNumberJackpot[i]:Update()
    end

end

function SweetBlastLevelUI:OnDisable()
end

function SweetBlastLevelUI:OnDestroy()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.m_LeanTweenIDs = {}

	for i=1, #self.m_LeanTweenIDBonusIdle do
		local id = self.m_LeanTweenIDBonusIdle[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.m_LeanTweenIDBonusIdle = {}

    self.m_mapGingermanEffectTextPro = {}

    Unity.Object.Destroy(self.m_goRespinCollectMoneyAni)

    SweetBlastFunc:destroy() -- 重置一些全局表 各种缓存数据等
end

function SweetBlastLevelUI:FlyGingermanEffect(key, nGingermanNum)
    local nRowCount = SlotsGameLua.m_nRowCount
    local x = math.floor(key / nRowCount)
    local y = key % nRowCount

    -- 确定飞gingerman的特效位置。。。 
    local reel = SlotsGameLua.m_listReelLua[x]
	-- local pos0 = reel.m_transform.localPosition
	-- local pos1 = reel.m_listGoSymbol[y].transform.localPosition
	-- local pos2 = SlotsGameLua.m_transform.localPosition
    local effectPos = reel.m_listGoSymbol[y].transform.position -- pos0 + pos1 + pos2
    
    local strName = "GingermanFlyEffect"
    local effectObj = EffectObj:CreateAndShowByName(effectPos, strName, nil)
    
    local goEffect = effectObj.m_effectGo
    local textNum = self.m_mapGingermanEffectTextPro[goEffect]
    if textNum == nil then
        textNum = goEffect:GetComponentInChildren(typeof(TextMeshPro))
        self.m_mapGingermanEffectTextPro[goEffect] = textNum
    end
    textNum.text = nGingermanNum
    
    local pos = self.m_posTargetGingermanLogo
    local posEnd = Unity.Vector3(pos.x - 150, pos.y + 50, 0)

    -- 先闪一闪播放起飞前的特效 0.667
    LeanTween.delayedCall(0.667, function()
        LeanTween.move(goEffect, posEnd, 0.7):setOnComplete(function()
            effectObj:reuseCacheEffect()
        end)

        -- local fScale = 1.0
        -- LeanTween.scale(goEffect, Unity.Vector3(fScale, fScale, 1.0), 0.6) 
        -- --2018-09-15 边飞边改变大小

    end)
    
end

function SweetBlastLevelUI:initFreeSpinRespinUI()
    local strName = "BonusGameBeginUI"
    self.m_goBonusGameBeginUI = self:loadUI(strName)
    self.m_goBonusGameBeginUI.transform:SetParent(SceneSlotGame.m_trPayTableCanvas, false)
    
    local strName = "FreeSpinsBeginUI"
    self.m_goFreeBeginUI = self:loadUI(strName)
    self.m_goFreeBeginUI.transform:SetParent(SceneSlotGame.m_trPayTableCanvas, false)

    local trFreeSpinNum = self.m_goFreeBeginUI.transform:FindDeepChild("TextMeshProFreeSpinNum")
    self.m_TextMeshProFreeSpinNum = trFreeSpinNum:GetComponent( typeof(UnityUI.Text) )
    local trReelsNum = self.m_goFreeBeginUI.transform:FindDeepChild("TextMeshProReelsNum")
    self.m_TextMeshProReelsNum = trReelsNum:GetComponent( typeof(UnityUI.Text) )

    local tr4XLogo = self.m_goFreeBeginUI.transform:FindDeepChild("WILD4XLOGO")
    local tr3XLogo = self.m_goFreeBeginUI.transform:FindDeepChild("WILD3XLOGO")
    self.m_goWILD4XLOGO = tr4XLogo.gameObject
    self.m_goWILD3XLOGO = tr3XLogo.gameObject
    for i=1, 5 do
        local strName = "WILD" .. tostring(i)
        local goWildReel3X = tr3XLogo:FindDeepChild(strName).gameObject
        local goWildReel4X = tr4XLogo:FindDeepChild(strName).gameObject
        self.m_listGoWildReel3X[i] = goWildReel3X
        self.m_listGoWildReel4X[i] = goWildReel4X
    end
    --ButtonStart
    local trButtonStart = self.m_goFreeBeginUI.transform:FindDeepChild("ButtonStart")
    local btnStart = trButtonStart:GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(btnStart)
    btnStart.onClick:AddListener(function()
        self:onFreeSpinStartBtnClick()
    end)
    
    local strName = "FreeSpinsRespinEndUI"
    self.m_goFreespinRespinEnd = self:loadUI(strName)
    self.m_textMeshProWinCoins = self.m_goFreespinRespinEnd:GetComponentInChildren(typeof(UnityUI.Text))
    
    local btn = self.m_goFreespinRespinEnd:GetComponentInChildren(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        self:onCollectBtnFreeSpinReSpinEnd()
    end)
    
    local strName = "GrandRespinEndUI"
    self.m_goGrandRespinEnd = self:loadUI(strName)
    self.m_textGrandRespinWinCoins = self.m_goGrandRespinEnd:GetComponentInChildren(typeof(UnityUI.Text))
    
    local btn = self.m_goGrandRespinEnd:GetComponentInChildren(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        self:onCollectBtnGrandReSpinEnd() -- 棋盘填满的情况
    end)

    local strName = "RespinBegin"
    self.m_goReSpinBegin = self:loadUI(strName)

    local strName = "RespinAgain"
    self.m_goReSpinAgain = self:loadUI(strName)
    
end

function SweetBlastLevelUI:loadUI(strName) -- 几个弹窗
    local assetPath = strName..".prefab"
    local uiPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    if uiPrefab == nil then
        return nil
    end
	local go = Unity.Object.Instantiate(uiPrefab)
    go.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    go.transform.localScale = Unity.Vector3.one
    go:SetActive(false)

    return go
end

function SweetBlastLevelUI:LoadCollectMoneyAni()
    local assetPath = "CollectMoneyAni.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local tranParent = ThemeVideo2020Scene.mUIBottomCanvas
    
    local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(tranParent, false)
    obj.transform:GetComponent(typeof(Unity.RectTransform)).anchoredPosition = Unity.Vector2 (0, 75);
    obj:SetActive(false)
    
    self.m_goRespinCollectMoneyAni = obj -- 显示隐藏
end

function SweetBlastLevelUI:initLevelParam()
    -- 读关卡数据文件 得到收集数等。。
    SweetBlastLevelParam:initSweetBlastParam()

    self:refreshCollectNumUI()
    
    self:InitJackportParam()
end

function SweetBlastLevelUI:RecoverReSpin()-- 每次进关卡都要调用的。。
    self:getDBReSpin()
    
    SweetBlastDeckUI:init()

    if self.m_bInReSpin then
        if self.m_nRemainReSpinSpinCount <= 0 then
            -- 没有这种情况
        else
            SlotsGameLua.m_GameResult.m_nReSpinCount = 3 - self.m_nRemainReSpinSpinCount
            SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 3
    
            self:RecoverReSpinUI()
        end
    end
end

function SweetBlastLevelUI:RecoverReSpinUI()
    AudioHandler:LoadAndPlayRespinGameMusic()
    self.m_goReSpinBG:SetActive(true)

   CoroutineHelper.waitForEndOfFrame(function()
        SceneSlotGame:ButtonEnable(false)
        SceneSlotGame.m_btnSpin.interactable = false
    end)

    if self.m_bGingermanStoreRespinFlag then
        SceneSlotGame.m_textTotalBet.text = "AVERAGE"
        
        self:modifyJackpotValueByTotalBet()
    end

    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    for reelID=0, 19 do
        local reel = SlotsGameLua.m_listReelLua[reelID]
        local preSymbolID = reel.m_curSymbolIds[0]
        if preSymbolID == nBonusID then
            local preGo = reel.m_listGoSymbol[0]
            SymbolObjectPool:Unspawn(preGo)
        
            local nSymbolID = math.random(1, 8)
            local symbolNew = SlotsGameLua:GetSymbol(nSymbolID)
            local goNew = SymbolObjectPool:Spawn(symbolNew.prfab)

            SweetBlastFunc:SymbolRectGroupHandler(goNew, reelID)

            goNew.transform:SetParent(reel.m_transform, false)
            goNew.transform.localScale = Unity.Vector3.one
            goNew.transform.localPosition = reel.m_listSymbolPos[0]

            reel.m_listGoSymbol[0] = goNew
            reel.m_curSymbolIds[0] = nSymbolID

        end
    end

    self:RecoverStickyCollectElem()
end

function SweetBlastLevelUI:RecoverStickyCollectElem()
    local listNewCollectElems = {}

    local listNewCollectElems = {}
    for k, v in pairs(SweetBlastFunc.m_mapCollectElemValue) do
        table.insert(listNewCollectElems, k)
    end

    SweetBlastFunc:stickyCollectElems(listNewCollectElems)
end

function SweetBlastLevelUI:RecoverFreeSpin() -- 每次进关卡都要调用的。。
    local nDBFreeSpins = LevelDataHandler:getFreeSpinCount(ThemeLoader.themeKey)
    local nTotalDBFreeSpins = LevelDataHandler:getTotalFreeSpinCount(ThemeLoader.themeKey)
    if nDBFreeSpins > 0 then

        Debug.Assert(nTotalDBFreeSpins > 0, "-----error!!----")

        SlotsGameLua.m_GameResult.m_nNewFreeSpinCount = nDBFreeSpins
        SlotsGameLua.m_GameResult.m_nFreeSpinCount = nTotalDBFreeSpins - nDBFreeSpins
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = nTotalDBFreeSpins
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = LevelDataHandler:getFreeSpinTotalWin(ThemeLoader.themeKey)
        
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:End(SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins)  --//更新界面显示。。。
        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
        
        SweetBlastFreeSpinCommon.m_nFreeSpinNum = nTotalDBFreeSpins
        self:FreeSpinFunc()
    else
        if nTotalDBFreeSpins>0 then
            --//freeSpin结束但是还没有弹出界面或者弹出界面了但是没有点collect就杀进程了，再次进入的时候就是这种情况处理
            SceneSlotGame:collectFreeSpinTotalWins(3.5)
            
            local param = {}
            param.m_nFreeSpinType = 0 -- 0类型 无意义。。
            param.m_listWildReelID = {}
            param.m_fFreeSpinBet = 0
            self:setFreeSpinParam(param)
        end

    end

    if nDBFreeSpins==0 then
        AudioHandler:LoadBaseGameMusic()
    end

    -- 没有需要恢复的freespin ...
end

function SweetBlastLevelUI:RecoverBonusGame()
    local bBonusGameFlag = LevelDataHandler:getBonusGameFlag(ThemeLoader.themeKey)
    if bBonusGameFlag then
        SweetBlastBonusGameUI:Show()
    end
end

 -- 从商店里兑换出来的respin专用
function SweetBlastLevelUI:initGummyStoreRespinDeck()
    -- 1. 停掉中奖线
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    -- 2. respin初始化盘面..
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    for reelID=0, 19 do
        local reel = SlotsGameLua.m_listReelLua[reelID]
        local preSymbolID = reel.m_curSymbolIds[0]
        if preSymbolID == nBonusID or preSymbolID == nCollectID then
            local preGo = reel.m_listGoSymbol[0]
            SymbolObjectPool:Unspawn(preGo)
        
            local nSymbolID = math.random(1, 8)
            local symbolNew = SlotsGameLua:GetSymbol(nSymbolID)
            local goNew = SymbolObjectPool:Spawn(symbolNew.prfab)

            SweetBlastFunc:SymbolRectGroupHandler(goNew, reelID)

            goNew.transform:SetParent(reel.m_transform, false)
            goNew.transform.localScale = Unity.Vector3.one
            goNew.transform.localPosition = reel.m_listSymbolPos[0]

            reel.m_listGoSymbol[0] = goNew
            reel.m_curSymbolIds[0] = nSymbolID
            SlotsGameLua.m_listDeck[reelID] = nSymbolID

        end
    end

end

-- 领取奖励、重置参数、设置UI等
function SweetBlastLevelUI:BonusGameEnd()
    -- 领取奖励... 弹窗 获得freespin的。。
    local param = SweetBlastLevelParam.m_BonusGameInfo
    local listWildReelID = param.m_listWildReelKey
    local nFreeSpinNum = param.m_nFreeSpinNum

    local nReelsNum = param.m_nSlotsGameNum
    local nRow = param.m_WildReelRows
    local nFreeSpinType = self:getFreeSpinTypeByParam(nReelsNum, nRow)

    -- 这里会奖励写数据库 并且打开freespinBegin界面
    local fFreeSpinBet = param.m_nTotalBet
    -- 这个值分两种情况 可能是收集gingerman的平均压注值(开箱子触发) 也可能是当前压注(3Bonus触发...)
    self:TriggerSweetBlastFreeSpin(nFreeSpinType, nFreeSpinNum, listWildReelID, fFreeSpinBet)

    local nCoins = param.m_nBonusGameCoins
    PlayerHandler:AddCoin(nCoins)  -- bonusgame地图上获得的金币
    LevelDataHandler:AddPlayerWinCoins(nCoins)
    UITop:updateCoinCountInUi(6.0)

    -- 更新界面参数
    self:refreshCollectNumUI()
    
    -- 标记着已经触发了bonusgame 等bonus结束了再设为false 断线重连需要...
    LevelDataHandler:setBonusGameFlag(ThemeLoader.themeKey, false)
    SweetBlastLevelParam:setBonusGameInfoEmpty() -- 参数清空
end

function SweetBlastLevelUI:getFreeSpinTypeByParam(nReelsNum, nRow)
    local nFreeSpinType = 0

    if nRow == 3 then
        if nReelsNum == 2 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin3X5_2

        elseif nReelsNum == 3 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin3X5_3

        elseif nReelsNum == 4 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin3X5_4

        else
            Debug.Log("----error!!--------------")
        end
    elseif nRow == 4 then
        if nReelsNum == 2 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_2

        elseif nReelsNum == 3 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3

        elseif nReelsNum == 4 then
            nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_4

        else
            Debug.Log("----error!!--------------")
        end
    else
        -- 
        Debug.Log("-------------error!!-----------")
    end

    if nFreeSpinType == 0 then
        Debug.Log("----error!!!---nReelsNum, nRow: " .. nReelsNum .. ", " .. nRow)
    end
    
    return nFreeSpinType
end

function SweetBlastLevelUI:refreshCollectNumUI()
    local num = 0
    if SweetBlastLevelParam.m_CollectInfo.m_nCollectNum ~= nil then
        num = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum
    end
    local strNum = MoneyFormatHelper.numWithCommas(num)
    self.m_TextMeshProCollectNum.text = strNum
end

--Init jackport params
function SweetBlastLevelUI:InitJackportParam()
    for i = 1, 4 do
        self.m_listSlotsNumberJackpot[i] = SlotsNumber:create()
        self.m_listSlotsNumberJackpot[i]:AddUIText(self.m_listTextJackpot[i])
    end

    self:modifyJackpotValueByTotalBet()
end

function SweetBlastLevelUI:modifyJackpotValueByTotalBet()
    local nTotalbet = SceneSlotGame.m_nTotalBet
    for i = 1, 4 do
        local fBase = nTotalbet * self.m_listJackpotBaseCoef[i]
        local fValue = SweetBlastLevelParam.m_listJackpotValue[i]
        local fTotal = fBase + fValue
        local strTemp = MoneyFormatHelper.numWithCommas(fTotal)
        self.m_listTextJackpot.text = strTemp
        self.m_listSlotsNumberJackpot[i]:End(fTotal)
    end
end

function SweetBlastLevelUI:addJackPotValue(bSimulationFlag)
    local rt = SlotsGameLua.m_GameResult
    if bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    if rt:InFreeSpin() or rt:InReSpin() then
        return
    end

    local nTotalBet = SceneSlotGame.m_nTotalBet

    for i=1, 4 do
        local fValue = nTotalBet * self.m_listJackpotMultiCoef[i]
        local fTemp = SweetBlastLevelParam.m_listJackpotValue[i]
        local fTotal = fTemp + fValue
        SweetBlastLevelParam.m_listJackpotValue[i] = fTotal

        if not bSimulationFlag then
            self.m_listSlotsNumberJackpot[i]:ChangeDelta(fValue)
        end
    end

    if not bSimulationFlag then
        SweetBlastLevelParam:saveParam()
    end
    
end

function SweetBlastLevelUI:resetJackpotValue()
    if SweetBlastFunc.m_bResetMiniJackpot then
        SweetBlastFunc.m_bResetMiniJackpot = false
        SweetBlastLevelParam.m_listJackpotValue[1] = 0
    end

    if SweetBlastFunc.m_bResetMinorJackpot then
        SweetBlastFunc.m_bResetMinorJackpot = false
        SweetBlastLevelParam.m_listJackpotValue[2] = 0
    end

    if SweetBlastFunc.m_bResetMajorJackpot then
        SweetBlastFunc.m_bResetMajorJackpot = false
        SweetBlastLevelParam.m_listJackpotValue[3] = 0
    end 

    if SweetBlastFunc.m_bResetGrandJackpot then
        SweetBlastFunc.m_bResetGrandJackpot = false
        SweetBlastLevelParam.m_listJackpotValue[4] = 0
    end
    
    SweetBlastLevelParam:saveParam()
    self:modifyJackpotValueByTotalBet()
end

function SweetBlastLevelUI:onGummyBoardBtnClick()
    AudioHandler:PlayBtnSound()

    -- 2018--9--28
    if SlotsGameLua.m_bAutoSpinFlag then
        SlotsGameLua.m_bAutoSpinFlag = false
        
		SceneSlotGame:OnSpinEndButtonChangeState()
        SceneSlotGame:ButtonEnable(false)
        SceneSlotGame.m_btnSpin.interactable = false
    end
    
    SweetBlastGummyBoardUI:Show()

    -- local nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_4
    -- local nFreeSpinNum = 5
    -- local listWildReelID = {1, 3, 4}
    -- self:TriggerSweetBlastFreeSpin(nFreeSpinType, nFreeSpinNum, listWildReelID)
    
end

function SweetBlastLevelUI:OnSpinEnd()
    -- 这里不是滚动结束  而是结算结束了
    
end

function SweetBlastLevelUI:checkCollectElemLandedEffect(nReelID)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
    local RowCount = SlotsGameLua.m_nRowCount
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    local listNewCollectRowIndex = {} -- y

    for y=0, RowCount-1 do
        local key = RowCount * nReelID + y
        local nSymbolID = SlotsGameLua.m_listDeck[key]
        if nSymbolID == nCollectID then
            local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
            if not bStickyFlag then
                table.insert(listNewCollectRowIndex, y)
            end
        end
    end

    local cnt = #listNewCollectRowIndex
    if cnt == 0 then
        return
    end

    AudioHandler:PlayBonusLanded()
    
    for i=1, cnt do
        local y = listNewCollectRowIndex[i]
        local go = reel.m_listGoSymbol[y]

        local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]
        if clipEffect ~= nil then
            clipEffect:playAniByPlayMode(1) -- 1落地  2结算
        end

    end
end

--列停止的时候播放scatter特效 -- 包括让列转的更久等也在这里做了
function SweetBlastLevelUI:OnPreReelStop(nReelID)
    self:checkCollectElemLandedEffect(nReelID) -- 收集元素出场特效。。

    local reel = SlotsGameLua.m_listReelLua[nReelID]
    
	if not SpinButton.m_bUserStopSpin or nReelID == SlotsGameLua.m_nReelCount-1 then
        AudioHandler:PlayReelStopSound(0) -- 列停止的音
    end
    
    -- bonus 音效 视效等。。
    local nMaxReelID = 19 -- 会出 bonus 的最大列
    if nReelID == nMaxReelID then
        if SlotsGameLua.m_bPlayingSlotFireSound then
            SlotsGameLua.m_bPlayingSlotFireSound = false
            AudioHandler:StopSlotsOnFire()
        end
    end

    if nReelID % 4 == 3 then
        local nFireReelID = math.floor( nReelID/4 ) * 4
        if SlotsGameLua.m_listReelLua[nFireReelID].m_ScatterEffectObj ~= nil then
            SlotsGameLua.m_listReelLua[nFireReelID].m_ScatterEffectObj:reuseCacheEffect()
            SlotsGameLua.m_listReelLua[nFireReelID].m_ScatterEffectObj = nil
        end
    end

    if SpinButton.m_bUserStopSpin then -- 玩家点stop的情况
        if SlotsGameLua.m_bPlayingSlotFireSound then
            SlotsGameLua.m_bPlayingSlotFireSound = false
            AudioHandler:StopSlotsOnFire()
        end
    end

    ---------- 检查 scatter
    local nReelCount = SlotsGameLua.m_nReelCount
	local RowCount = SlotsGameLua.m_nRowCount
    local nBonusNum = 0 -- 统计到目前为止出了几个scatter了
    
    local nCurScatterKey = -1 -- 记录当前这一列的scatter的key
    
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")

	for x=0, nReelID do
		for y=0, RowCount-1 do
			local nSymbolID = SlotsGameLua.m_listReelLua[x].m_curSymbolIds[y]
			
			if nSymbolID == nBonusID then
				local bStickyFlag, nStickyIndex = SlotsGameLua.m_listReelLua[x]:isStickyPos(y)
				if not bStickyFlag then
                    nBonusNum = nBonusNum + 1

                    if x == nReelID then
                        nCurScatterKey = RowCount * x + y
                    end

				end
			end
		end
    end
    
    local bPossibleUseful = self:isBonusPossibleUseful(nBonusNum, nReelID)

    if (not bPossibleUseful) and nCurScatterKey >= 0 then
        self:ShowScatterBonusIdleEffect(nCurScatterKey)
    end

    if bPossibleUseful and nCurScatterKey >= 0 then
        self:ShowScatterBonusLandedEffect(nCurScatterKey)
        local nFakeReelID = math.floor( nReelID/4 )
        AudioHandler:PlayScatterStopSound(nFakeReelID)
    end

    local nFakeReelID = math.floor( nReelID/4 )
    if bPossibleUseful and not SpinButton.m_bUserStopSpin then
        -- 要可能有用了，才有希望触发freespin
        if nCurScatterKey >= 0 or nReelID%4 == 3 then
            if self.m_nCurPlayFireEffectFakeReelID ~= nFakeReelID then
                self.m_nCurPlayFireEffectFakeReelID = nFakeReelID
    
                local bNeedWaitingFreeSpin = self:isNeedWaitingFreeSpin(nBonusNum, nReelID)
                if bNeedWaitingFreeSpin then
                    self:PlayEffectWaitingFreeSpin(nReelID)
                    Debug.Log("----PlayEffectWaitingFreeSpin----nReelID: " .. nReelID)
                end
    
            end
        end

    end

    if not bPossibleUseful or SpinButton.m_bUserStopSpin then
        if SlotsGameLua.m_bPlayingSlotFireSound then
            SlotsGameLua.m_bPlayingSlotFireSound = false
            AudioHandler:StopSlotsOnFire()
        end
    end

    local nNextReelID = self:getNextStopReelID(nReelID)
    -- Debug.Log("----nReelID: " .. nReelID .. " ----nNextReelID: " .. nNextReelID)
    if nNextReelID ~= -1 then -- -1是结束标记
        SlotsGameLua.m_listReelLua[nNextReelID]:Stop()
    end
end

function SweetBlastLevelUI:getNextStopReelID(nReelID)
    local nMaxReelID = SlotsGameLua.m_nReelCount-1
    if nReelID >= nMaxReelID then
        return -1
    end

    local nNextReelID = nReelID + 1

    while true do
        if nNextReelID > nMaxReelID then
            return -1
        end
        if SweetBlastFunc:isStopReel(nNextReelID) then
            nNextReelID = nNextReelID + 1
        else
            return nNextReelID
        end
    end
    
end

-- 单格滚动的.. 着火特效 放在 0 4 8 12 16 列上
-- 2020-11-17 -- 
function SweetBlastLevelUI:PlayEffectWaitingFreeSpin(nReelID)
    if math.floor(nReelID/4) >= 4 then
        return 
    end

    local nNextReelID = math.floor(nReelID/4) * 4 + 4
    
    local effectPos = SlotsGameLua:getReelBGPosByReelID(nNextReelID)

    local index = math.floor(nNextReelID/4) - 2
    local posx = SlotsGameLua.m_fCentBoardX + index * SlotsGameLua.m_fAllReelsWidth/5
    local posy = 40 -- ReelBG 下的 reel0 1 2 3 4 的位置

    local effectPos = Unity.Vector3(posx, posy, 0)

    local effectType = enumEffectType.Effect_ScatterEffect
    SlotsGameLua.m_listReelLua[nNextReelID].m_ScatterEffectObj = EffectObj:Show(effectPos, effectType)

    local fDisCoef = 2.7
    SlotsGameLua.m_listReelLua[nNextReelID].m_fRotateDistance = SlotsGameLua.m_fRotateDistance * fDisCoef

    Debug.Log("-------nNextReelID: " .. nNextReelID)

    if not SlotsGameLua.m_bPlayingSlotFireSound then
        SlotsGameLua.m_bPlayingSlotFireSound = true
        AudioHandler:PlaySlotsOnFire()
    end
end

function SweetBlastLevelUI:ShowScatterBonusLandedEffect(key)
    local nRow = SlotsGameLua.m_nRowCount -- 1
    local nReelId = math.floor( key/nRow )
    local nRowIndex = math.floor( key%nRow ) -- 0

    local listGo = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol
    local obj = listGo[nRowIndex]

    local bonusSpineEffect = SymbolObjectPool.m_mapSpinEffect[obj]
    if bonusSpineEffect ~= nil then
        SweetBlastFunc:SetSymbolRectGroup(obj, nil)

        bonusSpineEffect:PlayAnimation("animation1", 0, false, 1)
        local id = LeanTween.delayedCall(1.5, function()
            bonusSpineEffect:PlayAnimation("animation2", 0, true, 1)
        end).id
        -- id记着 如果中奖了要播放animation动画就要取消掉这个动作
        table.insert( self.m_LeanTweenIDBonusIdle, id )
    end
end

function SweetBlastLevelUI:ShowScatterBonusIdleEffect(key)
    local nRow = SlotsGameLua.m_nRowCount -- 1
    local nReelId = math.floor( key/nRow )
    local nRowIndex = math.floor( key%nRow )

    local listGo = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol
    local obj = listGo[nRowIndex]

    local bonusSpineEffect = SymbolObjectPool.m_mapSpinEffect[obj]
    if bonusSpineEffect ~= nil then
        bonusSpineEffect:PlayAnimation("animation2", 0, true, 1)
    end
    
end

-- 比如 nReelID 为 12 这个格子12刚好出了个scatter ... nScatterNum = 1
-- 这个scatter应该是没有用的
function SweetBlastLevelUI:isBonusPossibleUseful(nScatterNum, nReelID)
    local nMaxBonusNum = nScatterNum + 5 - math.floor(nReelID/4) -1
    -- nReelID列停止的时候 后续最多盘面可能的bonus数
    if nMaxBonusNum > 2 then
        return true
    end
    
    return false
end

function SweetBlastLevelUI:isNeedWaitingFreeSpin(nScatterNum, nReelID)
    local nMaxBonusNum = nScatterNum + 5 - math.floor(nReelID/4) -1
    -- nReelID列停止的时候 后续最多盘面可能的bonus数
    if nMaxBonusNum > 2 and nScatterNum == 2 then
        return true
    end
    
    return false
end

function SweetBlastLevelUI:ShowScatterBonusEffect()
	for i=1, #self.m_LeanTweenIDBonusIdle do
		local id = self.m_LeanTweenIDBonusIdle[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.m_LeanTweenIDBonusIdle = {}

    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    for x=0, SlotsGameLua.m_nReelCount-1 do
        local reel = SlotsGameLua.m_listReelLua[x]

        local nCurReelRowNum = reel.m_nReelRow

        for y=0, nCurReelRowNum-1 do
            local nkey = SlotsGameLua.m_nRowCount * x + y
            local nID = SlotsGameLua.m_listDeck[nkey]
            if nID == nBonusID then
                
                local bHasSpineEffectFlag = self.m_mapScatterEffects[nkey] ~= nil -- 是否已经在播放对应动画了
                if not bHasSpineEffectFlag then
                    local listGo = reel.m_listGoSymbol
                    local obj = listGo[y]

                    local bonusSpineEffect = SymbolObjectPool.m_mapSpinEffect[obj]
                    if bonusSpineEffect ~= nil then
                        SweetBlastFunc:SetSymbolRectGroup(obj, nil)
                        bonusSpineEffect:PlayAnimation("animation", 0, true, 1)
                        
                        self.m_mapScatterEffects[nkey] = bonusSpineEffect
                    end
                    
				end
			end
		end
	end

end

function SweetBlastLevelUI:HideScatterBonusEffect()
    for k, v in pairs(self.m_mapScatterEffects) do
        -- local clipEffect = self.m_mapScatterEffects[k]
        -- clipEffect:resetPlayModeDefault()

        local spineEffect = self.m_mapScatterEffects[k]
        spineEffect:StopActiveAnimation()
    end

    self.m_mapScatterEffects = {}
end

function SweetBlastLevelUI:updateRespinCountInfo(nRespinCount, bAniFlag)
    -- if not self.m_goReSpinBG.activeSelf then
    --     self.m_goReSpinBG:SetActive(true)
    -- end

    if bAniFlag == nil then -- 默认情况不传参数 需要正常做动画
        bAniFlag = true
    end

    -- 播放某个动画。。然后重置参数。。
     local ftime = 0.5
    if nRespinCount == 3 then
        self.m_aniRespinBG:SetInteger("nPlayMode", 1)
        -- ftime = 0.1
    -- else
    --     self.m_aniRespinBG:SetInteger("nPlayMode", 1)
    end

    LeanTween.delayedCall(ftime, function()
        self.m_textMeshProReSpinCount.text = tostring(nRespinCount)
        self.m_aniRespinBG:SetInteger("nPlayMode", 0)
    end)

end

function SweetBlastLevelUI:initGingermanStoreRespinInfo()
    self.m_bGingermanStoreRespinFlag = true
    self.m_nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = SweetBlastLevelParam.m_CollectInfo.m_fAvgTotalBet

    self:modifyJackpotValueByTotalBet()

    self.m_bInReSpin = true
    self:setDBReSpin()
end

function SweetBlastLevelUI:handleReSpinBegin()
    Debug.Log("-----111-----handleReSpinBegin--------")

    SceneSlotGame.m_bUIState = true
    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false

    if self.m_bGingermanStoreRespinFlag then
        SceneSlotGame.m_textTotalBet.text = "AVERAGE"

    end

    -- 2018-9-11
    -- 先留两秒盘面元素播放对应特效? todo

    -- 把盘面上方缓存的几个元素里有GingermanLogo的弃掉啊 省得掉下来不好看。。
    for i=0, 4 do
        local reel = SlotsGameLua.m_listReelLua[i]
        for j=4, 7 do
            local go = reel.m_listGoSymbol[j]
            if go == nil then
                break
            end
            
            local goGingerman = SweetBlastFunc.m_mapGoGingermanLogo[go]
            if goGingerman ~= nil then
                goGingerman:SetActive(false)
            end
        end
    end
    --

    if self.m_bPlayItAgainRespin then
        self.m_goReSpinBG:SetActive(true)
        LeanTween.delayedCall(1.5, function()
            AudioHandler:LoadAndPlayRespinGameMusic()
            SceneSlotGame.m_bUIState = false
            SceneSlotGame:OnSplashHide(SplashType.ReSpin) -- 让消息循环能继续往后检查..
        end)
    else
        -- 到这里盘面元素早已经固定了。。 --以前没有转场特效的时候..
        local ftime = 1.0
        -- 这里盘面元素还没有固定。。2020-12-14
        ftime = 1.0
        if self.m_bRespinFromGummyStore then
            ftime = 0.0
        end

        LeanTween.delayedCall(ftime, function()
            AudioHandler:PlayFreeGamePopupSound()
            self.m_goReSpinBegin:SetActive(true) -- 这个动画时长3.5秒
        end)

        LeanTween.delayedCall(3.5 + ftime, function()
            -- bangbangtangguochang 

            AudioHandler:PlayThemeSound("transitionRespin")
            self.m_goRespinTransitionEffect:SetActive(true)
        end)

        LeanTween.delayedCall(5.0 + ftime, function()
            self.m_goReSpinBG:SetActive(true)
            self.m_goReSpinBegin:SetActive(false)

            if self.m_bRespinFromGummyStore then
                self:initGummyStoreRespinDeck()
                self.m_bRespinFromGummyStore = false
            end

        end)

        LeanTween.delayedCall(7.0 + ftime, function()
            local ftime1 = SweetBlastFunc:AddAdjacentElemsHandler()
            LeanTween.delayedCall(ftime1, function()
                SweetBlastFunc:checkRespinResult()
            end)
        end)

        LeanTween.delayedCall(10 + ftime, function()
            AudioHandler:LoadAndPlayRespinGameMusic()
            SceneSlotGame.m_bUIState = false
            self.m_goRespinTransitionEffect:SetActive(false)
            SceneSlotGame:OnSplashHide(SplashType.ReSpin) -- 让消息循环能继续往后检查..
        end)
    end

end

function SweetBlastLevelUI:playItAgainRespin()
   -- self.m_goReSpinBG:SetActive(true)
    AudioHandler:PlayFreeGamePopupSound()
    self.m_goReSpinAgain:SetActive(true) -- againUI
    self.m_btnGummyBoard.interactable = false

    --Debug.Log("---000---playItAgainRespin----------")
    LeanTween.delayedCall(5.0, function()
        self.m_goReSpinAgain:SetActive(false)
        SceneSlotGame:OnSplashHide(SplashType.ReSpinEnd)
        
        SlotsGameLua.m_GameResult.m_nReSpinCount = 0
        SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 3

        LevelDataHandler:setReSpinCount(ThemeLoader.themeKey, 3)
        self:updateRespinCountInfo(3, false) -- 还剩下几次
        
        --Debug.Log("---1111111---playItAgainRespin----------")

        -- 重新来一遍消息循环检查..

        SlotsGameLua.m_bSplashFlags[SplashType.ReSpin] = true
        
        self.m_bInReSpin = true

        self.m_bPlayItAgainRespin = true
        --self:handleReSpinBegin()

        SlotsGameLua.m_bInResult = true
        SlotsGameLua.m_nSplashActive = 1
        SceneSlotGame:ButtonEnable(false)
        SceneSlotGame.m_btnSpin.interactable = false
        
        SceneSlotGame.m_SlotsNumberWins:End(0)
        
    end)

end

function SweetBlastLevelUI:onCollectBtnFreeSpinReSpinEnd()
    AudioHandler:PlayFreeGamePopupBtnSound()

    local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local bInRespinFlag = SlotsGameLua.m_GameResult:InReSpin()

    if not SweetBlastFunc.m_bPlayItAgainFlag then
        self.m_btnGummyBoard.interactable = true
    end

    if bInRespinFlag then
        self:hideReSpinEnd()
    else
        self:hideFreeSpinEnd()
    end
    
end

function SweetBlastLevelUI:onCollectBtnGrandReSpinEnd()
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:hideReSpinEnd()
    self.m_btnGummyBoard.interactable = true
end

function SweetBlastLevelUI:showReSpinEnd()
    local fCoins = SlotsGameLua.m_GameResult.m_fNonLineBonusWin
    local strCoins = MoneyFormatHelper.numWithCommas(fCoins)

    if SweetBlastFunc.m_bGrandPrizeFlag then
        AudioHandler:PlayThemeSound("grand_pop_up")

        self.m_goGrandRespinEnd:SetActive(true)
        self.m_textGrandRespinWinCoins.text = strCoins

    else
        AudioHandler:PlayFreeGamePopupEndSound()
        self.m_goFreespinRespinEnd:SetActive(true)
        self.m_textMeshProWinCoins.text = strCoins
    end


    -- 自动关闭..
    local rt = SlotsGameLua.m_GameResult
    if rt:InFreeSpin() or SlotsGameLua.m_bAutoSpinFlag then
        LeanTween.delayedCall(5.0, function()
            self:hideReSpinEnd()
        end)
    end
end

function SweetBlastLevelUI:showFreeSpinEnd(fCoins)
    AudioHandler:PlayFreeGamePopupEndSound()
    
    self.m_goFreespinRespinEnd:SetActive(true)
    
    local strCoins = MoneyFormatHelper.numWithCommas(fCoins)
    self.m_textMeshProWinCoins.text = strCoins
end

function SweetBlastLevelUI:hideFreeSpinEnd()
    Debug.Log("--------hideFreeSpinEnd------------")
    
    if not self.m_goFreespinRespinEnd.activeSelf then
        return
    end
    
    self.m_goFreespinRespinEnd:SetActive(false)
    self.m_goFreespinTransitionEffect:SetActive(true)
    self.m_SpineEffectRedBear:PlayAnimation("animation2", 0, false, 1)

    LeanTween.delayedCall(1.0, function()
        AudioHandler:PlayThemeSound("transitionFreespin")
    end)

    LeanTween.delayedCall(3.0, function()
        SweetBlastFreeSpinCommon:HideFreeSpinUI()
    end)

    LeanTween.delayedCall(4.0, function()
        self.m_SpineEffectRedBear:Reset()
        self.m_goFreespinTransitionEffect:SetActive(false)
        SceneSlotGame.m_bUIState = false
        
    end)

end

function SweetBlastLevelUI:hideReSpinEnd()
    Debug.Log("--------hideReSpinEnd------------")
    
    if (not self.m_goFreespinRespinEnd.activeSelf) and (not self.m_goGrandRespinEnd.activeSelf) then
        return
    end

    SweetBlastFunc.m_bGrandPrizeFlag = false
    self.m_goGrandRespinEnd:SetActive(false)
    
    for i=1, 4 do
        self.m_listGoJackpotEffect[i]:SetActive(false)
    end

    self.m_goFreespinRespinEnd:SetActive(false)
    self:resetJackpotValue() -- 把领过奖的重置
    UITop:updateCoinCountInUi(5.0)
    
    -- respin结束了在这里修改到数据库  获得respin的时候在各自的关卡里写数据库
    local nReSpinNum = 0
    SlotsGameLua.m_GameResult.m_nReSpinCount = 0
    SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 0

    LevelDataHandler:setReSpinCount(ThemeLoader.themeKey, 0)
    local bInFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    if bInFreeSpinFlag then
        AudioHandler:LoadFreeGameMusic()
    else
        AudioHandler:LoadBaseGameMusic()
    end
    
    if SweetBlastFunc.m_bPlayItAgainFlag then
        SweetBlastFunc.m_bPlayItAgainFlag = false

        AudioHandler:PlayThemeSound("respin_triggered")

        local ftime = 1.5
        local go = SweetBlastFunc.m_goPlayItAgainStickyElem

        local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]
        if clipEffect ~= nil then
            -- play it again 专用
            
            -- clipEffect:playAniByPlayMode(2) -- 1落地  2结算
            clipEffect.m_animator:Play("CollectElemplayagainAni", -1, 0)

            -- LeanTween.delayedCall(0.1, function()
            --     clipEffect:resetPlayModeDefault()
            -- end)
        end

        LeanTween.delayedCall(1.2, function()
            self:resetStickySymbols() -- 放回棋盘滚动出去。。

            --Debug.Log("------self:playItAgainRespin------")

            self:playItAgainRespin()
        end)

    else
        SweetBlastFunc.m_bHasPlayItAgain = false 
        -- again的情况就别再允许出again了 again的整个过程中m_bHasPlayItAgain都是true...

        self:resetStickySymbols() -- 放回棋盘滚动出去。。
        -- bangbangtangguochang

        AudioHandler:PlayThemeSound("transitionRespin")
        self.m_goRespinTransitionEffect:SetActive(true)
        
        LeanTween.delayedCall(1.5, function()
            self.m_goReSpinBG:SetActive(false)
            SceneSlotGame:OnSplashHide(SplashType.ReSpinEnd)
        end)

        LeanTween.delayedCall(3.5, function()
            self.m_goRespinTransitionEffect:SetActive(false)
        end)

        if self.m_bGingermanStoreRespinFlag then
            self.m_bGingermanStoreRespinFlag = false
            SceneSlotGame.m_nTotalBet = self.m_nPreTotalBet
            
            local strTotalBet = MoneyFormatHelper.numWithCommas( SceneSlotGame.m_nTotalBet )
            SceneSlotGame.m_textTotalBet.text = strTotalBet

            self:modifyJackpotValueByTotalBet()

        end
        
    end
end

function SweetBlastLevelUI:handleReSpinEnd()
    -- 结算过程的动画等等...
    Debug.Log("--------SweetBlastLevelUI:handleReSpinEnd()----------")


    ---所有固定的元素依次播放动画..
    -- 返回播放完所有元素动画的时间。。ftime
    local ftime = self:playStickyCollectElemsAni()

    LeanTween.delayedCall(ftime, function()
        self:showReSpinEnd()
    
    end)
    
    local fGameWin = SlotsGameLua.m_GameResult.m_fNonLineBonusWin

    SceneSlotGame.m_SlotsNumberWins:ChangeTo(fGameWin, ftime)

    self.m_goRespinCollectMoneyAni:SetActive(true)
    LeanTween.delayedCall(ftime, function()
        self.m_goRespinCollectMoneyAni:SetActive(false)
    end)
    
end

function SweetBlastLevelUI:playStickyCollectElemsAni()
    local listGoStickys = {}

    local fTotalValue = 0

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[i]
        for j = SlotsGameLua.m_nRowCount - 1, 0, -1 do
            local key = i * SlotsGameLua.m_nRowCount + j
            local bStickyFlag, nStickyIndex = reel:isStickyPos(j)
            if bStickyFlag then
                
                local value = SweetBlastFunc.m_mapCollectElemValue[key]
                
                -- if value > 0 then
                --     fTotalValue = fTotalValue + value
                -- end
                
                if value == -4 then -- 来到这里不会有-5 -6了 -5 -6在之前已经变成一个credit元素了。。
                    -- self.m_bPlayItAgainFlag = true
                    -- 跳过 等respin结束金币结算了再开始。。
                    
                else
                    local go = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
                    table.insert(listGoStickys, go)
                end
                
            end
        end
    end

    --Debug.Log("------------------fTotalValue: " .. fTotalValue)

    local cnt = #listGoStickys
    local fDeltaTime = 0.667
    local ftime = 0.0
    for i=1, cnt do
        LeanTween.delayedCall(ftime, function()
            local go = listGoStickys[i]

            local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]
            if clipEffect ~= nil then
                -- CollectElem2Ani
                clipEffect.m_animator:Play("CollectElem2Ani", -1, 0)
                -- clipEffect:playAniByPlayMode(2) -- 1落地  2结算

                AudioHandler:PlayThemeSound("respin_payout")
                
                -- LeanTween.delayedCall(0.1, function()
                --     clipEffect:resetPlayModeDefault()
                -- end)
            end

        end)

        ftime = ftime + fDeltaTime
    end

    return ftime
end

function SweetBlastLevelUI:resetStickySymbols()
    local nReelCount = SlotsGameLua.m_nReelCount

    for i=0, nReelCount-1 do
        local reel = SlotsGameLua.m_listReelLua[i]
        local cnt = #reel.m_listStickySymbol
        for j=1, cnt do
            local goSymbol = reel.m_listStickySymbol[j].m_goSymbol
            if goSymbol ~= nil then
                local nRowIndex = reel.m_listStickySymbol[j].m_nReelPos
                local nSymbolId = reel.m_listStickySymbol[j].m_nSymbolId
                local preGoSymbol = reel.m_listGoSymbol[nRowIndex]
                SymbolObjectPool:Unspawn(preGoSymbol)
                
                goSymbol.transform:SetParent(reel.m_transform, false)
                goSymbol.transform.localScale = Unity.Vector3.one
                goSymbol.transform.localPosition = reel.m_listSymbolPos[nRowIndex]

                reel.m_listGoSymbol[nRowIndex] = goSymbol

                SweetBlastFunc:SymbolRectGroupHandler(goSymbol, i)


                -- m_curSymbolIds 与之前的一样 没有改变
            end
        end

        reel.m_listStickySymbol = {}
    end

    SweetBlastFunc.m_mapCollectElemValue = {}

end

---- 2018-9-14
-- SplashType.Bonus 消息的处理 -- 3张bonus牌触发的情况
function SweetBlastLevelUI:handleBonusGameBegin()
    AudioHandler:PlayFreeGameTriggeredSound()
    self:ShowScatterBonusEffect()
    local ftime = 3.8
    
    SceneSlotGame.m_bUIState = true
    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false
    -- nType 1: 3个bonus牌触发的   2: 姜饼人开箱子兑换到的。。。
    self.m_bThreeBonusElemTriggerFlag = true

    SweetBlastLevelParam:setBonusGameBetByType(1)

    LeanTween.delayedCall(ftime, function()
        AudioHandler:PlayThemeSound("freePopupStart")
        self.m_goBonusGameBeginUI:SetActive(true)
        self:HideScatterBonusEffect()
    end)
    
    LeanTween.delayedCall(ftime + 3.2, function()
        self.m_goBonusGameBeginUI:SetActive(false)
        SweetBlastBonusGameUI:Show() -- 这个界面有出场动画就更好了。。。
    end)
end

function SweetBlastLevelUI:onFreeSpinStartBtnClick()
    AudioHandler:PlayFreeGamePopupBtnSound()

    self.m_goFreeBeginUI:SetActive(false)

    self.m_goFreespinTransitionEffect:SetActive(true)
    self.m_SpineEffectRedBear:PlayAnimation("animation2", 0, false, 1)

    LeanTween.delayedCall(1.0, function()
        AudioHandler:PlayThemeSound("transitionFreespin")
    end)

    LeanTween.delayedCall(3.0, function()
        SweetBlastBonusGameUI:hide() -- 如果是从bonusgame里触发的freespin..
        SweetBlastGummyBoardUI:hide() -- 从翻牌小游戏里触发的...

        SceneSlotGame:OnSplashHide(SplashType.Bonus)
        SceneSlotGame.m_bUIState = false
        self:FreeSpinFunc()
    end)

    LeanTween.delayedCall(4.0, function()
        self.m_SpineEffectRedBear:Reset()
        self.m_goFreespinTransitionEffect:SetActive(false)
    end)
end

function SweetBlastLevelUI:FreeSpinFunc()
    self:BaseGameToSweetBlastFreeSpin()
    
    local param = self:getFreeSpinParam()
    -- local nFreeSpinType = param.m_nFreeSpinType
    -- local listWildReelID = param.m_listWildReelID
    -- local fFreeSpinBet = param.m_fFreeSpinBet

    SweetBlastFreeSpinCommon:TriggerFreeSpinHandle(param)
end

-- 2018-10-10 
function SweetBlastLevelUI:TriggerSweetBlastFreeSpin(nFreeSpinType, nFreeSpinNum, listWildReelID, fFreeSpinBet)
    LevelDataHandler:addNewFreeSpinCount(ThemeLoader.themeKey, nFreeSpinNum)
    LevelDataHandler:addTotalFreeSpinCount(ThemeLoader.themeKey, nFreeSpinNum)

    SceneSlotGame.m_bUIState = true

    local param = {}
    param.m_nFreeSpinType = nFreeSpinType -- 0类型 无意义。。
    param.m_listWildReelID = listWildReelID
    param.m_fFreeSpinBet = fFreeSpinBet
    self:setFreeSpinParam(param)

    SlotsGameLua.m_GameResult.m_fGameWin = 0
    SlotsGameLua.m_GameResult.m_nNewFreeSpinCount = nFreeSpinNum
    SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = nFreeSpinNum
    SlotsGameLua.m_GameResult.m_nFreeSpinCount = 0

    SweetBlastFreeSpinCommon.m_nFreeSpinNum = nFreeSpinNum

    -- freespinBegin 界面以及界面上的参数初始化
    local id = LeanTween.delayedCall(4.0, function()
        AudioHandler:PlayFreeGamePopupSound()
        
        self:ShowFreeSpinBeginUI(nFreeSpinNum, nFreeSpinType, listWildReelID)
    end).id

    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id)

end

function SweetBlastLevelUI:ShowFreeSpinBeginUI(nFreeSpinNum, nFreeSpinType, listWildReelID)
    -- freespinBegin 界面以及界面上的参数初始化
    self.m_goFreeBeginUI:SetActive(true)

    self.m_TextMeshProFreeSpinNum.text = tostring( math.floor(nFreeSpinNum) )
    local nReelsNum = math.floor( nFreeSpinType % 3 )
    if nReelsNum == 0 then
        nReelsNum = 4
    else
        nReelsNum = nReelsNum + 1
    end
    local strReelsNum = tostring(nReelsNum)
    self.m_TextMeshProReelsNum.text = strReelsNum

    self.m_goWILD3XLOGO:SetActive(false)
    self.m_goWILD4XLOGO:SetActive(false)
    for i=1, 5 do
        self.m_listGoWildReel4X[i]:SetActive(false)
        self.m_listGoWildReel3X[i]:SetActive(false)
    end

    local listWildIndex = {}
    if nFreeSpinType >= 4 then
        self.m_goWILD4XLOGO:SetActive(true)
        listWildIndex = self.m_listGoWildReel4X
    else
        self.m_goWILD3XLOGO:SetActive(true)
        listWildIndex = self.m_listGoWildReel3X
    end

    for i=1, #listWildReelID do
        local index = listWildReelID[i] -- 0 1 2 3 4
        listWildIndex[index+1]:SetActive(true)
    end
end

-- UI切换 等...
function SweetBlastLevelUI:BaseGameToSweetBlastFreeSpin()
    SweetBlastFunc:showSpineFrame0(true)
    
    self.m_goFreeSpinBG:SetActive(true)
    self.m_goJackPotValueUI:SetActive(false)
    self.m_goBtnCanvas:SetActive(false)
    self.m_goSlotsDataInfo:SetActive(false)
    self.m_goBaseGameBG:SetActive(false)

    -- 把以前的下注记录着
    self.m_nPreTotalBet = SceneSlotGame.m_nTotalBet

   CoroutineHelper.waitForEndOfFrame(function()
        Unity.Resources.UnloadUnusedAssets()
    end)
end

function SweetBlastLevelUI:SweetBlastFreeSpinToBaseGame()
    self.m_goFreeSpinBG:SetActive(false)
    self.m_goJackPotValueUI:SetActive(true)
    self.m_goBtnCanvas:SetActive(true)
    self.m_goSlotsDataInfo:SetActive(true)
    self.m_goBaseGameBG:SetActive(true)

    self.m_bThreeBonusElemTriggerFlag = false
    SceneSlotGame.m_nTotalBet = self.m_nPreTotalBet

   CoroutineHelper.waitForEndOfFrame(function()
        Unity.Resources.UnloadUnusedAssets()
    end)
end

-- 写数据库 FreeSpin 的类型。。(次数不在这写)
function SweetBlastLevelUI:setFreeSpinParam(param)
    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data == nil then
		LevelDataHandler.m_Data = {}
	end

    LevelDataHandler.m_Data.param = param
	LevelDataHandler:persistentData()
end

function SweetBlastLevelUI:getFreeSpinParam() -- 杀进程再进之后恢复需要
    local strLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data == nil then
        return 0
	end

    local param = LevelDataHandler.m_Data.param
    if param == nil then
        param.m_nFreeSpinType = 0 -- 0类型 无意义。。
        param.m_listWildReelID = {}
    end

    return param
end

function SweetBlastLevelUI:addBonusGameNum()
    -- 统计触发了多少次bonusgame了
    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data == nil then
        LevelDataHandler.m_Data = {}
    end
    
    if LevelDataHandler.m_Data.m_nBonusGameNum == nil then
        LevelDataHandler.m_Data.m_nBonusGameNum = 0
    end

    local nBonusGameNum = LevelDataHandler.m_Data.m_nBonusGameNum
    LevelDataHandler.m_Data.m_nBonusGameNum = nBonusGameNum + 1
	LevelDataHandler:persistentData()
end

function SweetBlastLevelUI:getBonusGameNum()
    local strLevelName = ThemeLoader.themeKey

    if LevelDataHandler.m_Data == nil then
        return 0
    end
    
    if LevelDataHandler.m_Data.m_nBonusGameNum == nil then
        return 0
    end

    local num = LevelDataHandler.m_Data.m_nBonusGameNum
    return num
end

function SweetBlastLevelUI:addRespinTriggerNum()
    -- 统计触发了多少次bonusgame了
    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data == nil then
        LevelDataHandler.m_Data = {}
    end
    
    if LevelDataHandler.m_Data.m_nRespinTriggerNum == nil then
        LevelDataHandler.m_Data.m_nRespinTriggerNum = 0
    end

    local nRespinTriggerNum = LevelDataHandler.m_Data.m_nRespinTriggerNum
    LevelDataHandler.m_Data.m_nRespinTriggerNum = nRespinTriggerNum + 1
	LevelDataHandler:persistentData()
end

function SweetBlastLevelUI:getRespinTriggerNum()
    local strLevelName = ThemeLoader.themeKey

    if LevelDataHandler.m_Data == nil then
        return 0
    end
    
    if LevelDataHandler.m_Data.m_nRespinTriggerNum == nil then
        return 0
    end

    local num = LevelDataHandler.m_Data.m_nRespinTriggerNum
    return num
end

-------- 2019-10-26
--==================================== 数据库 ======================================

-- nType 0 1 2
-- 2 的情况是结算时候断线了但是盘面有playitagain的情况
-- 1 的情况是结算了 盘面没有playitagain
-- 0 的情况是没有结算，平常respin的一回合滚动结束或者是首次触发

function SweetBlastLevelUI:setDBReSpin(nType)
    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local gameResult = SlotsGameLua.m_GameResult
    
    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data == nil then
		LevelDataHandler.m_Data = {}
    end 

    local param = LevelDataHandler.m_Data
    param.bInReSpin = self.m_bInReSpin -- gameResult:InReSpin()

    param.m_bGingermanStoreRespinFlag = self.m_bGingermanStoreRespinFlag
    param.m_nTotalBet = SceneSlotGame.m_nTotalBet 
    -- 开姜饼人箱子开出来的情况 这里得存数据库 才能恢复..

    local tableReSpinFixedSymbol = {}

    if nType == nil then
        nType = 0
    end

    if nType ~= 2 then
        for k, v in pairs(SweetBlastFunc.m_mapCollectElemValue) do
            local value = SweetBlastFunc.m_mapCollectElemValue[k]
            -- value 就是这些.. SweetBlastFunc.CollectValueType
            table.insert(tableReSpinFixedSymbol, {k, value})
        end
    end

    param.tableReSpinFixedSymbol = tableReSpinFixedSymbol

    local nRemainReSpinSpinCount = gameResult.m_nReSpinTotalCount - gameResult.m_nReSpinCount
    if nRemainReSpinSpinCount < 0 then
        nRemainReSpinSpinCount = 0
    end

    if nType == 2 then
        nRemainReSpinSpinCount = 3
        param.m_bHasPlayItAgain = true
    end

    if nType == 1 then
        param.m_bHasPlayItAgain = false
    end

    param.nRemainReSpinSpinCount = nRemainReSpinSpinCount
    LevelDataHandler:persistentData()
end

function SweetBlastLevelUI:getDBReSpin()
	local param = LevelDataHandler.m_Data
	if param == nil then
        return
    end
    
	if param.bInReSpin == nil then
		return
	end

    if param.bInReSpin then
        if param.tableReSpinFixedSymbol then
            SweetBlastFunc.m_mapCollectElemValue = {}
            for k, v in pairs(param.tableReSpinFixedSymbol) do
                SweetBlastFunc.m_mapCollectElemValue[v[1]] = v[2]
            end
        end
        
        self.m_nRemainReSpinSpinCount = param.nRemainReSpinSpinCount
        self.m_bInReSpin = true
        SweetBlastFunc.m_bHasPlayItAgain = param.m_bHasPlayItAgain

        self.m_bGingermanStoreRespinFlag = param.m_bGingermanStoreRespinFlag

        -- 把以前的下注记录着
        self.m_nPreTotalBet = SceneSlotGame.m_nTotalBet
        SceneSlotGame.m_nTotalBet = param.m_nTotalBet
    end

end
