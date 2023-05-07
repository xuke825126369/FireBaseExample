require "Lua/ThemeVideo/FortunesOfGold/FortunesOfGoldLevelUI"
require "Lua/ThemeVideo/FortunesOfGold/FortunesOfGoldCustomDeck"
require "Lua/ThemeVideo/FortunesOfGold/FortunesOfGoldSymbol"
require "Lua/ThemeVideo/FortunesOfGold/FortunesOfGoldConfig"

FortunesOfGoldFunc = {}
FortunesOfGoldFunc.m_listReel2Deck2 = {} -- 中间列的3个格子里的上面那个元素 从下往上0 1 2的顺序

---以下3个都是从0开始。。。元素索引从下往上012345.。。
FortunesOfGoldFunc.m_listSymbolPos = {} --// Vector3[]  m_nReelRow+ m_nAddSymbolNums
FortunesOfGoldFunc.m_listGoSymbol = {}  --// GameObject[] m_nReelRow+ m_nAddSymbolNums ---运行时参数
FortunesOfGoldFunc.m_curSymbolIds = {} --比FinalValues记录的多 m_nReelRow+m_nAddSymbolNums

FortunesOfGoldFunc.m_listOutSideSymbols = {} --List<GameObject>() --- 从1开始。。。
FortunesOfGoldFunc.m_nOutSideCount = 1 --移除棋盘外的还保留几个。。由大元素占几个格子来决定  编辑关卡时候事先编辑好

-- 中奖线上是元素2的情况...
FortunesOfGoldFunc.m_listWins2 = {} ---从1开始数组  类似 SlotsGameLua.m_GameResult.m_listWins
FortunesOfGoldFunc.m_listScatterKey = {} -- 中间列的每个格子上方的三个元素的key: 106, 107, 108

-----------------------
FortunesOfGoldFunc.m_bSimulationFlag = false
FortunesOfGoldFunc.m_nSimulationCount = 0 -- 仿真统计专用
FortunesOfGoldFunc.m_nSimulationFreeSpinLess16Num = 0 -- 玩家获得freespin小于16次的次数统计
FortunesOfGoldFunc.m_nSimulationFreeSpinLarge100Num = 0 -- 玩家获得freespin超过100次的次数统计
------------------------

FortunesOfGoldFunc.m_bGetDeckFunc2Flag = true -- 用第二种方法来获取最后的结果列表 2018-6-27
FortunesOfGoldFunc.m_nWin0Count = 0 -- 统计多少把没中奖了
FortunesOfGoldFunc.m_nFreeSpinTriggerFreq = 0 -- 仿真下统计一共触发了多少回freespin

function FortunesOfGoldFunc:showSpineFrame0(bShowFrame0)
    for x=0, SlotsGameLua.m_nReelCount-1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        local nRowCount = reel.m_nReelRow
		for y=0, nRowCount-1 do
        --    local nKey = SlotsGameLua.m_nRowCount * x + y

            local goSymbol = nil
            local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
            if bStickyFlag then
                goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
            else
                goSymbol = reel.m_listGoSymbol[y]
            end
            
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
                --    goFrame0:SetActive(false) -- 静帧不隐藏了。。。一直处于显示状态。。
                end

            end
        end

    end
end

function FortunesOfGoldFunc:OnStartSpin()
    self:showSpineFrame0(true)
    self.m_listWins2 = {}
end

function FortunesOfGoldFunc:OnSpinEnd()
    self:showSpineFrame0(false)
end

function FortunesOfGoldFunc:GetDeck2() -- 尝试另一种思路 最终结果从一个事先生成的列表去取
    self.m_nWin0Count = self.m_nWin0Count + 1 -- 统计多少把连续不中奖的变量
    local deck = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            deck[nKey] = SlotsGameLua.m_randomChoices:ChoiceSymbolId(i)
        end
    end
    
    self.m_listReel2Deck2 = {}
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(2)
        self.m_listReel2Deck2[i] = nSymbolID
    end

    FortunesOfGoldCustomDeck:ModifyCustomDeck(deck)
    self:ModifyTestDeck(deck)
    self.preDeck = LuaHelper.DeepCloneTable(deck)
    return deck
