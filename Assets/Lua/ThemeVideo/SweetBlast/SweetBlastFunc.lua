require "Lua/ThemeVideo2020/SweetBlast/SweetBlastLevelUI"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastCustomDeck"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastSimulation"
require "Lua/ThemeVideo2020/SweetBlast/SweetBlastDeckUI"

SweetBlastFunc = {}

SweetBlastFunc.m_bSimulationFlag = false

SweetBlastFunc.m_listHitSymbols = {} -- 本轮中奖元素key 用于控制spinenode的显示与隐藏

-- 收集元素 球 上的数值。。或者 mini minor major标记。。
-- -1 mini  -2 minor  -3 major -4 play it again -5 AddAllAdjacentsType -6 AddAnAdjacent
SweetBlastFunc.m_mapCollectBallValue = {} -- go : value -- 滚动过程的也记录着

SweetBlastFunc.CollectValueType = {
    MiniType = -1, MinorType = -2, MajorType = -3, PlayItAgainType = -4, 
    AddAllAdjacentsType = -5, AddAnAdjacentType = -6, GrandType = -100,
}

SweetBlastFunc.m_mapGoValueNode = {} -- go :
-- {goTextMeshProCoinsValue, goMINI, goMINOR, goMAJOR, goPlayItAgain, 
-- AddAllAdjacents, AddAnAdjacent, TextMeshProCoinsValue}

SweetBlastFunc.m_mapCollectElemValue = {} -- key : value -- 只记录最终结果 固定元素的。。

-- play it again 最多只会出一个
SweetBlastFunc.m_bPlayItAgainFlag = false --
SweetBlastFunc.m_bResetMiniJackpot = false
SweetBlastFunc.m_bResetMinorJackpot = false
SweetBlastFunc.m_bResetMajorJackpot = false
SweetBlastFunc.m_bResetGrandJackpot = false

SweetBlastFunc.m_bCollectFullFlag = false -- 是否收集满了

-- 用来控制滚动过程中最多只掉落出一个playitagain
-- playitagain触发的respin过程中m_bHasPlayItAgain一直是true
SweetBlastFunc.m_bHasPlayItAgain = false 

SweetBlastFunc.m_goPlayItAgainStickyElem = nil -- 触发的时候要播一下闪光特效

---- GingermanLogo   -- TextMeshProGingermanNum
SweetBlastFunc.m_mapGoGingermanLogo = {} -- GoElem: GoGingermanLogo -- 所有元素
SweetBlastFunc.m_mapTextMeshProGingermanNum = {} -- GoElem: TextMeshProNum -- 所有元素
SweetBlastFunc.m_mapGingermanNum = {} -- deckKey: num -- 棋盘停下来后每个格子里的数量
--

-- 收集元素上面的金币数 totalbet 的倍数
SweetBlastFunc.m_listCollectElemCoinCoefs = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75,
                                2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0}
-- SweetBlastFunc:getCollectElemValue(bResultDeck)

SweetBlastFunc.m_mapElemReelsType = {} -- go : ReelsType

SweetBlastFunc.m_listGingermanLogoProb = {500, 310, 260, 90, 60, 30, 20, 10, 10, 10,
                                        10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
                                       
SweetBlastFunc.m_listGingermanLogoElemKeys = {}

SweetBlastFunc.m_bGrandPrizeFlag = false
SweetBlastFunc.m_bTriggerBonusGameFlag = false --true 本次spin触发了bonusgame -- 这种情况不要允许打开GummyboardUI

-- 1 2 3 4 是从上往下的顺序...
SweetBlastFunc.m_NormalRectGroup1 = nil
SweetBlastFunc.m_NormalRectGroup2 = nil
SweetBlastFunc.m_NormalRectGroup3 = nil
SweetBlastFunc.m_NormalRectGroup4 = nil
SweetBlastFunc.m_ReSpinFixedGroup = nil -- 这个比棋盘大

SweetBlastFunc.tableSymbolRectMaskGroup = {}
SweetBlastFunc.tableSymbolMaskGroupChildren = {}


SweetBlastFunc.N_COLLECTCOINS_MAX = 150000 -- 

-- 放到棋盘上的元素需要检查 RectGroup Mask
function SweetBlastFunc:SymbolRectGroupHandler(go, nReelID)
    local targetGroup = nil
    if nReelID%4 == 0 then
        targetGroup = self.m_NormalRectGroup1
    elseif nReelID%4 == 1 then
        targetGroup = self.m_NormalRectGroup2
    elseif nReelID%4 == 2 then
        targetGroup = self.m_NormalRectGroup3
    elseif nReelID%4 == 3 then
        targetGroup = self.m_NormalRectGroup4
    end

    self:SetSymbolRectGroup(go, targetGroup)
end

function SweetBlastFunc:SetSymbolRectGroup(goSymbol, targetGroup)
    if self.tableSymbolRectMaskGroup[goSymbol] == targetGroup then
        return
    end 

    self.tableSymbolRectMaskGroup[goSymbol] = targetGroup

    if not self.tableSymbolMaskGroupChildren[goSymbol] then
        local tableRectMaskGroupChildren = LuaHelper.GetComponentsInChildren(goSymbol, typeof(CS.CustomerRectMaskGroupChildren))
        self.tableSymbolMaskGroupChildren[goSymbol] = tableRectMaskGroupChildren
    end
    
    for k, v in pairs(self.tableSymbolMaskGroupChildren[goSymbol]) do
        v.ValidParentMaskGroup = false
        v:SetGroupMask(targetGroup)
    end 
end

function SweetBlastFunc:destroy() -- 退出关卡时重置参数
    self.m_mapGoGingermanLogo = {}
    self.m_mapTextMeshProGingermanNum = {}
    self.m_mapGingermanNum = {}
    self.m_mapCollectElemValue = {}
    self.m_listHitSymbols = {}
    self.m_mapCollectBallValue = {}
    self.m_mapGoValueNode = {}
    self.m_bTriggerBonusGameFlag = false

    self.tableSymbolRectMaskGroup = {}
    self.tableSymbolMaskGroupChildren = {}
end

--开始滚动的时候 显示静帧 隐藏spine节点
--准备结算的时候 显示静帧 显示spine节点
function SweetBlastFunc:showSpineFrame0(bShowFrame0)
    -- 2018-6-14 显示spine节点只显示需要播放中奖特效的
    if not bShowFrame0 then
        self:showSpineNode()
        return
    end

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        local nRowCount = reel.m_nReelRow
        for y = 0, nRowCount - 1 do
            --    local nkey = SlotsGameLua.m_nRowCount * x + y

            local goSymbol = nil
            local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
            if bStickyFlag then
                goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
                self:SetSymbolRectGroup(goSymbol, nil)
            else
                goSymbol = reel.m_listGoSymbol[y]
                self:SymbolRectGroupHandler(goSymbol, x)
            end

            -- self:SymbolRectGroupHandler(goSymbol, x)
            
            local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
            if goFrame0 ~= nil then
                local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
                local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]

                if bShowFrame0 then
                    goFrame0:SetActive(true)

                    -- 要隐藏spineNode的时候 检查是否在播放 如果在播放 需要先停止播放
                    if spineEffect ~= nil then
                        spineEffect:StopActiveAnimation()
                    end
                    goSpineNode:SetActive(false)
                else
                    --显示spine节点 隐藏静帧
                    goSpineNode:SetActive(true)
                    spineEffect:Reset()
                    goFrame0:SetActive(false)
                end
            end
        end
    end
end

function SweetBlastFunc:showSpineNode() -- 滚动停止的时候调用
    local cnt = #self.m_listHitSymbols
    for i = 1, cnt do
        local key = self.m_listHitSymbols[i]
        local x = math.floor(key / SlotsGameLua.m_nRowCount)
        local y = key % SlotsGameLua.m_nRowCount

        local reel = SlotsGameLua.m_listReelLua[x]
        local goSymbol = nil
        local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
        if bStickyFlag then
            goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
        else
            goSymbol = reel.m_listGoSymbol[y]
        end

        local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
        local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
        local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
        if goSpineNode ~= nil then
            --显示spine节点 隐藏静帧
            goSpineNode:SetActive(true)
            
            spineEffect:Reset()
            goFrame0:SetActive(false)

            self:SetSymbolRectGroup(goSymbol, nil)
        end
    end

    self.m_listHitSymbols = {}
