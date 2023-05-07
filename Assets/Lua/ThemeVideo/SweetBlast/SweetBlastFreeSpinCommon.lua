require "Lua/ThemeVideo2020/SweetBlast/SweetBlastFreeSpinGameMain"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastFreeSpinGameExtra1"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastFreeSpinGameExtra2"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastFreeSpinGameExtra3"

require "Lua/ThemeVideo2020/SweetBlast/FreeSpinData3X5"
require "Lua/ThemeVideo2020/SweetBlast/FreeSpinData4X5"


-- reels 一个棋盘
SweetBlastReelsType = {
    ReelsTypeNull = -1,

    ReelsTypeBase = 0, -- basegame 下的情况

    ReelsType3X5_2_1 = 1, -- 两个棋盘的主棋盘
    ReelsType3X5_2_2 = 2,

    ReelsType3X5_3_1 = 3, -- 三个棋盘的主棋盘
    ReelsType3X5_3_2 = 4,
    ReelsType3X5_3_3 = 5,

    ReelsType3X5_4_1 = 6, -- 四个棋盘的主棋盘
    ReelsType3X5_4_2 = 7,
    ReelsType3X5_4_3 = 8,
    ReelsType3X5_4_4 = 9,
    ----------
    ReelsType4X5_2_1 = 10,
    ReelsType4X5_2_2 = 11,

    ReelsType4X5_3_1 = 12,
    ReelsType4X5_3_2 = 13,
    ReelsType4X5_3_3 = 14,

    ReelsType4X5_4_1 = 15,
    ReelsType4X5_4_2 = 16,
    ReelsType4X5_4_3 = 17,
    ReelsType4X5_4_4 = 18,
}

-- FreeSpin都有哪些种类
EnumSweetBlastFreeSpinType = {
    FreeSpin3X5_2 = 1,
    FreeSpin3X5_3 = 2,
    FreeSpin3X5_4 = 3,
    -------
    FreeSpin4X5_2 = 4,
    FreeSpin4X5_3 = 5,
    FreeSpin4X5_4 = 6
}

SweetBlastFreeSpinCommon = {}
-- 这个文件里做的是6种freespin公用的 UI开始结束 元素缓存处理 元素sticky 等。。

SweetBlastFreeSpinCommon.m_transform = nil -- trSweetBlastFreeSpinBG

-- 触发不同类型的freespin需要显示隐藏不同的节点...
-- FreeSpin3X5_2 FreeSpin3X5_3 FreeSpin3X5_4
-- FreeSpin4X5_2 FreeSpin4X5_3 FreeSpin4X5_4
SweetBlastFreeSpinCommon.m_mapGoFreeSpinNode = {} -- key: EnumSweetBlastFreeSpinType value: go

--
SweetBlastFreeSpinCommon.m_nFreeSpinType = 0 -- EnumSweetBlastFreeSpinType
SweetBlastFreeSpinCommon.m_nUsedReelsNum = 0 -- 几个棋盘是有用的
SweetBlastFreeSpinCommon.m_nRowCount = 0 -- 3 or 4
SweetBlastFreeSpinCommon.m_nFreeSpinNum = 0

SweetBlastFreeSpinCommon.m_listWildReelIDs = {} -- 哪些列是固定wild的 这里记录的是reelid

--key: SweetBlastReelsType  value: CustomerRectMaskGroup
SweetBlastFreeSpinCommon.m_mapFreeSpinRectGroup = {}

function SweetBlastFreeSpinCommon:init()
    local go = SweetBlastLevelUI.m_goFreeSpinBG
    -- LuaAutoBindMonoBehaviour.Bind(go, self)
    -- LuaAutoBindMonoBehaviour.Bind(go, self)

    local trFreeSpinNode = go.transform
    self.m_transform = trFreeSpinNode

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin3X5_2").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin3X5_2
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin3X5_3").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin3X5_3
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin3X5_4").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin3X5_4
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin4X5_2").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin4X5_2
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin4X5_3").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    local goFreeSpin = trFreeSpinNode:FindDeepChild("FreeSpin4X5_4").gameObject
    goFreeSpin:SetActive(false)
    local nType = EnumSweetBlastFreeSpinType.FreeSpin4X5_4
    self.m_mapGoFreeSpinNode[nType] = goFreeSpin

    self:readData() -- 读CFG文件 填充 SlotsGameLua.m_listSymbolLua ..

    FreeSpinData3X5:Init()
    FreeSpinData4X5:Init()

    self:initFreeSpinRectGroup()