end

function FortunesOfGoldFunc:GetDeck()
    if self.m_bGetDeckFunc2Flag then
        return self:GetDeck2()
    end
    Debug.Assert(false)
end

function FortunesOfGoldFunc:ModifyTestDeck(deck) -- 调试的时候自己修改数据用
    if self.m_bSimulationFlag then
        return
    end

    if not GameConfig.Instance.m_nThemeTestType then
        return
    end
    
    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild") 
    -- 模拟测试如何生存不同freespin次数的盘面
    -- for i=0, 14 do
    --     deck[i] = math.random(1, 10)
    -- end
    -- for i=0, 2 do
    --     self.m_listReel2Deck2[i] = math.random(1, 10)
    -- end

    -- local nSum = 0
    -- for var=1, 100 do
    --     FortunesOfGoldCustomDeck:ModifyFreeSpin25Deck(deck)

    --     local nFreeSpinNum = self:GetFreeSpinNum(deck)
    --     nSum = nSum + nFreeSpinNum

    --     for i=0, 14 do
    --         deck[i] = math.random(1, 10)
    --     end
    --     for i=0, 2 do
    --         self.m_listReel2Deck2[i] = math.random(1, 10)
    --     end
    -- end

    -- Debug.Log("------------nAvgFreeSpinNum: " .. nSum/100)
    local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    local bHasFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()

    if self.m_nThemeTestType == 1 then
    
        deck[0] = 8
        deck[1] = 8
        deck[2] = nScatterID
        deck[3] = nWildID
        deck[4] = nWildID
        deck[5] = nWildID
    
        deck[6] = 9
        deck[7] = 10
        deck[8] = 5

        self.m_listReel2Deck2[0] = 1
        self.m_listReel2Deck2[1] = 2
        self.m_listReel2Deck2[2] = nWildID
        
        deck[9] = 9
        deck[10] = nScatterID
        deck[11] = nWildID

        deck[12] = nWildID
        deck[13] = 6
        deck[14] = 6
    
    end

    if self.m_nThemeTestType == 2 then
        deck[0] = nScatterID
        deck[3] = nWildID
        deck[6] = nWildID

        deck[1] = nScatterID
        deck[2] = nScatterID
        deck[4] = nScatterID
        deck[5] = nScatterID

        deck[7] = 3
        deck[8] = 3

        self.m_listReel2Deck2[0] = nWildID
        self.m_listReel2Deck2[1] = nWildID
        self.m_listReel2Deck2[2] = 1

        deck[9] = 2
        deck[10] = 2
        deck[11] = 2

        deck[12] = 3
        deck[13] = 3
        deck[14] = 3
    end
end

function FortunesOfGoldFunc:CreateReelRandomSymbolList()
    local nTotal = 100
    for i = 1, nTotal do
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            if SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID == nil then
                SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
            end

            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

end

function FortunesOfGoldFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function FortunesOfGoldFunc:CheckSpinWinPayLines(deck, result)
    result:ResetSpin()

    for k, v in pairs(deck) do
        Debug.Assert(self.preDeck[k] == v)
    end 

    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")
    for i = 1, #SlotsGameLua.m_listLineLua do
        local listResults = {{},{}}
        local ld = SlotsGameLua:GetLine(i)
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local y = ld.Slots[x]
            local nKey = SlotsGameLua.m_nRowCount * x + y
            listResults[1][x] = deck[nKey]
            listResults[2][x] = deck[nKey]
            if x == 2 then
                listResults[2][x] = self.m_listReel2Deck2[y]
            end
        end

        for y = 1, 2 do
            local nMaxMatchReelID = 0
            local MatchCount = 0
            local bFirstSymbol = false
            local SymbolIdx = -1
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                local nSymbolId = listResults[y][x]
                if not bFirstSymbol then
                    if not FortunesOfGoldSymbol:isWildSymbol(nSymbolId) then
                        SymbolIdx = nSymbolId
                        bFirstSymbol = true
                    end
                end

                if self:isSamekindSymbol(SymbolIdx, nSymbolId) then
                    MatchCount = MatchCount + 1
                    nMaxMatchReelID = x
                else
                    break
                end
            end

            if MatchCount >= 3 then
                local fCombReward = 0.0
                local sd = SlotsGameLua:GetSymbol(SymbolIdx)
                fCombReward = sd.m_fRewards[MatchCount]

                if fCombReward > 0 then
                    self.m_nWin0Count = 0 -- 统计多少把连续不中奖的变量

                    local fLineBet = SceneSlotGame.m_nTotalBet / #SlotsGameLua.m_listLineLua
                    local LineWin = fCombReward * fLineBet

                    local item = WinItem:create(i, SymbolIdx, MatchCount, LineWin, false, nMaxMatchReelID)
                    if y == 1 then
                        table.insert(result.m_listWins, item)
                    else
                        table.insert(self.m_listWins2, item)
                    end

                    result.m_fSpinWin = result.m_fSpinWin + LineWin
                    if self.m_bSimulationFlag then
                        if result.m_listTestWinSymbols[SymbolIdx] == nil then
                            result.m_listTestWinSymbols[SymbolIdx] = TestWinItem:create(SymbolIdx)
                        end
                        result.m_listTestWinSymbols[SymbolIdx].Hit = result.m_listTestWinSymbols[SymbolIdx].Hit + 1
                        result.m_listTestWinSymbols[SymbolIdx].WinGold = result.m_listTestWinSymbols[SymbolIdx].WinGold + LineWin
                    end
                end
            end
        end
    end

    if result:InFreeSpin() then
        result.m_fSpinWin = result.m_fSpinWin * 2.0
    end

    local nNewFreeSpinCount = self:GetFreeSpinNum(deck)
    local bSimuFreeSpinToCoinPrizeFlag = false

    if nNewFreeSpinCount > 0 then
        self.m_nFreeSpinTriggerFreq = self.m_nFreeSpinTriggerFreq + 1
        self.m_nWin0Count = 0

        result.m_nNewFreeSpinCount = nNewFreeSpinCount
        result.m_nFreeSpinAccumCount = result.m_nFreeSpinAccumCount + result.m_nNewFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + result.m_nNewFreeSpinCount

        if self.m_bSimulationFlag then
            if nNewFreeSpinCount > 99 then
                self.m_nSimulationFreeSpinLarge100Num = self.m_nSimulationFreeSpinLarge100Num + 1
            elseif nNewFreeSpinCount < 16 then
                self.m_nSimulationFreeSpinLess16Num = self.m_nSimulationFreeSpinLess16Num + 1
            end
        end
    end

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    result.m_fGameWin = result.m_fGameWin + result.m_fNonLineBonusWin
    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fSpinWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fNonLineBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fNonLineBonusWin
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fJackPotBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fJackPotBonusWin
    end

    return result
end

function FortunesOfGoldFunc:isSamekindSymbol(SymbolIdx, nResultId)
    if FortunesOfGoldSymbol:isWildSymbol(nResultId) then
        return true
    end

    if SymbolIdx == nResultId then
        return true
    end

    return false
end

function FortunesOfGoldFunc:GetFreeSpinNum(deck)
    local FreeSpinCount = {0, 0}
    self.m_listScatterKey = {}

    for i = 1, #SlotsGameLua.m_listLineLua do
        local listResults = {{}, {}}
        local ld = SlotsGameLua:GetLine(i)
        for x=0, SlotsGameLua.m_nReelCount-1 do
            local y = ld.Slots[x]
            local nKey = SlotsGameLua.m_nRowCount * x + y
            listResults[1][x] = deck[ nKey ]
            if x == 2 then
                listResults[2][x] = self.m_listReel2Deck2[y]
            else
                listResults[2][x] = deck[ nKey ]
            end
        end

        local ScatterCount = {0, 0} 
        for i = 1, 2 do
            local bMidElemNormal = FortunesOfGoldSymbol:isCommonSymbolId(listResults[i][2])
            if not bMidElemNormal then
                for x = 0, SlotsGameLua.m_nReelCount - 1 do
                    local bNormalSymbol = FortunesOfGoldSymbol:isCommonSymbolId(listResults[i][x])
                    if not bNormalSymbol then
                        ScatterCount[i] = ScatterCount[i] + 1

                        local nScatterKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
                        if i == 2 and x == 2 then
                            nScatterKey = 106 + ld.Slots[2]
                        end

                        local bFlag = LuaHelper.tableContainsElement(self.m_listScatterKey, nScatterKey)
                        if not bFlag then
                            table.insert( self.m_listScatterKey, nScatterKey )
                        end

                    else
                        break
                    end
                end
                if ScatterCount[i] == 3 then
                    FreeSpinCount[i] = FreeSpinCount[i] + 8
                elseif ScatterCount[i] == 4 then
                    FreeSpinCount[i] = FreeSpinCount[i] + 10
                elseif ScatterCount[i] == 5 then
                    FreeSpinCount[i] = FreeSpinCount[i] + 15
                end
            end
        end
    end 

    return FreeSpinCount[1] + FreeSpinCount[2]