end

function SweetBlastFunc:OnStartSpin()
    self:showSpineFrame0(true)

    if SweetBlastLevelUI.m_goCollectTipAni.activeSelf then
        SweetBlastLevelUI.m_aniCollectTipUI:SetInteger("nPlayMode", 1) -- 退场动画

        LeanTween.delayedCall(2.0, function()
            SweetBlastLevelUI.m_goCollectTipAni:SetActive(false)
        end)
    end

    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end
    local bReSpinFlag = rt:InReSpin()
    if not bReSpinFlag then
        -- 如果是处于freespin中就不能在这里重置。。
        self.m_bPlayItAgainFlag = false
        self.m_bHasPlayItAgain = false

        self.m_mapCollectElemValue = {}
    end
    -- 

    self.m_bResetMiniJackpot = false
    self.m_bResetMinorJackpot = false
    self.m_bResetMajorJackpot = false
    self.m_bResetGrandJackpot = false
    self.m_bCollectFullFlag = false
    
    self.m_fRespinWinCoins = 0

    self.m_mapGingermanNum = {}

    SweetBlastLevelUI.m_btnGummyBoard.interactable = false
    self.m_bTriggerBonusGameFlag = false

    SweetBlastLevelUI.m_nCurPlayFireEffectFakeReelID = -1
end

function SweetBlastFunc:OnSpinEnd()
    self:showSpineFrame0(false)

    local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local bReSpinFlag = SlotsGameLua.m_GameResult:InReSpin()
    local nAutoSpinNum = SceneSlotGame.m_nAutoSpinNum
    
    local bCond1 = (not bFreeSpinFlag) and (not bReSpinFlag)
    local bCond2 = (not self.m_bPlayItAgainFlag) and (not self.m_bTriggerBonusGameFlag)
    --local bCond3 = nAutoSpinNum > 1
    if bCond1 and bCond2 then
        SweetBlastLevelUI.m_btnGummyBoard.interactable = true
    end
    
    -- 3个bonus触发了bonusgame之后。。 返回大厅按钮亮着。。

    if SweetBlastBonusGameUI.m_transform.gameObject.activeSelf then
        SceneSlotGame:ButtonEnable(false)
    end

end

-- 掉落过程中的检查
function SweetBlastFunc:CheckShiftDownSymbolRule(nSymbolID)
    -- respin freespin 里不要掉落bonus collectElem

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    if nSymbolID ~= nBonusID and nSymbolID ~= nCollectID then
        return nSymbolID
    end

    local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local bReSpinFlag = SlotsGameLua.m_GameResult:InReSpin()
    if (not bFreeSpinFlag) and (not bReSpinFlag) then
        return nSymbolID
    end

    nSymbolID = math.random(1, 8) -- 从普通元素里面随机一个

    return nSymbolID
end

function SweetBlastFunc:GetDeck()
    self.m_listGingermanLogoElemKeys = {}

    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    local deck = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            local nkey = SlotsGameLua.m_nRowCount * x + y
            deck[nkey] = nSymbolID
        end
    end

    -- 以下做可能的各种掉落规则检查
    -- respin 里不要掉落bonus 以及 sticky元素的下方一定掉落一个collectelem
    if bReSpinFlag then
        SweetBlastCustomDeck:checkRespinRules(deck)

        SweetBlastCustomDeck:modifyCollectElemProb(deck)
    end

    if bFreeSpinFlag then -- freespin 里不掉落bonus和collectelem
        SweetBlastCustomDeck:checkFreespinRules(deck)
    end

    if (not bReSpinFlag) and (not bFreeSpinFlag) then
        -- 检查 bonus 一列只能有一个
        SweetBlastCustomDeck:checkBonusElemRules(deck)

        
        self:initGingermanLogoElemKeys()
    end

    -- 1. 一定概率修改触发 respin 如果respin与bonusgame同时触发就去掉respin
    -- 2. 触发了respin的时候把盘面上的bonus牌清理掉。。包括顶上缓存的几个，防止滚动过程中落下来穿帮
    SweetBlastCustomDeck:modifyDeckForRespin(deck)
    
    -- 2019-8-9
    if (not bReSpinFlag) and (not bFreeSpinFlag) then
        -- 程序控制生成 bonusgame
        -- 如果上面控制要触发respin了。。在下面这个方法里就直接返回了
        SweetBlastCustomDeck:checkDeckForBonusGame(deck)
    end

    self:ModifyTestDeck(deck) -- 测试方法

    return deck
end

function SweetBlastFunc:initGingermanLogoElemKeys()
    self.m_listGingermanLogoElemKeys = {}

    local nCurCollectNum = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum

    local fProb = 0.51
    if SweetBlastCustomDeck.m_bCollectTest then
        fProb = 0.1
    end

    if math.random() < fProb or nCurCollectNum >= self.N_COLLECTCOINS_MAX then
        return
    end

    -- 确定有几个格子里会出收集数字..
    local nTotal = LuaHelper.GetIndexByRate(self.m_listGingermanLogoProb)
    
    local listElemKeys = {}
    for key=1, 20 do
        table.insert(listElemKeys, key)
    end

    listElemKeys = LuaThemeVideo2020Helper.shuffle(listElemKeys)
    for i=1, nTotal do
        table.insert( self.m_listGingermanLogoElemKeys, listElemKeys[i] )
    end
end

function SweetBlastFunc:getGingermanNum()
    local listGingermanNum = {}
    for i=1, 10 do
        listGingermanNum[i] = i * 5
    end
    local listProb = {350, 390, 50, 30, 20, 10, 10, 5, 3, 1}
    local index = LuaHelper.GetIndexByRate(listProb)
    local num = listGingermanNum[index]

    if SweetBlastCustomDeck.m_bCollectTest then
        num = num * 1000
    end
    return num
end

function SweetBlastFunc:isTriggerRespin(deck)
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if bReSpinFlag then
        return false
    end

    local bTrigerRespin = false
    -- 20个元素 6个触发
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local num = 0
    for key = 0, 19 do
        if deck[key] == nCollectID then
            num = num + 1
        end
    end

    if num >= 6 then
        bTrigerRespin = true
    end
    return bTrigerRespin
end

function SweetBlastFunc:isTriggerBonusGame(deck)
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()

    if bReSpinFlag or bFreeSpinFlag then
        return false
    end

    local bTrigerBonusGame = false
    -- 20个元素 3个触发
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    local num = 0
    for key = 0, 19 do
        if deck[key] == nBonusID then
            num = num + 1
        end
    end

    if num >= 3 then
        bTrigerBonusGame = true
    end

    return bTrigerBonusGame
end

function SweetBlastFunc:ModifyTestDeck(deck)
    if not GameConfig.PLATFORM_EDITOR then
        return
    end

    if self.m_bSimulationFlag then
        return
    end

    local nTest = -1
    if nTest < 0 then
        return
    end

    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    -- 8 9 绿熊 10 红熊
    for i=0, 2 do
        deck[4*i+0] = 8
        deck[4*i+1] = 9
        deck[4*i+2] = 10
        deck[4*i+3] = 7
    end

    -- deck[3] = 9
    -- deck[6] = 9
    deck[2] = nBonusID
    deck[6] = nBonusID

    local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local bRespinFlag = SlotsGameLua.m_GameResult:InReSpin()

    -- bRespinFlag and not SweetBlastLevelUI.m_bPlayItAgainRespin and 
    if not bRespinFlag and math.random() < -0.1 then
        deck[1] = nBonusID
        deck[5] = nBonusID
        deck[6] = 1
        deck[7] = 2
        deck[2] = 1
        deck[12] = 1
        deck[13] = 2
        deck[10] = 1
        deck[11] = nBonusID
        
    end
end