end

function SweetBlastFreeSpinCommon:initFreeSpinRectGroup()
    -- FreeSpin3X5_2 Group2_1 Group2_2 (RectGroup)
    -- FreeSpin3X5_3 Group3_1 Group3_2 Group3_3 (RectGroup)
    -- FreeSpin3X5_4 Group4_1 Group4_2 Group4_3  Group4_4 (RectGroup)

    -- FreeSpin4X5_2 Group2_1 Group2_2 (RectGroup)
    -- FreeSpin4X5_3 Group3_1 Group3_2 Group3_3 (RectGroup)
    -- FreeSpin4X5_4 Group4_1 Group4_2 Group4_3  Group4_4 (RectGroup)

    -- 
    local tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin3X5_2].transform
    local trGroup321 = tr:FindDeepChild("Group2_1")
    local trGroup322 = tr:FindDeepChild("Group2_2")

    tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin3X5_3].transform
    local trGroup331 = tr:FindDeepChild("Group3_1")
    local trGroup332 = tr:FindDeepChild("Group3_2")
    local trGroup333 = tr:FindDeepChild("Group3_3")

    tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin3X5_4].transform
    local trGroup341 = tr:FindDeepChild("Group4_1")
    local trGroup342 = tr:FindDeepChild("Group4_2")
    local trGroup343 = tr:FindDeepChild("Group4_3")
    local trGroup344 = tr:FindDeepChild("Group4_4")

    -- 
    tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin4X5_2].transform
    local trGroup421 = tr:FindDeepChild("Group2_1")
    local trGroup422 = tr:FindDeepChild("Group2_2")

    tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin4X5_3].transform
    local trGroup431 = tr:FindDeepChild("Group3_1")
    local trGroup432 = tr:FindDeepChild("Group3_2")
    local trGroup433 = tr:FindDeepChild("Group3_3")

    tr = self.m_mapGoFreeSpinNode[EnumSweetBlastFreeSpinType.FreeSpin4X5_4].transform
    local trGroup441 = tr:FindDeepChild("Group4_1")
    local trGroup442 = tr:FindDeepChild("Group4_2")
    local trGroup443 = tr:FindDeepChild("Group4_3")
    local trGroup444 = tr:FindDeepChild("Group4_4")

    local listTrs = {trGroup321, trGroup322, trGroup331, trGroup332, trGroup333, 
                    trGroup341, trGroup342, trGroup343, trGroup344,
                    trGroup421, trGroup422, trGroup431, trGroup432, trGroup433, 
                    trGroup441, trGroup442, trGroup443, trGroup444}
    for i=1, 18 do
        local tr = listTrs[i]
        local trRectGroup = tr:FindDeepChild("RectGroup")
        local rectMask = trRectGroup:GetComponent(typeof(CS.CustomerRectMaskGroup))
        self.m_mapFreeSpinRectGroup[i] = rectMask
    end
end

function SweetBlastFreeSpinCommon:SetSymbolRectGroup(go, nReelsType)
    local targetGroup = self.m_mapFreeSpinRectGroup[nReelsType]
    SweetBlastFunc:SetSymbolRectGroup(go, targetGroup)
end

function SweetBlastFreeSpinCommon:readData()
    local strCFGFileName = ThemeLoader.themeKey.."CFG"
    local strRq = "Lua/ThemeVideo2020CFG/"..strCFGFileName
    self.mCFGData = require(strRq)

    SlotsGameLua.m_listSymbolLua = {}
    for k, v in pairs(self.mCFGData.SymbolList) do
        Debug.Assert(k == v.nId)
        
        local nSymbolId = k
        SlotsGameLua.m_listSymbolLua[nSymbolId] = SymbolLua:create(nSymbolId, v)
        if v.m_nSymbolType ~= 0 then
            SlotsGameLua.m_listSymbolLua[nSymbolId].type = SymbolType.Special
        end
    end

end

-- function SweetBlastFreeSpinCommon:OnEnable()
-- end

-- function SweetBlastFreeSpinCommon:Start()
-- end

-- function SweetBlastFreeSpinCommon:Update()
-- end

-- function SweetBlastFreeSpinCommon:OnDisable()
-- end

-- function SweetBlastFreeSpinCommon:OnDestroy()
-- end