end

function FortunesOfGoldFunc:isStopReel(nReelID)
    return false
end

function FortunesOfGoldFunc:isNeedPlayReelStopSound(nReelID)
    local bres = self:isStopReel(nReelID)
    if bres then
        return false
    end

    return true
end

function FortunesOfGoldFunc:FortunesOfGoldSymbolShiftDown(bResultDeck, nDeckKey, nReelID)
    local nSymbolID = -1
    local reel = SlotsGameLua.m_listReelLua[nReelID]

    if bResultDeck then
        local nRow = SlotsGameLua.m_nRowCount
        local nRowIndex = math.floor(nDeckKey % nRow)
        nSymbolID = self.m_listReel2Deck2[nRowIndex]
    else
        nSymbolID = reel:GetRandom(false)
    end

    local nTotalNum = reel.m_nReelRow + reel.m_nAddSymbolNums
    for y = 0, nTotalNum - 1 do
        if y == 0 then
            local goSymbol0 = self.m_listGoSymbol[0] --GameObject
            table.insert(self.m_listOutSideSymbols, goSymbol0)
            local cnt = #self.m_listOutSideSymbols
            if cnt == self.m_nOutSideCount+1 then
                SymbolObjectPool:Unspawn(self.m_listOutSideSymbols[1])
                
                table.remove( self.m_listOutSideSymbols, 1 ) -- 移出
            end

            self.m_curSymbolIds[0] = -1
        end

        if y == nTotalNum - 1 then
            self.m_listGoSymbol[y] = nil
            self:SetSymbolReel2(y, nSymbolID)
        else
            self.m_listGoSymbol[y] = self.m_listGoSymbol[y+1]
			self.m_curSymbolIds[y] = self.m_curSymbolIds[y+1]
        end

        if y < nTotalNum-1 then
            local pos = self.m_listGoSymbol[y].transform.localPosition
            local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(nReelID, y)
            fOrderZ = fOrderZ + 5
            local newPos = Unity.Vector3(pos.x, pos.y, fOrderZ)
            self.m_listGoSymbol[y].transform.localPosition = newPos
        end

    end

end

function FortunesOfGoldFunc:SetSymbolReel2(y, nSymbolID)
    self.m_curSymbolIds[y] = nSymbolID

    if self.m_listGoSymbol[y] ~= nil then
        SymbolObjectPool:Unspawn(self.m_listGoSymbol[y])
    end

    local reel = SlotsGameLua.m_listReelLua[2]

    local newSymbol = SlotsGameLua:GetSymbol(nSymbolID)
    local go = SymbolObjectPool:Spawn(newSymbol.prfab)
    go.transform:SetParent(reel.m_transform)
    go.transform.localScale = Unity.Vector3.one

    local elemPos = self.m_listSymbolPos[y]
    if y >= 1 then
        local prePos = self.m_listGoSymbol[y-1].transform.localPosition
        elemPos = prePos
        elemPos.y = elemPos.y + SlotsGameLua.m_fSymbolHeight
    end
    go.transform.localPosition = elemPos

    local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(2, y)
    fOrderZ = fOrderZ + 5
    local newPos = Unity.Vector3(elemPos.x, elemPos.y, fOrderZ)
    go.transform.localPosition = newPos

    self.m_listGoSymbol[y] = go
    self:ModifyReel2ElemSize(go, nSymbolID)