function SweetBlastFunc:CreateReelRandomSymbolList()
    local nTotal = 100
    for i = 1, nTotal do
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            if SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID == nil then
                SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
            end
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

    -- 随机滚动过程中 Bonus 每4个连续元素中最多只能有一个
    local specialSymbolID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local nPreIndex = -100
        for i = 1, nTotal do
            local nSymbolID = SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i]
            if nSymbolID == specialSymbolID then
                local ndis = i - nPreIndex
                if ndis < 4 then
                    while nSymbolID == specialSymbolID do
                        nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                    end
                    SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolID
                    ndis = -100
                else
                    nPreIndex = i
                end
            end
        end
    end
end

-- 元素上显示的信息 修改了与棋盘格子里的一样
function SweetBlastFunc:modifyGoSticky(goSticky, key)
    local goGingermanLogo = self.m_mapGoGingermanLogo[goSticky]
    if goGingermanLogo ~= nil then
        goGingermanLogo:SetActive(false)
    end
    --

    local value = self.m_mapCollectElemValue[key]
    if value == nil then
        value = SceneSlotGame.m_nTotalBet
        self.m_mapCollectElemValue[key] = value

        Debug.Log("----error!!!------value == nil------key: " .. key)
        -- return
    end
    if value < 0 then
        Debug.Log("-----modifyGoSticky-----key: " .. key .. " -----value: " .. value)
    end

    local goNodes = self:getCollectElemValueNodeGameObject(goSticky)

    for i = 1, 7 do
        goNodes[i]:SetActive(false)
    end

    if value == self.CollectValueType.MiniType then
        goNodes[2]:SetActive(true)
    elseif value == self.CollectValueType.MinorType then
        goNodes[3]:SetActive(true)
    elseif value == self.CollectValueType.MajorType then
        goNodes[4]:SetActive(true)
    elseif value == self.CollectValueType.PlayItAgainType then
        goNodes[5]:SetActive(true)
    elseif value == self.CollectValueType.AddAllAdjacentsType then
        goNodes[6]:SetActive(true)
    elseif value == self.CollectValueType.AddAnAdjacentType then
        goNodes[7]:SetActive(true)
    elseif value > 0 then
        goNodes[1]:SetActive(true)
        local nTempValue = MoneyFormatHelper.normalizeCoinCount(value, 3)
        local strValue = MoneyFormatHelper.coinCountOmit(nTempValue)
        goNodes[8].text = strValue
    end
    --
end

function SweetBlastFunc:isCollectFull(listNewCollectElems)
    local cnt = #listNewCollectElems -- 新的 加 以前固定的。。

    local nStickyNum = self:stickyElemNum()

    if (cnt + nStickyNum) == 20 then
        return true
    else
        return false
    end
end

function SweetBlastFunc:stickyElemNum() -- 返回已经固定的元素个数
    local cnt = 0
    local nReelCount = SlotsGameLua.m_nReelCount
    for i = 0, nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[i]
        local cnt1 = #reel.m_listStickySymbol
        cnt = cnt + cnt1
    end

    return cnt
end

-- Respin期间 特殊元素逻辑2个AddAdjacent 
-- 不固定 只替换盘面元素 修改deck表等 以及修改 m_mapCollectElemValue
function SweetBlastFunc:AddAdjacentElemsHandler()
    local listNewCollectElems = self:getCollectElems()
    
    if #listNewCollectElems == 0 then
        return 0
    end

    local rt = SlotsGameLua.m_GameResult
    if not rt:InReSpin() then
        if #listNewCollectElems >= 6 then
            -- 2020-12-12
            -- 这种情况是从basegame触发了respin 等转场特效结束之后再做处理。。
            -- 比如gingerman bomb等 给周围加一个元素 加八个元素之类的..
            -- 这几个元素播放特效..

            ---------
            for i=1, #listNewCollectElems do
                local key = listNewCollectElems[i]
                local reel = SlotsGameLua.m_listReelLua[key]
                local go = reel.m_listGoSymbol[0]
                self:SetSymbolRectGroup(go, nil)
                local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]
                clipEffect.m_animator:Play("CollectElem3Ani", -1, 0)
                LeanTween.delayedCall(8.0, function()
                    clipEffect.m_animator:Play("CollectElem1Ani", -1, 0)
                end)
            end
            ----------
            
            return 0
        end
    end

    if #listNewCollectElems < 6 then
        if not rt:InReSpin() then
            return 0
        end

    end

    local listAddAllAdjacentKeys = {}
    local listAddOneAdjacentKey = {}

    local bHasSpecialElemFlag = false

    for i=1, #listNewCollectElems do
        local key = listNewCollectElems[i]
        local value = self.m_mapCollectElemValue[key]
        if value == self.CollectValueType.AddAllAdjacentsType then
            table.insert(listAddAllAdjacentKeys, key)
            bHasSpecialElemFlag = true

        elseif value == self.CollectValueType.AddAnAdjacentType then
            table.insert(listAddOneAdjacentKey, key)
            bHasSpecialElemFlag = true

        end
    end

    local listAddAdjacentKeys = {} -- 已经变过或者加过 .. 就是处理过的格子记录在这里

    for i=1, #listAddAllAdjacentKeys do
        local key = listAddAllAdjacentKeys[i]
        self:handleAddAdjacent(listAddAdjacentKeys, key, true)
    end

    for i=1, #listAddOneAdjacentKey do
        local key = listAddOneAdjacentKey[i]
        self:handleAddAdjacent(listAddAdjacentKeys, key, false)
    end

    local ftime = 0.1
    if bHasSpecialElemFlag then
        ftime = 1.8
    end
    return ftime
end

-- 加一个或者加全部8个
function SweetBlastFunc:handleAddAdjacent(listAddAdjacentKeys, centerKey, bAddAllFlag)
    -- 找出周围的 collectElem 和 normalElem
    -- listAddAdjacentKeys 已经处理过的格子记录在这里
    local listCollectElem = {}
    local listNormalElem = {}

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    local nReelCount = SlotsGameLua.m_nReelCount
    local nRowCount = SlotsGameLua.m_nRowCount

    local oldReelID = math.floor(centerKey / 4)
    local oldRowIndex = centerKey % 4
    -- 找领域9格子
    for x=oldReelID-1, oldReelID+1 do
        if x >= 0 and x <= 4 then

            for y=oldRowIndex-1, oldRowIndex+1 do
                if y >= 0 and y <= 3 then

                    local nReelID = 4*x + y
                    local reel = SlotsGameLua.m_listReelLua[nReelID]

                    local nkey =nReelID
                    local nID = SlotsGameLua.m_listDeck[nkey]
                    local bres, nStickyIndex = reel:isStickyPos(0) -- 一个reel只有一个元素
                    
                    local bFlag = LuaHelper.tableContainsElement(listAddAdjacentKeys, nkey)

                    if not bFlag then -- 只找没有处理过的。。
                        if bres then -- 已经固定的..
                            -- 2019-3-22 bug修改
                            -- 只能记录金币元素... 特殊功能的元素不能处理啊..
                            -- 如果把特殊功能元素也加1倍TB就不对了。。
                            -- 特殊功能元素ElemValue里的值是-1 -2 -3 -4 等等...
                            if self.m_mapCollectElemValue[nkey] > 0 then
                                table.insert( listCollectElem, nkey )
                            end
                        else -- 还没固定的..
                            if nID == nCollectID then
                                if self.m_mapCollectElemValue[nkey] > 0 then
                                    -- 只找金币元素 特殊功能的元素不处理
                                    table.insert( listCollectElem, nkey )
                                end
                            else
                                table.insert( listNormalElem, nkey )
                            end
                        end
                    end

                end
            end
        end
    end

    local nGingerManTargetKey = 0 -- Gingerman要移动到哪个格子...

    if bAddAllFlag then -- 变周围8个
        -- listCollectElem - 里面的都加一倍TB  
        -- listCollectElem 里不包含 centerKey
        -- handleCentElem里单独处理 centerKey 直接修改成 1tb 
        for i=1, #listCollectElem do -- 
            local nkey = listCollectElem[i]
            table.insert( listAddAdjacentKeys, nkey )
    
            -- 美术特效
            local id1 = LeanTween.delayedCall(0.75, function()
                -- 开始是中间元素播放特效 0.75秒之后 周围格子开始播放特效。。播一会之后开始变元素..
                self:playChangeToCollectEffect(nkey)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)

            local id2 = LeanTween.delayedCall(1.2, function()
                self:handleOneAdjacent(nkey, false)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)
        end

        -- listNormalElem - 里面的都变成收集元素 
        for i=1, #listNormalElem do
            local nkey = listNormalElem[i]
            table.insert( listAddAdjacentKeys, nkey )
            
            -- 美术特效
            local id1 = LeanTween.delayedCall(0.75, function()
                -- 开始是中间元素播放特效 0.75秒之后 周围格子开始播放特效。。播一会之后开始变元素..
                self:playChangeToCollectEffect(nkey)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)

            local id2 = LeanTween.delayedCall(1.0, function()
                self:handleOneAdjacent(nkey, true)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)
        end

        self:handleCentElem(centerKey, SweetBlastFunc.CollectValueType.AddAllAdjacentsType, -1)
        table.insert( listAddAdjacentKeys, centerKey )

    else -- 变一个
        if #listNormalElem > 0 then
            local nRandomIndex = math.random(1, #listNormalElem)
            local nkey = listNormalElem[nRandomIndex]
            nGingerManTargetKey = nkey
            table.insert( listAddAdjacentKeys, nkey )
            
            -- 美术特效
            local id1 = LeanTween.delayedCall(0.5, function()
                -- 开始是中间元素播放特效 0.75秒之后 周围格子开始播放特效。。播一会之后开始变元素..
                self:playChangeToCollectEffect(nkey)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)

            local id2 = LeanTween.delayedCall(0.86, function()
                self:handleOneAdjacent(nkey, true)
            end).id
            table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)

        else
            for i=1, #listCollectElem do
                local nkey = listCollectElem[i]
                nGingerManTargetKey = nkey
                
                table.insert( listAddAdjacentKeys, nkey )
                    
                -- 美术特效
                local id1 = LeanTween.delayedCall(0.5, function()
                    -- 开始是中间元素播放特效 0.75秒之后 周围格子开始播放特效。。播一会之后开始变元素..
                    self:playChangeToCollectEffect(nkey)
                end).id
                table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)

                local id2 = LeanTween.delayedCall(0.86, function()
                    self:handleOneAdjacent(nkey, false)
                end).id
                table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)

                break
            end
        end

        self:handleCentElem(centerKey, SweetBlastFunc.CollectValueType.AddAnAdjacentType, nGingerManTargetKey)
        table.insert( listAddAdjacentKeys, centerKey )

    end