function SweetBlastFreeSpinCommon:TriggerFreeSpinHandle(param)
    -- self.m_transform.gameObject:SetActive(true) -- 在levelui里做了
    local nFreeSpinType = param.m_nFreeSpinType
    local listWildReelID = param.m_listWildReelID
    local fFreeSpinBet = param.m_fFreeSpinBet

    SceneSlotGame.m_nTotalBet = math.floor( fFreeSpinBet )

    Debug.Log("----TriggerFreeSpinHandle------nFreeSpinType: " .. nFreeSpinType)
    
    self.m_mapGoFreeSpinNode[nFreeSpinType]:SetActive(true)

    SceneSlotGame.m_SlotsNumberWins:End(SlotsGameLua.m_GameResult.m_fGameWin)
    SceneSlotGame:setTotalWinTipInfo("WIN", false)

    self.m_listWildReelIDs = listWildReelID

    self.m_nFreeSpinType = nFreeSpinType -- EnumSweetBlastFreeSpinType

    PayLinePayWaysEffectHandler:MatchLineHide(true)
    
    SlotsGameLua.m_bAutoSpinFlag = false
    AudioHandler:LoadFreeGameMusic()

    self:ShowFreeSpinUI()
    
    -- 以下初始化棋盘。。 包括初始化要放在这个棋盘上的大量元素缓存 不同group间的元素不能混用
    -- init()

    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        self.m_nUsedReelsNum = 2 -- 几个棋盘是有用的
        self.m_nRowCount = 3

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        self.m_nUsedReelsNum = 3
        self.m_nRowCount = 3

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        self.m_nUsedReelsNum = 4
        self.m_nRowCount = 3

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        self.m_nUsedReelsNum = 2
        self.m_nRowCount = 4

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        self.m_nUsedReelsNum = 3
        self.m_nRowCount = 4

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        self.m_nUsedReelsNum = 4
        self.m_nRowCount = 4
        
    end
    
    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    for i=1, self.m_nUsedReelsNum do
        listGames[i].m_nRowCount = self.m_nRowCount
        listGames[i]:init()
    end

    self:stickySymbols(listWildReelID)

end

function SweetBlastFreeSpinCommon:stickySymbols(listWildReelID)
    -- 所有棋盘固定wild的列都一样
    local nStickyWildID = SlotsGameLua:GetSymbolIdByObjName("WILD1")
    local nStickyWildID3 = SlotsGameLua:GetSymbolIdByObjName("WILD3X1")
    local nStickyWildID4 = SlotsGameLua:GetSymbolIdByObjName("WILD4X1")

    local symbol3X1 = FreeSpinData3X5:GetSymbol(nStickyWildID3)
    local symbol4X1 = FreeSpinData4X5:GetSymbol(nStickyWildID4)

    local stickySymbol = symbol3X1
    if self.m_nRowCount == 4 then
        stickySymbol = symbol4X1
    end

    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    for i=1, self.m_nUsedReelsNum do
        local game = listGames[i]

        for j=1, #listWildReelID do
            local goSticky = nil
    
            local nReelId = listWildReelID[j]
            goSticky = SymbolObjectPool:Spawn(stickySymbol.prfab)
            --
            goSticky.transform:SetParent(game.m_trReels[nReelId + 1], false)
            goSticky.transform.localScale = Unity.Vector3.one
            goSticky.transform.localPosition = Unity.Vector3.zero
            
            local stickySymbol = StickySymbol:create(goSticky, nStickyWildID, 0)
            table.insert(game.m_listReelLua[nReelId].m_listStickySymbol, stickySymbol)
        end
    end
    
end

function SweetBlastFreeSpinCommon:resetStickySymbols()
    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    for i=1, self.m_nUsedReelsNum do
        local game = listGames[i]
        for i=0, 4 do
            local reel = game.m_listReelLua[i]
            local cnt = #reel.m_listStickySymbol
            for j=1, cnt do
                local goSymbol = reel.m_listStickySymbol[j].m_goSymbol
                if goSymbol ~= nil then -- 仿真的情况就是nil
                    SymbolObjectPool:Unspawn(goSymbol)
                end
            end
    
            reel.m_listStickySymbol = {}
        end
    end

end