end

function FortunesOfGoldFunc:ModifyReel2ElemSize(go, nSymbolID)
    if go == nil then
        Debug.Log("-----FortunesOfGoldFunc:ModifyReel2ElemSize----error!-------")
        return
    end

    local fScaleY = self:getScaleY(nSymbolID)
    go.transform.localScale = Unity.Vector3(1.0, fScaleY, 1.0)
end

function FortunesOfGoldFunc:getScaleY(nSymbolID)
    local fScaleY = 0.5
    if nSymbolID >= 6 and nSymbolID <= 10 then -- AKQJ10
        fScaleY = 0.7
    elseif nSymbolID == 1 then
        fScaleY = 0.6
    elseif nSymbolID == 5 then
        fScaleY = 0.7
    elseif nSymbolID == 2 or nSymbolID == 4 then
        fScaleY = 0.8
    elseif nSymbolID == 3 then -- 碗
        fScaleY = 0.9
    end

    return fScaleY
end

function FortunesOfGoldFunc:getScaleCoef(x, y, bCustomFlag)
    local nKey = SlotsGameLua.m_nRowCount * x + y
    local nSymbolID = SlotsGameLua.m_listDeck[nKey]
    if x == 2 and bCustomFlag then
        nSymbolID = self.m_listReel2Deck2[y]
    end

    local fScaleCoef = self:getScaleY(nSymbolID)
    return fScaleCoef
end

function FortunesOfGoldFunc:initSymbolPosReel2()
    local fReel2Height = SlotsGameLua.m_fSymbolHeight / 2.0

    local reel = SlotsGameLua.m_listReelLua[2]
    local nSymbolNum = reel.m_nReelRow + reel.m_nAddSymbolNums --#(reelLua.m_listGoSymbol)
    for i=0, nSymbolNum-1 do
        local pos = reel.m_listSymbolPos[i]
        reel.m_listSymbolPos[i] = Unity.Vector3(pos.x, pos.y - fReel2Height/2.0, pos.z)

        self.m_listSymbolPos[i] = Unity.Vector3(pos.x, pos.y + fReel2Height/2.0, pos.z)
    end
    
end

function FortunesOfGoldFunc:SetSymbolRandomReel2()
    local reel = SlotsGameLua.m_listReelLua[2]
    local nTotal = reel.m_nReelRow + reel.m_nAddSymbolNums

    for i=0, nTotal-1 do
        local nId = reel:GetRandom(false)
        self:SetSymbolReel2(i, nId)
    end
end

function FortunesOfGoldFunc:resetReel2SymbolsPos()
    local reel = SlotsGameLua.m_listReelLua[2]

    local nTotalNum = reel.m_nReelRow + reel.m_nAddSymbolNums
    for y = 0, nTotalNum - 1 do
        local posx = self.m_listSymbolPos[y].x
        local posy = self.m_listSymbolPos[y].y
        local posz = LevelCommonFunctions:getSymbolOrderZ(2, y)

        local pos = Unity.Vector3(posx, posy, posz)
        self.m_listGoSymbol[y].transform.localPosition = pos
    end

    local cnt = #self.m_listOutSideSymbols
    for i=0, cnt-1 do
        local posx = self.m_listSymbolPos[0].x
        local posy = self.m_listSymbolPos[0].y
        local posz = self.m_listSymbolPos[0].z
        posy = posy - SlotsGameLua.m_fSymbolHeight * (cnt - i)

        local pos = Unity.Vector3(posx, posy, posz)
        self.m_listOutSideSymbols[i+1].transform.localPosition = pos
    end

end

function FortunesOfGoldFunc:ShowMatchLinesEffect(nIndex)
    local wi = self.m_listWins2[nIndex]
    local ld = SlotsGameLua:GetLine(wi.m_nLineID)

    for x = 0, wi.m_nMaxMatchReelID do
        local y = ld.Slots[x]
        self:PlayHitLineEffect2(x, y)
        self:PlaySpineEffect2(x, y)
        self:LoopScaleSymbol2(x, y)
    end

    PayLinePayWaysEffectHandler:InitCurPayLineEffectKeys(wi.m_nLineID, true, wi)
    PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()