end

function SweetBlastFunc:playChangeToCollectEffect(key)
    local nRowCount = SlotsGameLua.m_nRowCount
    local x = math.floor(key / nRowCount)
    local y = key % nRowCount

    -- 确定飞gingerman的特效位置。。。 
    local reel = SlotsGameLua.m_listReelLua[x]
	-- local pos0 = reel.m_transform.localPosition
	-- local pos1 = reel.m_listGoSymbol[y].transform.localPosition
	-- local pos2 = SlotsGameLua.m_transform.localPosition
    local effectPos = reel.m_listGoSymbol[y].transform.position -- pos0 + pos1 + pos2
    
    local strName = "ChangeToCollectEffect"
    local effectObj = EffectObj:CreateAndShowByName(effectPos, strName, nil)
    
    LeanTween.delayedCall(0.5, function()
        effectObj:reuseCacheEffect()
    end)
    
end

-- nGingerManTargetKey 只针对姜饼人有用 炸弹的情况传入的是-1
function SweetBlastFunc:handleCentElem(nkey, enumValueType, nGingerManTargetKey)
    local nTotalBet = SceneSlotGame.m_nTotalBet
    local nRowCount = SlotsGameLua.m_nRowCount
    
    local x = math.floor( nkey / nRowCount )
    local y = nkey % nRowCount
    
    -- local x = nkey
    -- local y = 0

    local reel = SlotsGameLua.m_listReelLua[x]

    local go = reel.m_listGoSymbol[y]
    self:SetSymbolRectGroup(go, nil)

    local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]

    -- 特效不同...
    -- CollectElem2Ani respin结算时候播 直接指定clip的名字
    local fEffectTime = 0.85
    if enumValueType == self.CollectValueType.AddAllAdjacentsType then
        -- clipEffect:playAniByPlayMode(3) -- 1落地  2-结算  3变全部的圣诞树 4变单个的姜饼人

        AudioHandler:PlayThemeSound("respin_bomb")
        clipEffect.m_animator:Play("CollectElemAnizhadanzhongjiang", -1, 0)
    else
        -- clipEffect:playAniByPlayMode(4) -- 1落地  2结算  3变全部的圣诞树 4变单个的姜饼人

        AudioHandler:PlayThemeSound("respin_gingerbread")
        clipEffect.m_animator:Play("CollectElemAnijiangbingrenzhongjiang", -1, 0)
        -- nGingerManTargetKey

        --移动姜饼人节点
        local goNodes = self:getCollectElemValueNodeGameObject(go)
        local goGingerManNode = goNodes[7]

        local x = nGingerManTargetKey
        local y = 0
        local reel = SlotsGameLua.m_listReelLua[x]
        local goTarget = reel.m_listGoSymbol[y]
        local posPosition = goTarget.transform.position
        LeanTween.move(goGingerManNode, posPosition, 0.5):setOnComplete(function()
            -- 粒子特效?
        end)
    end

    local tempNodes = self:getCollectElemValueNodeGameObject(go) -- 各种节点缓存
    local nPreValue = self.m_mapCollectElemValue[nkey]

    LeanTween.delayedCall(fEffectTime, function()
       -- clipEffect:resetPlayModeDefault()
        
        tempNodes[6]:SetActive(false)
        tempNodes[7]:SetActive(false)
        tempNodes[1]:SetActive(true)

        tempNodes[7].transform.localScale = Unity.Vector3.one
        tempNodes[7].transform.localPosition = Unity.Vector3(0, 0, -5)

        local nCurValue = nTotalBet
        self.m_mapCollectElemValue[nkey] = nCurValue
        
        local nTempValue = MoneyFormatHelper.normalizeCoinCount(nCurValue, 3)
        local strValue = MoneyFormatHelper.coinCountOmit(nTempValue)
        tempNodes[8].text = strValue
    end)
    
end

function SweetBlastFunc:handleOneAdjacent(nkey, bNormalFlag)
    Debug.Log("---handleOneAdjacent---nkey: " .. nkey)
    local nTotalBet = SceneSlotGame.m_nTotalBet
    local nRowCount = SlotsGameLua.m_nRowCount

    local x = math.floor( nkey / nRowCount ) -- nkey
    local y = nkey % nRowCount -- 0
    local reel = SlotsGameLua.m_listReelLua[x]

    local go = reel.m_listGoSymbol[y]
    local bres, nStickyIndex = reel:isStickyPos(y)
    if bres then
        go = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
    end

    if not bNormalFlag then
        local tempNodes = self:getCollectElemValueNodeGameObject(go) -- 各种节点缓存

        local nPreValue = self.m_mapCollectElemValue[nkey]

        -- if nPreValue < 0 then -- nkey == centerKey 挪到 handleCentElem 里去做了
        --     nPreValue = 0
        --     tempNodes[6]:SetActive(false)
        --     tempNodes[7]:SetActive(false)
        --     tempNodes[1]:SetActive(true)
        -- end
        
        local nCurValue = nPreValue + nTotalBet
        self.m_mapCollectElemValue[nkey] = nCurValue

        local nTempValue = MoneyFormatHelper.normalizeCoinCount(nCurValue, 3)
        local strValue = MoneyFormatHelper.coinCountOmit(nTempValue)

        tempNodes[8].text = strValue
    else
        local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
        SlotsGameLua.m_listDeck[nkey] = nCollectID
        SymbolObjectPool:Unspawn(go)
        
        local symbolNew = SlotsGameLua:GetSymbol(nCollectID)
        local goNew = SymbolObjectPool:Spawn(symbolNew.prfab)

        self:SymbolRectGroupHandler(goNew, x)

        goNew.transform:SetParent(reel.m_transform, false)
        goNew.transform.localScale = Unity.Vector3.one
        goNew.transform.localPosition = reel.m_listSymbolPos[y]

        reel.m_listGoSymbol[y] = goNew
        reel.m_curSymbolIds[y] = nCollectID

        local goGingerman = self.m_mapGoGingermanLogo[goNew]
        if goGingerman ~= nil then
            goGingerman:SetActive(false) -- 不该有gingerman
        end

        local goNodes = self:getCollectElemValueNodeGameObject(goNew) -- 各种节点缓存

        for i=1, 7 do
            goNodes[i]:SetActive(false)
        end
        
        self.m_mapCollectElemValue[nkey] = nTotalBet
        
        local nTempValue = MoneyFormatHelper.normalizeCoinCount(nTotalBet, 3)
        local strValue = MoneyFormatHelper.coinCountOmit(nTempValue)
        
        goNodes[1]:SetActive(true)
        goNodes[8].text = strValue

    end