function SweetBlastFreeSpinCommon:isAllReelsStop() -- 是否所有棋盘的所有列都停止了
    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    local bStopFlag = true
    for i=1, self.m_nUsedReelsNum do
        if not listGames[i].m_bAllReelStop then
            bStopFlag = false
            break
        end
    end

    return bStopFlag
end

function SweetBlastFreeSpinCommon:ShowFreeSpinUI()
    -- freespin里杀进程也会来到这。。
    SceneSlotGame.m_goBottomUILeftNormal:SetActive(false)
    SceneSlotGame.m_goBottomUILeftFreeSpin:SetActive(true)
    
    SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
    SpinButton:SetButtonSprite(enumButtonType.ButtonType_FreeSpin)
    SceneSlotGame:ButtonEnable(false)
    
    if SceneSlotGame.m_textAutoSpinNum.gameObject.activeSelf then
        SceneSlotGame.m_textAutoSpinNum.gameObject:SetActive(false)
    end

    local nFreeSpinNum = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - SlotsGameLua.m_GameResult.m_nFreeSpinCount
    local nTotalFreeSpinCount = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
    local strFreeSpinNumInfo = nFreeSpinNum .."/"..nTotalFreeSpinCount
    SceneSlotGame.m_textFreeSpinNumInfo.text = strFreeSpinNumInfo
    
    if SweetBlastLevelUI.m_bThreeBonusElemTriggerFlag then
        local strTotalBet = MoneyFormatHelper.numWithCommas( SceneSlotGame.m_nTotalBet )
        SceneSlotGame.m_textFreeSpinTotalBetInfo.text = strTotalBet
    else
        SceneSlotGame.m_textFreeSpinTotalBetInfo.text = "AVERAGE"
    end
    
    local fDelayTime = 1.8 -- 延迟多久开始 FreeSpins 
    
    SceneSlotGame.m_btnSpin.interactable = false
    SpinButton.m_bEnableSpinFlag = false
    SceneSlotGame:delaySetAutoSpinEnable(fDelayTime)
end

function SweetBlastFreeSpinCommon:HideFreeSpinUI()
    SceneSlotGame.m_goBottomUILeftNormal:SetActive(true)
    SceneSlotGame.m_goBottomUILeftFreeSpin:SetActive(false)
    
    self.m_mapGoFreeSpinNode[self.m_nFreeSpinType]:SetActive(false)

    self:resetStickySymbols()
    
    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    for i=1, self.m_nUsedReelsNum do
        self:resetAllSymbolPool(listGames[i])
    end
    
    SceneSlotGame:ButtonEnable(true)
    SceneSlotGame.m_bUIState = false
    
    SlotsGameLua.m_nActiveReel = -1
    SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = 0
    SlotsGameLua.m_GameResult.m_nFreeSpinCount = 0
    SweetBlastFunc.m_listHitSymbols = {}

    AudioHandler:LoadBaseGameMusic()

    -- 在这里面会把 scenetotalbet 重置回来...
    SweetBlastLevelUI:SweetBlastFreeSpinToBaseGame()
end

function SweetBlastFreeSpinCommon:GetLine(nLineID)
    local nFreeSpinType = self.m_nFreeSpinType

    if nFreeSpinType <= 3 then
        return FreeSpinData3X5:GetLine(nLineID)
    else
        return FreeSpinData4X5:GetLine(nLineID)
    end
end

function SweetBlastFreeSpinCommon:getDeck()
    local deck = {}
    local nFreeSpinType = self.m_nFreeSpinType
    
    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        deck = FreeSpinData3X5:get2XDeck()

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        deck = FreeSpinData3X5:get3XDeck()

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        deck = FreeSpinData3X5:get4XDeck()

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        deck = FreeSpinData4X5:get2XDeck()

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        deck = FreeSpinData4X5:get3XDeck()

    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        deck = FreeSpinData4X5:get4XDeck()
        
    end

    return deck
end

function SweetBlastFreeSpinCommon:CreateReelRandomSymbolList(game)
    local nTotal = 100
    local nSymbolId = 1 -- 普通元素

    for i=1, nTotal do
        for x=0, game.m_nReelCount-1 do
            --local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            
            nSymbolId = math.random(1, 10) -- 普通元素

            if game.m_listReelLua[x].m_listRandomSymbolID == nil then
                game.m_listReelLua[x].m_listRandomSymbolID = {}
            end

            game.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

end