end

function FortunesOfGoldFunc:ShowAllMatchLines2()
    local nTotalWinLines = #self.m_listWins2
    for nWinIndex = 1, nTotalWinLines do
        self:ShowMatchLinesEffect(nWinIndex)
    end
end

function FortunesOfGoldFunc:PlayHitLineEffect2(x, y)
    local nEffectKey = SlotsGameLua.m_nRowCount * x + y
    if x == 2 then
        nEffectKey = nEffectKey + 100 -- 避免重复
    end

    local pos0 = SlotsGameLua.m_listReelLua[x].m_transform.localPosition
    local pos1 = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y].transform.localPosition
    if x == 2 then
        pos1 = self.m_listGoSymbol[y].transform.localPosition
    end
    local pos2 = SlotsGameLua.m_transform.localPosition
    local effectPos = pos0 + pos1 + pos2

    PayLinePayWaysEffectHandler:PlayHitLineEffect2(effectPos, nEffectKey, x, y)
end

function FortunesOfGoldFunc:PlaySpineEffect2(x, y)
	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
    if x == 2 then
        nEffectKey = nEffectKey + 100 -- 避免重复
    end
    local goSymbol = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y]
    if x == 2 then
        goSymbol = self.m_listGoSymbol[y]
    end

    PayLinePayWaysEffectHandler:PlaySpineEffect2(goSymbol, nEffectKey)
end

function FortunesOfGoldFunc:LoopScaleSymbol2(x, y)
	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
    if x == 2 then
        nEffectKey = nEffectKey + 100 -- 避免重复
    end
	
    local goSymbol = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y]
    if x == 2 then
        goSymbol = self.m_listGoSymbol[y]
    end

    PayLinePayWaysEffectHandler:LoopScaleSymbol2(goSymbol, nEffectKey, x, y, true)
end

----------------

--仿真，把结果 输入到文本文件中
function FortunesOfGoldFunc:Simulation()
    self.m_bSimulationFlag = true
    self.m_nSimulationFreeSpinLess16Num = 0 -- 玩家获得freespin超过16次的次数统计
    self.m_nSimulationFreeSpinLarge100Num = 0 -- 玩家获得freespin超过100次的次数统计

    self.m_nFreeSpinTriggerFreq = 0

    Unity.Random.InitState(TimeHandler:GetServerTimeStamp())
    
    self:GetTestResultByRate()
    self:WriteToFile()
    
    self.m_bSimulationFlag = false

end

function FortunesOfGoldFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount

    local nWin0Count = 0
    self.m_nSimulationWin0SpinNum = 0 -- 统计仿真期间一共有多少次没有中奖
    self.m_nFreeSpin16Count = 0 --出现16次freespin的次数

    local c = 0
    while true do
        local bFreeSpinFlag = rt:InFreeSpin()
        if c >= 2*nSimulationCount then
            break
        end
        if c >= nSimulationCount and not bFreeSpinFlag then
            break
        end
        
       --  -- 这个没有用了 取数据都是从事先配好的表里取

        local bFlag = rt:Spin()
        if bFlag then
            --
        end

        if rt.m_nFreeSpinTotalCount > 0 then
            rt.m_nFreeSpinCount = rt.m_nFreeSpinCount + 1
        end
        
        local iDeck = self:GetDeck()
        
        rt = self:CheckSpinWinPayLines(iDeck, rt)
        local nMaxCount = 10
        if rt.m_fSpinWin <= 0.0 then
            nWin0Count = nWin0Count + 1
            self.m_nSimulationWin0SpinNum = self.m_nSimulationWin0SpinNum + 1
        elseif nWin0Count > 0 then
            if nWin0Count > nMaxCount then
                if rt.m_TestWin0Nums[nMaxCount] == nil then
                    rt.m_TestWin0Nums[nMaxCount] = 1
                else
                    rt.m_TestWin0Nums[nMaxCount] = rt.m_TestWin0Nums[nMaxCount] + 1
                end
            else
                for i=1, nWin0Count do
                    if rt.m_TestWin0Nums[i] == nil then
                        rt.m_TestWin0Nums[i] = 1
                    else
                        rt.m_TestWin0Nums[i] = rt.m_TestWin0Nums[i] + 1
                    end
                end
            end
            nWin0Count = 0
        else
            --
        end

        Debug.Assert(ReturnRateManager.m_enumReturnRateType == SlotsGameLua.m_enumSimRateType)
        Debug.Assert(SceneSlotGame.m_nTotalBet == 1)
        c = c + 1
    end
    
    self.m_nSimulationCount = c
    SlotsGameLua.m_TestGameResult = rt
    SceneSlotGame.m_nTotalBet = nPreTotalBet  --下注 金额 还原

    ChoiceCommonFunc:CreateChoice()