end

function SweetBlastFunc:stickyCollectElems(listNewCollectElems) -- 仿真不会调用的
    local cnt = #listNewCollectElems
    local nRowCount = SlotsGameLua.m_nRowCount

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    for i = 1, cnt do
        local key = listNewCollectElems[i]
        local x = key -- math.floor(key / nRowCount)
        local y = 0 -- key % nRowCount

        local reel = SlotsGameLua.m_listReelLua[x]

        local goSrcElem = reel.m_listGoSymbol[y]

        -- SymbolCustomHandler 里已经填好这些数值了 不放在固定的时候填了
        -- local value = self.m_mapCollectBallValue[goSrcElem] 
        -- 这个里面的值可能是错的，gingerman元素已经变成1TB了，这里可能还是记录的-6
        -- self.m_mapCollectElemValue[key] = value

        local pos = goSrcElem.transform.position

        local stickySymbol = SlotsGameLua:GetSymbol(nCollectID)
        local goSticky = SymbolObjectPool:Spawn(stickySymbol.prfab)
        
        -- 2020-12-12
        -- self:SymbolRectGroupHandler(goSticky, x)
        self:SetSymbolRectGroup(goSticky, nil)

        -- 元素上显示的信息 修改了与棋盘格子里的一样
        self:modifyGoSticky(goSticky, key)

        --local goSticky = Unity.GameObject.Instantiate(goSrcElem)

        goSticky.transform:SetParent(SlotsGameLua.m_goStickySymbolsDir.transform, false)
        goSticky.transform.localScale = Unity.Vector3.one
        goSticky.transform.position = Unity.Vector3(pos.x, pos.y, pos.z)
        local pos = goSticky.transform.localPosition
        goSticky.transform.localPosition = Unity.Vector3(pos.x, pos.y, 0)

        local stickySymbol = StickySymbol:create(goSticky, nCollectID, y)
        table.insert(reel.m_listStickySymbol, stickySymbol)

        local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[goSticky]
        if clipEffect ~= nil then
            clipEffect.m_animator:Play("CollectElemStickyAni", -1, 0)
        end
    end

    listNewCollectElems = {}
end

function SweetBlastFunc:getCollectElems() -- 仿真不会调用的
    local listNewCollectElems = {} -- 新加进来的 不是固定位置的 对应元素key

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local nRowCount = SlotsGameLua.m_nRowCount
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for y = 0, nRowCount - 1 do
            local nkey = nRowCount * x + y
            local nID = SlotsGameLua.m_listDeck[nkey]
            if nID == nCollectID then
                local bres, nStickyIndex = reel:isStickyPos(y)
                if not bres then
                    table.insert(listNewCollectElems, nkey)
                end
            end
        end
    end

    return listNewCollectElems
end

function SweetBlastFunc:CollectGingerman()
    -- 收集Gingerman
    local nRowCount = SlotsGameLua.m_nRowCount

    local nTotalGingerman = 0
    for k, v in pairs(self.m_mapGingermanNum) do
        local nGingermanNum = v -- 收集个数
        nTotalGingerman = nTotalGingerman + nGingermanNum
        
        -- 飞特效
        SweetBlastLevelUI:FlyGingermanEffect(k, nGingermanNum)

        -- 隐藏元素上的logo
        LeanTween.delayedCall(0.1, function()
            local nRowCount = SlotsGameLua.m_nRowCount
            local x = math.floor(k / nRowCount)
            local y = k % nRowCount
            local reel = SlotsGameLua.m_listReelLua[x]
            local goSymbol = reel.m_listGoSymbol[y]
            local goGingermanLogo = self.m_mapGoGingermanLogo[goSymbol]
            goGingermanLogo:SetActive(false)
        end)
    end
    
    if nTotalGingerman > 0 then
        LeanTween.delayedCall(0.667, function()
            AudioHandler:PlayThemeSound("bonusCollectionFly")
        end)
        LeanTween.delayedCall(1.3, function()
            AudioHandler:PlayThemeSound("target")
        end)
    
        SweetBlastLevelParam:updateCollectAvgBet(nTotalGingerman)

        local nPreCollectNum = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum
        local nTotal = nPreCollectNum + nTotalGingerman
        if nTotal > self.N_COLLECTCOINS_MAX then
            nTotal = self.N_COLLECTCOINS_MAX
        end
        SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = nTotal
        SweetBlastLevelParam:saveParam()
    
        LeanTween.delayedCall(1.5, function()
            SweetBlastLevelUI:refreshCollectNumUI() -- 更新界面显示
        end)
        
        LeanTween.delayedCall(1.3, function()
            SweetBlastLevelUI.m_aniBtnGummyBoard:SetInteger("nPlayMode", 1)
            LeanTween.delayedCall(0.5, function()
                SweetBlastLevelUI.m_aniBtnGummyBoard:SetInteger("nPlayMode", 0)
            end)
        end)

    end
end

function SweetBlastFunc:checkRespinResult() -- precheckwin 里调用。。
    local rt = SlotsGameLua.m_GameResult
    -- 仿真不会来到这里

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()
    local bTrigerRespinFlag = false
    SweetBlastLevelUI.m_bInReSpin = bReSpinFlag

    local ftime = 0

    if not bReSpinFlag then
        bTrigerRespinFlag = self:isTriggerRespin(SlotsGameLua.m_listDeck)
        if bTrigerRespinFlag then
            SweetBlastLevelUI.m_bPlayItAgainRespin = false
            SweetBlastLevelUI.m_bInReSpin = true
            
            AudioHandler:PlayThemeSound("respin_triggered")

            SlotsGameLua.m_bSplashFlags[SplashType.ReSpin] = true
            ftime = 1.0

            rt.m_nReSpinCount = 0
            rt.m_nReSpinTotalCount = 3

            SweetBlastLevelUI:updateRespinCountInfo(3, false) -- 还剩下几次

        else
            --这种情况就返回等待调用 SlotsGameLua:CheckWinEnd() 就行了
            return
        end
    end

    if bTrigerRespinFlag then
        -- 2020-12-12 等转场动画之后再去处理固定元素的事
        return
    end

    -- 检查固定元素等等..
    local listNewCollectElems = {} -- 新加进来的 不是固定位置的 对应元素key
    local listNewCollectElems = self:getCollectElems() -- 有新收集元素加进来就固定...
    local bHasNewCollectElem = false
    if #listNewCollectElems > 0 then
        bHasNewCollectElem = true

        self.m_bCollectFullFlag = self:isCollectFull(listNewCollectElems)

        LeanTween.delayedCall(0.1, function()
                self:stickyCollectElems(listNewCollectElems)
            end)
    end

    if bHasNewCollectElem and not bTrigerRespinFlag then
        if self.m_bCollectFullFlag then
            rt.m_nReSpinCount = 3 -- 不要更新界面显示 但是要让respin逻辑结束了
            rt.m_nReSpinTotalCount = 3
        else
            rt.m_nReSpinCount = 0
            rt.m_nReSpinTotalCount = 3
            
            AudioHandler:PlayRespinReset()

            SweetBlastLevelUI:updateRespinCountInfo(3, false) -- 还剩下几次
        end

        ftime = ftime + 0.5
    end

    local nType = 0 -- 
    if rt.m_nReSpinCount == rt.m_nReSpinTotalCount then

        SlotsGameLua.m_bSplashFlags[SplashType.ReSpinEnd] = true

        SceneSlotGame:ButtonEnable(false)
        SceneSlotGame.m_btnSpin.interactable = false -- 按钮灰掉。。

        local fRespinCoins = self:getRespinWinCoins()
        if not self.m_bPlayItAgainFlag then
            SweetBlastLevelUI.m_bInReSpin = false
            nType = 1
        else
            nType = 2
        end
        
        if self.m_bCollectFullFlag then
            self.m_bCollectFullFlag = false
            local fGrandValue = self:getElemCoins( self.CollectValueType.GrandType ) -- grand奖励
            fRespinCoins = fRespinCoins + fGrandValue
            Debug.Log("----------------fGrandValue: " .. MoneyFormatHelper.numWithCommas(fGrandValue))
            self.m_bGrandPrizeFlag = true -- 弹窗的时候需要用到。。
            -- 播放一个特效 在GrandJackpotEffect区域
            -- getElemCoins 里播放了
            -- SweetBlastLevelUI.m_listGoJackpotEffect[4]:SetActive(true)
        end

        Debug.Log("------fRespinCoins----: " .. MoneyFormatHelper.numWithCommas(fRespinCoins))

        -- m_bPlayItAgainFlag 也在里面初始化了..
        self.m_fRespinWinCoins = fRespinCoins

        -- 各种结算动画等要处理收到 ReSpinEnd 消息时候再做了。。
        -- SweetBlastLevelUI:handleReSpinEnd() 在这里播放各种动画。。

        ftime = ftime + 0.5
    end
    --

    SweetBlastLevelUI:setDBReSpin(nType)