function SweetBlastFreeSpinCommon:resetAllSymbolPool(game)
    for k, v in pairs(game.m_mapSymbolPool) do
        local listSymbols = v
        for i=1, #listSymbols do
            local go = listSymbols[i]
            SymbolObjectPool:Unspawn(go)
        end
    end

    game.m_mapSymbolPool = {}

    for reelid=0, 4 do
        local reel = game.m_listReelLua[reelid]
        local listSymbols = reel.m_listGoSymbol
        
        local cnt = reel.m_nReelRow + reel.m_nAddSymbolNums
        for i=0, cnt-1 do
            local go = listSymbols[i]
            SymbolObjectPool:Unspawn(go)
        end

        reel.m_listGoSymbol = {}

        local listSymbols = reel.m_listOutSideSymbols
        for i=1, #listSymbols do
            local go = listSymbols[i]
            SymbolObjectPool:Unspawn(go)
        end
        reel.m_listOutSideSymbols = {}
    end
end

function SweetBlastFreeSpinCommon:initSymbolPool(game)
    -- 放一堆元素来 game.m_trSymbolsPool 下

    for nSymbolID=1, 11 do -- 高级元素加上AKQJ10 wild
        for i=1, 10 do -- 每个元素缓存10个到这个group下来
            local newSymbol = self:GetSymbol(nSymbolID)
            local go = SymbolObjectPool:Spawn(newSymbol.prfab)
            local tr = SymbolObjectPool.m_mapGOElemTransform[go]
            tr:SetParent(game.m_trSymbolsPool)
            tr.localScale = Unity.Vector3.one
            tr.localPosition = Unity.Vector3.zero
            
            local goGingerman = SweetBlastFunc.m_mapGoGingermanLogo[go]
            if goGingerman ~= nil then
                goGingerman:SetActive(false)
            end

            self:SetSymbolRectGroup(go, game.m_nReelsType)
            go:SetActive(false)

            if game.m_mapSymbolPool[newSymbol.prfab] == nil then
                game.m_mapSymbolPool[newSymbol.prfab] = {}
            end
            table.insert(game.m_mapSymbolPool[newSymbol.prfab], go)
        end
    end
end

function SweetBlastFreeSpinCommon:getSymbolObject(nSymbolID, game)
    local newSymbol = self:GetSymbol(nSymbolID)
    local listSymbols = game.m_mapSymbolPool[newSymbol.prfab]

    local bres1 = listSymbols == nil
    local bres2 = false
    if listSymbols ~= nil then
        if #listSymbols == 0 then
            bres2 = true
        end
    else
        -- 正常的。。
    end

    if bres1 or bres2 then
        local go = SymbolObjectPool:Spawn(newSymbol.prfab)
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]
        tr:SetParent(game.m_trSymbolsPool)
        tr.localScale = Unity.Vector3.one
        tr.localPosition = Unity.Vector3.zero
        
        local goGingerman = SweetBlastFunc.m_mapGoGingermanLogo[go]
        if goGingerman ~= nil then
            goGingerman:SetActive(false)
        end

       CoroutineHelper.waitForEndOfFrame(function()
            self:SetSymbolRectGroup(go, game.m_nReelsType)
        end)

        return go
    end

    local go = listSymbols[1]
    table.remove(game.m_mapSymbolPool[newSymbol.prfab], 1)
    go:SetActive(true)
    return go
end

function SweetBlastFreeSpinCommon:reuseSymbolObject(go, game)
    local spineEffect = SymbolObjectPool.m_mapSpinEffect[go]
    if spineEffect ~= nil then
        spineEffect:StopActiveAnimation()
    end
    
    go:SetActive(false)
    
    local prefab = SymbolObjectPool.m_mapSpawnedObjects[go]

    if game.m_mapSymbolPool[prefab] == nil then
        game.m_mapSymbolPool[prefab] = {}
    end

    local tr = SymbolObjectPool.m_mapGOElemTransform[go]
    tr:SetParent(game.m_trSymbolsPool)

    table.insert(game.m_mapSymbolPool[prefab], go)
end

function SweetBlastFreeSpinCommon:GetSymbol(nSymbolID)
    local nFreeSpinType = self.m_nFreeSpinType

    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 or
        nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 or
        nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then

        return FreeSpinData3X5:GetSymbol(nSymbolID)
    end

    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 or
        nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 or
        nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then

        return FreeSpinData4X5:GetSymbol(nSymbolID)
    end

end