end

function FortunesOfGoldFunc:WriteToFile()
    local strFile = ThemeLoader.themeKey .. "\n"
    local levelReturnRateType = SlotsGameLua.m_enumSimRateType
    if levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
        strFile = strFile.."=============enumReturnType_Rate200============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        strFile = strFile.."============enumReturnType_Rate95===============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        strFile = strFile.."==========enumReturnType_Rate50=============\n"
    end

    local rt = SlotsGameLua.m_TestGameResult
    local fTotalUse = 1.0 * (self.m_nSimulationCount  - rt.m_nFreeSpinAccumCount)
    local fTotalWin = rt.m_fGameWin
    local Ratio = fTotalWin / fTotalUse

    strFile = strFile.."Test SimulationCount:  "..SlotsGameLua.m_SimulationCount.."\n"
    strFile = strFile.."Actual SimulationCount:  "..self.m_nSimulationCount.."\n"
    strFile = strFile.."TotalBets : "..fTotalUse.."\n"
    strFile = strFile.."TotalWins : "..fTotalWin.."\n"
    strFile = strFile.."Return Rate: "..Ratio.."\n"
    strFile = strFile .. "----------------------------------" .. "\n"

    local nSymbolCount = #SlotsGameLua.m_listSymbolLua
    for i=1, nSymbolCount + 1 do
        local name = ""
        if i <= nSymbolCount then
            name = SlotsGameLua.m_listSymbolLua[i].prfab.name
        end

        local nHit = 0
        local fWinGold = 0
        if rt.m_listTestWinSymbols[i] ~= nil then
            nHit = rt.m_listTestWinSymbols[i].Hit
            fWinGold = rt.m_listTestWinSymbols[i].WinGold
        end
        strFile = strFile.."Name: "..name .." | HitWinCount: "..nHit.." | WinGolds: "..fWinGold.."\n"
    end

    strFile = strFile.. "\n"

    local nMaxCount = 10
    for i=1, nMaxCount do
        if rt.m_TestWin0Nums[i] > 0 then
            local strTemp = "Win0Count_" .. tostring(i) .. ": "
            strFile = strFile.. strTemp .. rt.m_TestWin0Nums[i] .. "\n"
        end
    end

    local fWin0Rate = self.m_nSimulationWin0SpinNum / self.m_nSimulationCount
    strFile = strFile.."fWin0Rate: " .. fWin0Rate .. "\n"

    strFile = strFile.. "\n"

    strFile = strFile.."FreeSpin TotalNum: " .. rt.m_nFreeSpinAccumCount .. "\n"
    strFile = strFile.."FreeSpin TotalWin: " .. rt.m_fFreeSpinAccumWins .. "\n"
    strFile = strFile.. "\n"
    strFile = strFile.."FreeSpinLess16Num: " .. self.m_nSimulationFreeSpinLess16Num .. "\n"
    strFile = strFile.."FreeSpinLarge100Num: " .. self.m_nSimulationFreeSpinLarge100Num .. "\n"

    strFile = strFile.."FreeSpinTriggerFreq: " .. self.m_nFreeSpinTriggerFreq .. "\n"

    strFile = strFile.. "\n"

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir..ThemeLoader.themeKey..".txt"
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end

---------------
function FortunesOfGoldFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)
    
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = FortunesOfGoldLevelUI
end