end

function SweetBlastFunc:PreCheckWin()
    local rt = SlotsGameLua.m_GameResult
    -- 仿真不会来到这里

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()
    if not bFreeSpinFlag and not bReSpinFlag then
        -- 收集Gingerman
        self:CollectGingerman()
    end

    local ftime = 0

    -- Respin期间 特殊元素逻辑2个AddAdjacent 
    -- 不固定 只替换盘面元素 修改deck表等 以及修改 m_mapCollectElemValue
    local ftime1 = self:AddAdjacentElemsHandler()

    LeanTween.delayedCall(ftime1, function()
        self:checkRespinResult() -- 检查是否触发。。固定元素 重置 是否结束。。结束了要算结果。。等等。。
    end)
    
    LeanTween.delayedCall(ftime + ftime1, function()
        SlotsGameLua:CheckWinEnd()
    end)
    
end

function SweetBlastFunc:getRespinWinCoins()
    -- 返回赢得的金币数 --和 是否触发了play it again  -- m_bPlayItAgainFlag
    local fRespinCoins = 0

    self.m_bPlayItAgainFlag = false
    
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[i]
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local key = i * SlotsGameLua.m_nRowCount + j
            local bStickyFlag, nStickyIndex = reel:isStickyPos(j)
            if bStickyFlag then
                --local go = reel.m_listStickySymbol[nStickyIndex].m_goSymbol

                local value = self.m_mapCollectElemValue[key]
                if value == self.CollectValueType.PlayItAgainType then
                    self.m_bPlayItAgainFlag = true -- 一次respin最多只会出一个这种元素。。

                    self.m_goPlayItAgainStickyElem = reel.m_listStickySymbol[nStickyIndex].m_goSymbol

                elseif value == self.CollectValueType.AddAllAdjacentsType then

                elseif value == self.CollectValueType.AddAnAdjacentType then

                else
                    local nCoins = self:getElemCoins(value)
                    fRespinCoins = fRespinCoins + nCoins

                    -- Debug.Log("-------nCoins: " .. nCoins .. "-----value: " .. value)
                end
            end
        end
    end

    Debug.Log("---end----fRespinCoins: " .. fRespinCoins)

    return fRespinCoins
end

function SweetBlastFunc:getElemCoins(value)
    local nCoins = 0
    if value == nil then
        return 0
    end
    if value > 0 then
        nCoins = value
        return nCoins
    end

    local nTotalbet = SceneSlotGame.m_nTotalBet

    if value == self.CollectValueType.MiniType then
        local fBase = nTotalbet * SweetBlastLevelUI.m_listJackpotBaseCoef[1]
        local fValue = SweetBlastLevelParam.m_listJackpotValue[1]
        nCoins = fBase + fValue


        SweetBlastLevelUI.m_listGoJackpotEffect[1]:SetActive(true)
        self.m_bResetMiniJackpot = true
    elseif value == self.CollectValueType.MinorType then
        local fBase = nTotalbet * SweetBlastLevelUI.m_listJackpotBaseCoef[2]
        local fValue = SweetBlastLevelParam.m_listJackpotValue[2]
        nCoins = fBase + fValue

        SweetBlastLevelUI.m_listGoJackpotEffect[2]:SetActive(true)
        self.m_bResetMinorJackpot = true
    elseif value == self.CollectValueType.MajorType then
        local fBase = nTotalbet * SweetBlastLevelUI.m_listJackpotBaseCoef[3]
        local fValue = SweetBlastLevelParam.m_listJackpotValue[3]
        nCoins = fBase + fValue

        SweetBlastLevelUI.m_listGoJackpotEffect[3]:SetActive(true)
        self.m_bResetMajorJackpot = true

    elseif value == self.CollectValueType.GrandType then -- 收集满的时候领取grand 平常掉落元素上不会有
        local fBase = nTotalbet * SweetBlastLevelUI.m_listJackpotBaseCoef[4]
        local fValue = SweetBlastLevelParam.m_listJackpotValue[4]
        nCoins = fBase + fValue

        SweetBlastLevelUI.m_listGoJackpotEffect[4]:SetActive(true)
        self.m_bResetGrandJackpot = true
    else -- 收集满的时候领取grand 平常掉落元素上不会有
        
    end

    return nCoins
end

function SweetBlastFunc:CheckSpinWinPayLines(deck, result)
    result:ResetSpin()
    
    local bInReSpinFlag = result:InReSpin()
    local bHasReSpinFlag = result:HasReSpin()
    if bInReSpinFlag then
        if not bHasReSpinFlag then
            result.m_fNonLineBonusWin = self.m_fRespinWinCoins
        -- 填result表 -- 奖励先加给玩家 动画慢慢做
        end

        return result
    end

    -- 仿真下的respin单独处理啊。。

    local nWildID = SlotsGameLua:GetSymbolIdByObjName("WILD1")

    for i = 1, #SlotsGameLua.m_listLineLua do
        local iResult = {}
        local ld = SlotsGameLua:GetLine(i)
        for x = 0, 4 do
            local y = ld.Slots[x]
            local key = 4 * x + 3-y -- 这关的deck key与reelID是一样的
            iResult[x] = deck[key]
        end

        local nMaxMatchReelID = 0
        local MatchCount = 0
        local bFirstSymbol = false
        local SymbolIdx = -1
        for x = 0, 4 do
            local bNormalFlag = SlotsGameLua:GetSymbol(iResult[x]):IsNormalSymbol()
            if not bFirstSymbol then
                if not self:IsWild(iResult[x]) then
                    if (not bNormalFlag) and (MatchCount > 0) then -- 这是遇到scatter牌了
                        break
                    end
                    SymbolIdx = iResult[x]
                    bFirstSymbol = true
                end

                MatchCount = MatchCount + 1
                nMaxMatchReelID = x
            else
                local curSymbol = SlotsGameLua:GetSymbol(SymbolIdx)
                bNormalFlag = curSymbol:IsNormalSymbol()

                local bSameKindSymbolFlag = false
                bSameKindSymbolFlag = self:isSamekindSymbol(SymbolIdx, iResult[x])
                if bSameKindSymbolFlag or (self:IsWild(iResult[x]) and bNormalFlag) then
                    MatchCount = MatchCount + 1

                    nMaxMatchReelID = x
                else
                    break
                end
            end
        end
        if MatchCount >= 1 then
            local bcond1 = false
            local bcond2 = false
            local bcond3 = false

            local nCombIndex = -1
            local sd = nil
            local fCombReward = 0.0
            if SymbolIdx == -1 then
                sd = SlotsGameLua:GetSymbol(nWildID)
                fCombReward = sd.m_fRewards[MatchCount]
                bcond1 = true
                SymbolIdx = nWildID
            else
                sd = SlotsGameLua:GetSymbol(SymbolIdx)
                if sd.type == SymbolType.Normal or sd.type == SymbolType.NormalDouble or sd.type > 100 then
                    fCombReward = sd.m_fRewards[MatchCount]
                    bcond3 = true
                end
            end

            if fCombReward > 0 then
                self.m_nWin0Count = 0

                if not self.m_bSimulationFlag then
                    -- 哪根线的哪几个元素中奖了 记录下来
                    --m_listHitSymbols
                    self:refreshHitSymbols(i, MatchCount)
                end
                --

                local fLineBet = SceneSlotGame.m_nTotalBet / 100 -- #SlotsGameLua.m_listLineLua
                local LineWin = fCombReward * fLineBet

                table.insert(
                    result.m_listWins,
                    WinItem:create(i, SymbolIdx, MatchCount, LineWin, bcond2, nMaxMatchReelID)
                )
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if self.m_bSimulationFlag then
                    if result.m_listTestWinSymbols[SymbolIdx] == nil then
                        result.m_listTestWinSymbols[SymbolIdx] = TestWinItem:create(SymbolIdx)
                    end

                    result.m_listTestWinSymbols[SymbolIdx].Hit = result.m_listTestWinSymbols[SymbolIdx].Hit + 1
                    result.m_listTestWinSymbols[SymbolIdx].WinGold =
                        result.m_listTestWinSymbols[SymbolIdx].WinGold + LineWin
                end
            else
            end
        end
    end

    result.m_fGameWin = result.m_fGameWin + result.m_fNonLineBonusWin
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin

    local nLevelType = SlotsGameLua.m_enumLevelType
    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fSpinWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fNonLineBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fNonLineBonusWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fJackPotBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fJackPotBonusWin
    end
    
    local bTriggerFlag = self:isTriggerBonusGame(deck)
    if bTriggerFlag then
        if not self.m_bSimulationFlag then
            self.m_bTriggerBonusGameFlag = true
            SlotsGameLua.m_bSplashFlags[SplashType.Bonus] = true
            SweetBlastLevelParam:setBonusGameBetByType(1)
        end
    end

    return result
end

function SweetBlastFunc:isSamekindSymbol(SymbolIdx, nResultId)
    local bWildFlag1 = self:IsWild(SymbolIdx)
    local bWildFlag2 = self:IsWild(nResultId)

    if bWildFlag1 or bWildFlag2 then
        return true
    end

    if SymbolIdx == nResultId then
        return true
    end

    return false
end

-- 哪根线的哪几个元素中奖了 记录下来
--m_listHitSymbols
function SweetBlastFunc:refreshHitSymbols(nLineId, MatchCount)
    local nMaxMatchId = MatchCount - 1
    local nRowCount = 4 -- SlotsGameLua.m_nRowCount
    for x = 0, 4 do
        if x <= nMaxMatchId then
            local y = SlotsGameLua:GetLine(nLineId).Slots[x]
            local nkey = nRowCount * x + 3-y -- key 与 reelID 一样

            local bflag = LuaHelper.tableContainsElement(self.m_listHitSymbols, nkey)
            if not bflag then
                table.insert(self.m_listHitSymbols, nkey)
            end
        end
    end
end

function SweetBlastFunc:isStopReel(nReelID) -- 还有固定了一个占多格的大元素的reel ...
    local rt = SlotsGameLua.m_GameResult
    if not rt:InReSpin() then
        return false
    end

    local reel = SlotsGameLua.m_listReelLua[nReelID]
    
    local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
    if bStickyFlag then
        return true
    end

    return false
end

function SweetBlastFunc:isNeedPlayReelStopSound(nReelID)
    local bres = self:isStopReel(nReelID)
    if bres then
        return false
    end

    return true
end

function SweetBlastFunc:initGingermanLogo(nReelID, nRowIndex, bResultDeck, nDeckKey)
    if #self.m_listGingermanLogoElemKeys == 0 then
        return
    end

    local flag = LuaHelper.tableContainsElement(self.m_listGingermanLogoElemKeys, nDeckKey)
    if not flag then
        return
    end
    -- 一定比例的元素上有 Gingerman

    local reel = SlotsGameLua.m_listReelLua[nReelID]
    local go = reel.m_listGoSymbol[nRowIndex]
    local nSymbolID = reel.m_curSymbolIds[nRowIndex]

    local strName = "GingermanLogo"
    local nGingermanLogoID = SlotsGameLua:GetSymbolIdByObjName(strName)
    if self.m_mapGoGingermanLogo[go] == nil then
        local symbolGingerman = SlotsGameLua:GetSymbol(nGingermanLogoID)
        local goGingerman = SymbolObjectPool:Spawn(symbolGingerman.prfab)
        self:SymbolRectGroupHandler(goGingerman, nReelID)
        goGingerman.transform:SetParent(go.transform, false)
        goGingerman.transform.localScale = Unity.Vector3.one
        goGingerman.transform.localPosition = Unity.Vector3.zero

        -- goGingerman:SetActive(true)

        local textMeshProGingermanNum = goGingerman:GetComponentInChildren(typeof(Unity.TextMesh))
        self.m_mapGoGingermanLogo[go] = goGingerman
        self.m_mapTextMeshProGingermanNum[go] = textMeshProGingermanNum
    end

    local nGingermanNum = self:getGingermanNum()
    self.m_mapTextMeshProGingermanNum[go].text = nGingermanNum

    if bResultDeck then -- 每次进来都要初始化的
        self.m_mapGingermanNum[nDeckKey] = nGingermanNum
    end

    self.m_mapGoGingermanLogo[go]:SetActive(true)
end

-- 滚动过程中加到棋盘的元素 从缓存里取出就会调用一下这个
function SweetBlastFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
    local go = reel.m_listGoSymbol[nRowIndex]

    self:SymbolRectGroupHandler(go, nReelID) -- 这是 BaseGame 的情况

    local nSymbolID = reel.m_curSymbolIds[nRowIndex]

    local goGingerman = self.m_mapGoGingermanLogo[go]
    if goGingerman ~= nil then
        goGingerman:SetActive(false) -- 不一定每个元素都需要有gingerman 所以先隐藏掉
    end

    local rt = SlotsGameLua.m_GameResult
    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()
    if not bFreeSpinFlag and not bReSpinFlag then
        -- 1. 任意元素刚加入的时候都需要检查有没有gingerman节点 以及 初始化上面的数值
        self:initGingermanLogo(nReelID, nRowIndex, bResultDeck, nDeckKey)
        -- GingermanLogo   -- TextMeshProGingermanNum
    end

    -- 2. 收集元素魔法球刚加入棋盘的时候。。
    -- 收集元素 球 上的数值。。或者 mini minor major标记。。
    -- -1 mini  -2 minor  -3 major -4 play it again -5 AddAllAdjacentsType -6 AddAnAdjacent

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    if nSymbolID ~= nCollectID then
        return
    end

    local value = self:getCollectElemValue(bResultDeck)

    local bStickyFlag = false
    local nStickyIndex = 0
    if bResultDeck then
        -- 在列没有停下来之前 nRowIndex 不能用来判断是否有固定元素，此时这个范围是0--7

        local y = nDeckKey % SlotsGameLua.m_nRowCount

        bStickyFlag, nStickyIndex = reel:isStickyPos(y) -- nRowIndex
        if bStickyFlag then -- 已经固定的...
            value = self.m_mapCollectElemValue[nDeckKey]
        else
            self.m_mapCollectElemValue[nDeckKey] = value
        end
    end

    if bResultDeck and value == self.CollectValueType.PlayItAgainType then
        -- 已经固定了的不要下面的重复判断了
        if not bStickyFlag then
            if self.m_bHasPlayItAgain then -- 保证 playitagain 最多只会出一个
                value = 1 * SceneSlotGame.m_nTotalBet -- 已经有了 就把多的替换成 1TB ...
                self.m_mapCollectElemValue[nDeckKey] = value
            else
                self.m_bHasPlayItAgain = true
            end
        end
    end

    --
    local goNodes = self:getCollectElemValueNodeGameObject(go)
    for i = 1, 7 do
        goNodes[i]:SetActive(false)
    end

    if value == self.CollectValueType.MiniType then
        goNodes[2]:SetActive(true)
    elseif value == self.CollectValueType.MinorType then
        goNodes[3]:SetActive(true)
    elseif value == self.CollectValueType.MajorType then
        goNodes[4]:SetActive(true)
    elseif value == self.CollectValueType.PlayItAgainType then
        goNodes[5]:SetActive(true)
    elseif value == self.CollectValueType.AddAllAdjacentsType then
        goNodes[6]:SetActive(true)
    elseif value == self.CollectValueType.AddAnAdjacentType then
        goNodes[7]:SetActive(true)
    elseif value > 0 then
        goNodes[1]:SetActive(true)
        local nTempValue = MoneyFormatHelper.normalizeCoinCount(value, 3)
        value = nTempValue
        local strValue = MoneyFormatHelper.coinCountOmit(nTempValue)
        goNodes[8].text = strValue
    end
    
    --
    self.m_mapCollectBallValue[go] = value -- 包括最终结果以及滚动过程中的元素
    
    -- self.m_mapCollectElemValue[nDeckKey] = value
    -- 只有最终结果。。 在上面 bResultDeck 为true的情况处理了
end

function SweetBlastFunc:getCollectElemValueNodeGameObject(go)
    if self.m_mapGoValueNode[go] == nil then
        -- 查找了缓存起来
        local goCoinsValue = go.transform:FindDeepChild("TextMeshProCoinsValue").gameObject
        local textCoinsValue = goCoinsValue:GetComponent(typeof(Unity.TextMesh))

        local goMINI = go.transform:FindDeepChild("MINI").gameObject
        local goMINOR = go.transform:FindDeepChild("MINOR").gameObject
        local goMAJOR = go.transform:FindDeepChild("MAJOR").gameObject
        local goPlayItAgain = go.transform:FindDeepChild("PlayItAgain").gameObject
        local goAddAllAdjacents = go.transform:FindDeepChild("AddAllAdjacents").gameObject
        local goAddAnAdjacent = go.transform:FindDeepChild("AddOneAdjacent").gameObject

        goAddAnAdjacent.transform.localScale = Unity.Vector3.one
        goAddAnAdjacent.transform.localPosition = Unity.Vector3(0, 0, -5)
        
        local temp = {goCoinsValue, goMINI, goMINOR, goMAJOR, goPlayItAgain, 
                    goAddAllAdjacents, goAddAnAdjacent, textCoinsValue}
                    
        self.m_mapGoValueNode[go] = temp -- 运行时收集元素上的数字
    end
    
    local goNodes = self.m_mapGoValueNode[go]

    return goNodes
end

-- respin中jackpot的概率等..
function SweetBlastFunc:getCollectElemValue(bResultDeck)
    local value = 0
    if bResultDeck then -- 按概率来
        local fProb = math.random()
        if fProb < 0.04 then
            value = self.CollectValueType.MiniType
        elseif fProb < 0.05 then
            value = self.CollectValueType.MinorType
        elseif fProb < 0.052 then
            value = self.CollectValueType.MajorType
        elseif fProb < 0.06 then
            value = self.CollectValueType.PlayItAgainType -- 只会出一个
        elseif fProb < 0.07 then
            value = self.CollectValueType.AddAllAdjacentsType -- 周围8个。。
        elseif fProb < 0.12 then
            value = self.CollectValueType.AddAnAdjacentType -- 周围1个。。
        else
            local listProbs = {200, 300, 200, 100, 100, 75, 75, 25, 25, 25, 25, 10, 10, 5, 3, 2}
            local nIndex = LuaHelper.GetIndexByRate(listProbs)
            local fCoef = self.m_listCollectElemCoinCoefs[nIndex]
            if fCoef == nil then
                fCoef = 1.0
            end
            value = fCoef -- totalbet 的倍数
        end

        if SweetBlastCustomDeck.m_bRespinTest then
            if fProb < 0.015 and not self.m_bHasPlayItAgain then
                value = self.CollectValueType.PlayItAgainType
            elseif fProb < 0.05 then
                value = self.CollectValueType.AddAllAdjacentsType
            elseif fProb < 0.25 then
                value = self.CollectValueType.AddAnAdjacentType -- 周围1个。。
            end
        end

    else
        -- 多出一些牛叉的...
        local fProb = math.random()
        if fProb < 0.1 then
            value = self.CollectValueType.MiniType
        elseif fProb < 0.2 then
            value = self.CollectValueType.MinorType
        elseif fProb < 0.3 then
            value = self.CollectValueType.MajorType
        elseif fProb < 0.4 then
            value = self.CollectValueType.PlayItAgainType
        elseif fProb < 0.5 then
            value = self.CollectValueType.AddAllAdjacentsType
        elseif fProb < 0.6 then
            value = self.CollectValueType.AddAnAdjacentType
        else
            local listProbs = {10, 20, 20, 10, 75, 75, 75, 50, 50, 50, 25, 25, 25, 5, 5, 5}
            local nIndex = LuaHelper.GetIndexByRate(listProbs)
            local fCoef = self.m_listCollectElemCoinCoefs[nIndex]
            value = fCoef -- totalbet 的倍数
        end
    end
    
    if value > 0 then
        value = value * SceneSlotGame.m_nTotalBet
    end

    return value
end

--仿真，把结果 输入到文本文件中
function SweetBlastFunc:Simulation()
    self.m_bSimulationFlag = true

    Unity.Random.InitState(TimeHandler:GetServerTimeStamp())

    SweetBlastSimulation:GetTestResultByRate()
    SweetBlastSimulation:WriteToFile()

    self.m_bSimulationFlag = false
end

--

function SweetBlastFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = SweetBlastLevelUI
end

--

function SweetBlastFunc:getReelRotateDistance(nReelId)
    local distance = 1500.0
    SlotsGameLua.m_fRotateDistance = distance
    -- local nFakeReelId = nReelId % 4

    if nReelId == 0 then
        return distance
    else
        return 0
    end
end

function SweetBlastFunc:UpdateReelRunStop(dt)
    if SlotsGameLua.m_nActiveReel == -1 then
        SlotsGameLua.m_fSpinAge = SlotsGameLua.m_fSpinAge + dt
        if SlotsGameLua.m_fSpinAge > 0.5 then -- spin开始后0.5s可以允许停
            SlotsGameLua.m_nActiveReel = 0
            SlotsGameLua:ApplyResult()
            SlotsGameLua.m_listReelLua[SlotsGameLua.m_nActiveReel]:Stop()
            
            SceneSlotGame:OnSpinToStop()
            SlotsGameLua.m_fSpinAge = 0.0

            self.m_bStopAll = false
        end
    else
        local nMaxReelID = SlotsGameLua.m_nReelCount-1
        
        if SlotsGameLua.m_nActiveReel <= nMaxReelID and SlotsGameLua.m_listReelLua[SlotsGameLua.m_nActiveReel]:Completed() then
            SceneSlotGame:OnReelStop(SlotsGameLua.m_nActiveReel)
            --check next reel
            SlotsGameLua.m_nActiveReel = SlotsGameLua.m_nActiveReel + 1
            --if all Reels stopped.
            if SlotsGameLua.m_nActiveReel > nMaxReelID then
                SlotsGameLua:PreCheckWin()
            else
                SlotsGameLua.m_listReelLua[SlotsGameLua.m_nActiveReel]:Stop()
            end
        end
    end
end

-- 2020-10-27
function SweetBlastFunc:IsWild(nSymbolID)
    if nSymbolID == 11 or nSymbolID == 15 or nSymbolID == 16 then
        return true
    end

    return false
end