require("Lua/ThemeVideo/TigerDragon/TigerDragonConfig")
require("Lua/ThemeVideo/TigerDragon/TigerDragonCustomDeck")
require("Lua/ThemeVideo/TigerDragon/TigerDragonSymbol")
require("Lua/ThemeVideo/TigerDragon/TigerDragonLevelUI")

TigerDragonFunc = {}

function TigerDragonFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.tableBigSymbol = {}
    
    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}
end 

function TigerDragonFunc:refreshHitSymbols(nLineId, nMaxMatchId)
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        if x <= nMaxMatchId then
            local reel = SlotsGameLua.m_listReelLua[x]

            local y = SlotsGameLua:GetLine(nLineId).Slots[x]
            local nKey = SlotsGameLua.m_nRowCount * x + y

            local bflag = LuaHelper.tableContainsElement(self.m_listHitSymbols, nKey)
            if not bflag then
                table.insert(self.m_listHitSymbols, nKey )
            end
        end
    end

end

function TigerDragonFunc:OnStartSpin()
    TigerDragonLevelUI.mDeckResultPayWays:MatchLineHide()
    self:CreateReelRandomSymbolList()

    if not SlotsGameLua.m_GameResult:InReSpin() and not SlotsGameLua.m_GameResult:InFreeSpin() then
        local bNeedResetJackPotValue = false
        for i = 1, #self.tableNowbGetJackPot do
            if self.tableNowbGetJackPot[i] then
                bNeedResetJackPotValue = true
                break
            end
        end         

        if bNeedResetJackPotValue then
            TigerDragonLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            for i = 1, #self.tableNowbGetJackPot do
                self.tableNowbGetJackPot[i] = false
            end
        end
    end 
    
    if SlotsGameLua.m_GameResult:InReSpin() then
        for k, v in pairs(self.tableFixedSymbol) do
            local nKey = k
            local nSymbolId = v
            local nReelId = nKey // SlotsGameLua.m_nRowCount
            local nRowIndex = nKey % SlotsGameLua.m_nRowCount
            TigerDragonLevelUI:FixedSymbol(nSymbolId, nReelId, nRowIndex)
        end
    end

end

function TigerDragonFunc:OnSpinEnd()

end

function TigerDragonFunc:GetDeck()
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local deck = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            local nKey = SlotsGameLua.m_nRowCount * x + y
            deck[nKey] = nSymbolId
        end
    end     

    TigerDragonCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    TigerDragonCustomDeck:ModifyDeckForBigSymbol(deck)

    if rt:InReSpin() then
        local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")
        for k, v in pairs(self.tableFixedSymbol) do
            local nKey = k
            local nSymbolId = v
            local nReelId = nKey // SlotsGameLua.m_nRowCount
            local nRowIndex = nKey % SlotsGameLua.m_nRowCount
            deck[nKey] = nSymbolId
            
            if TigerDragonSymbol:isWildSymbol(nSymbolId) then
                deck[nKey - 1] = nNullSymbolId
                deck[nKey - 2] = nNullSymbolId
            end
        end
    end

    return deck
end

function TigerDragonFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local nContinueCount = 0
        local nContinueMaxCount = 0
        local nStackSymbolId = TigerDragonSymbol:GetCommonSymbolIdByReelId(x)
        local bHaveScatter = false
        local bHaveWildSymbol = false
        for i = 1, cnt do
            if nContinueCount >= nContinueMaxCount then
                nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                nContinueCount = 0
                nContinueMaxCount = math.max(1, 5)
            end

            if TigerDragonSymbol:isScatterSymbol(nStackSymbolId) then
                if bHaveScatter then
                    nStackSymbolId = TigerDragonSymbol:GetCommonSymbolIdByReelId(x)
                else    
                    bHaveScatter = true
                end
            end

            if TigerDragonSymbol:isWildSymbol(nStackSymbolId) then
                if bHaveWildSymbol then
                    nStackSymbolId = TigerDragonSymbol:GetCommonSymbolIdByReelId(x)
                else    
                    bHaveWildSymbol = true
                end
            end

            nContinueCount = nContinueCount + 1
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nStackSymbolId
        end
    end

end

function TigerDragonFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]
end   

function TigerDragonFunc:isReelCanStartDeck(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nIndex = reel.m_nReelRow + reel.m_nAddSymbolNums -1
    local nPreID = reel.m_curSymbolIds[nIndex]

    if TigerDragonSymbol:isCommonSymbolId(nPreID) then
        return true
    end

    return false
end

function TigerDragonFunc:GetDeckFinishRandom(nReelId, nStopOffset)
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nSymbolId = reel:GetRandom(false)
    if TigerDragonSymbol:isWildSymbol(nSymbolId) or nSymbolId == nNullSymbolId then
        nSymbolId = TigerDragonSymbol:GetCommonSymbolIdByReelId(nReelId)
    end

    if self.tableBigSymbol[nReelId] and self.tableBigSymbol[nReelId][1] >= SlotsGameLua.m_nRowCount then
        local nTargetRowIndex = self.tableBigSymbol[nReelId][1]
        local nBigSymbolId = self.tableBigSymbol[nReelId][2]

        if nStopOffset + SlotsGameLua.m_nRowCount == nTargetRowIndex then
            nSymbolId = nBigSymbolId
        elseif nStopOffset + SlotsGameLua.m_nRowCount < nTargetRowIndex then
            nSymbolId = nNullSymbolId
        elseif nStopOffset + SlotsGameLua.m_nRowCount > nTargetRowIndex then

        end
    end     

    return nSymbolId
end

function TigerDragonFunc:ReDeck(deck)
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    for k, v in pairs(TigerDragonFunc.tableBigSymbol) do
        local nReelId = k
        local nTargetIndex = v[1]
        local nSymbolId = v[2]
        local nStackBeginIndex = math.min(3, nTargetIndex)
        local nStackEndIndex = math.max(0, nTargetIndex - 2)
        for j = nStackBeginIndex, nStackEndIndex, -1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + j
            deck[nKey] = nSymbolId
        end
    end 

    deck[3] = nNullSymbolId
    deck[19] = nNullSymbolId
end 

function TigerDragonFunc:PreCheckWin()
    for k, v in pairs(TigerDragonLevelUI.tableFixedGoSymbol) do
        TigerDragonLevelUI:SetDefaultLayer(v)
        SymbolObjectPool:Unspawn(v)
    end
    TigerDragonLevelUI.tableFixedGoSymbol = {}

    local fAniTime = self:CheckWildExpand(SlotsGameLua.m_listDeck, SlotsGameLua.m_GameResult)
    LeanTween.delayedCall(fAniTime, function()
        self:ReDeck(SlotsGameLua.m_listDeck)

        --self:CheckBug()
        
        SlotsGameLua:CheckWinEnd()
        TigerDragonLevelUI.mDeckResultPayWays:InitMatchLineShow()
    end)

end

function TigerDragonFunc:CheckBug()
    if SlotsGameLua.m_GameResult:InReSpin() and not SlotsGameLua.m_GameResult:HasReSpin() then
        local nNanWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nanxiaWild_1")
        local nNvWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nvxiaWild_1")

        for nKey = 0, 2 do
            Debug.Assert(SlotsGameLua.m_listDeck[nKey] == nNanWildSymbol)
        end

        for nKey = 16, 18 do
            Debug.Assert(SlotsGameLua.m_listDeck[nKey] == nNvWildSymbol)
        end 

        Debug.LogWithColor("检查Bug完毕")
    end

end

function TigerDragonFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            if  TigerDragonFunc:orValidKey(nKey)  then
                local nSymbolId = deck[nKey]
                if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                    nScatterCount = nScatterCount + 1
                    break
                end
            end
        end
    end
    
    return nScatterCount >= 3, nScatterCount
end

function TigerDragonFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
end

function TigerDragonFunc:CheckDoorChangeSymbol(bHaveBothWild, deck, result) 
    local nDoorSymbolId = SlotsGameLua:GetSymbolIdByObjName("men")
    local nNanWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nanxiaWild_1")
    local nNvWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nvxiaWild_1")

    self.tableFixedSymbol = {}

    local bHaveAni = false
    if bHaveBothWild and not result:InReSpin() then
        local bHaveDoor = false
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                if TigerDragonFunc:orValidKey(nKey) then
                    local nSymbolId = deck[nKey]
                    if nSymbolId == nDoorSymbolId then
                        bHaveDoor = true
                        break
                    end
                end
            end
        end 

        if bHaveDoor then
            result.m_nReSpinTotalCount = result.m_nReSpinTotalCount + 1

            for i = 0, SlotsGameLua.m_nReelCount - 1 do
                for j = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = i * SlotsGameLua.m_nRowCount + j
                    if self:orValidKey(nKey) then
                        local nSymbolId = deck[nKey]
                        if nSymbolId == nDoorSymbolId then
                            self.tableFixedSymbol[nKey] = nDoorSymbolId
                        end
                    end
                end
            end 

            self.tableFixedSymbol[2] = nNanWildSymbol
            self.tableFixedSymbol[18] = nNvWildSymbol

            if self.m_bSimulationFlag then  
                self.m_nSimuReSpinTriggerCount = self.m_nSimuReSpinTriggerCount + 1
            end
        end
    else
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local nSymbolId = deck[nKey]
                if nSymbolId == nDoorSymbolId and TigerDragonFunc:orValidKey(nKey) then
                    local nToSymbolId = math.random(1, 11)
                    deck[nKey] = nToSymbolId

                    if not self.m_bSimulationFlag then
                        bHaveAni = true
                        local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                        local oriPos = goSymbol.transform.position
                        TigerDragonLevelUI:FillSymbol(nToSymbolId, i, j)
                        
                        local goEffect = TigerDragonLevelUI:GetEffectByEffectPool("OpenTigerDragonDoorEffect")
                        goEffect.transform.position = oriPos
                        goEffect:SetActive(true)
                        LeanTween.delayedCall(0.607, function()
                            TigerDragonLevelUI:RecycleEffectToEffectPool(goEffect)
                        end)
                    end
                end
            end
        end
    end

    if bHaveAni then
        if not self.m_bSimulationFlag then
            AudioHandler:PlayThemeSound("revealWild")
        end
    end
    
    return bHaveAni
end

function TigerDragonFunc:CheckWildExpand(deck, result)   
    local bHaveWildAni = false
    local nNanWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nanxiaWild_1")
    local nNvWildSymbol = SlotsGameLua:GetSymbolIdByObjName("nvxiaWild_1")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    local bHaveNanWild = false
    local bHaveNvWild = false
    local bHaveBothWild = false

    if not result:InReSpin() then
        if self.tableBigSymbol[0] then
            bHaveNanWild = true
        end

        if self.tableBigSymbol[4] then
            bHaveNvWild = true
        end

        bHaveBothWild = bHaveNanWild and bHaveNvWild
        if bHaveBothWild then
            if not self.m_bSimulationFlag then
                local nReelId = 0 
                local nRowIndex = self.tableBigSymbol[0][1]
                if TigerDragonFunc:PlayWildMoveAni(nReelId, nRowIndex) then
                    bHaveWildAni = true
                end

                local nReelId = 4 
                local nRowIndex = self.tableBigSymbol[4][1]
                if TigerDragonFunc:PlayWildMoveAni(nReelId, nRowIndex) then
                    bHaveWildAni = true
                end
            end

            TigerDragonFunc.tableBigSymbol[0] = {2, nNanWildSymbol}
            TigerDragonFunc.tableBigSymbol[4] = {2, nNvWildSymbol}
            deck[0] = nNullSymbolId
            deck[1] = nNullSymbolId
            deck[2] = nNanWildSymbol

            deck[16] = nNullSymbolId
            deck[17] = nNullSymbolId
            deck[18] = nNvWildSymbol

            if self.m_bSimulationFlag then
                self.m_nSimunTriggerBothBigSymbolCount = self.m_nSimunTriggerBothBigSymbolCount + 1
            end
        end
    end

    local bHaveOpenDoorAni = self:CheckDoorChangeSymbol(bHaveBothWild, deck, result)

    if bHaveWildAni then
        return 1.0
    elseif bHaveOpenDoorAni then
        return 1.0
    else
        return 0.0
    end

end

function TigerDragonFunc:PlayWildMoveAni(nReelId, nRowIndex)
    local m_fWildPlayAniTime = 0.6
    local nTargetRowIndex = 2
    local fSymbolHeight = SlotsGameLua.m_fSymbolHeight
    local nTotalSymbols = SlotsGameLua.m_nRowCount + SlotsGameLua.m_listReelLua[nReelId].m_nAddSymbolNums
    local nMoveRowCount = math.abs(nTargetRowIndex - nRowIndex)
    if nMoveRowCount == 0 then
        return false
    end

    for i = 0, nTotalSymbols - 1 do
        local nIndex = i
        local mGoSymbolt = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i]

        if nRowIndex < nTargetRowIndex then
            local ToPosY = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[i].y + fSymbolHeight * nMoveRowCount
            local ltd = LeanTween.moveLocalY(mGoSymbolt, ToPosY, m_fWildPlayAniTime):setEase(LeanTweenType.easeInOutQuad)
            ltd:setOnComplete(function()
                if nIndex >= nTotalSymbols - nMoveRowCount then
                    SymbolObjectPool:Unspawn(mGoSymbolt)
                end
            end)
        elseif nRowIndex > nTargetRowIndex then
            local ToPosY = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[i].y - fSymbolHeight * nMoveRowCount
            local ltd = LeanTween.moveLocalY(mGoSymbolt, ToPosY, m_fWildPlayAniTime):setEase(LeanTweenType.easeInOutQuad)
            ltd:setOnComplete(function()
                if nIndex < nMoveRowCount then
                    SymbolObjectPool:Unspawn(mGoSymbolt)
                end
            end)
        end
    end

    if nRowIndex < nTargetRowIndex then
        for i = nTotalSymbols - 1, nMoveRowCount, -1 do
            SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i] = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i - nMoveRowCount]
            SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i] = SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i - nMoveRowCount]
        end

        for i = 0, nMoveRowCount - 1 do
            local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

            local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, i)
            newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
            newGO.transform.localScale = Unity.Vector3.one
            newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[i]
            SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i] = newGO
            SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i] = nSymbolId
        end
    elseif nRowIndex > nTargetRowIndex then
        for i = 0, nTotalSymbols - 1 - nMoveRowCount do
            SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i] = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i + nMoveRowCount]
            SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i] = SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i + nMoveRowCount]
        end 

        for i = nTotalSymbols - nMoveRowCount, nTotalSymbols - 1 do
            local nSymbolId = TigerDragonSymbol:GetCommonSymbolIdByReelId(nReelId)
            local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, i)
            newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
            newGO.transform.localScale = Unity.Vector3.one
            newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[i]
            SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[i] = newGO
            SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[i] = nSymbolId
        end
    end

    return true
end

function TigerDragonFunc:CheckFreeSpin(deck, result)
    local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
    if bTrigger then
        local nFreeSpinCount = TigerDragonConfig:GetFreeSpinCount(nScatterCount)
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end
    end
end

function TigerDragonFunc:orValidKey(nKey)
    return nKey ~= 3 and nKey ~= 19
end

function TigerDragonFunc:GetPayWaysWin(deck, result)
    self:GetReelWin(0, deck, 0, result)
end

function TigerDragonFunc:GetReelWin(nPreID, deck, nStartReelId, result)    
    for k = 0, SlotsGameLua.m_nRowCount - 1 do
        local nKey = SlotsGameLua.m_nRowCount * nStartReelId + k
        local nCurID = deck[nKey]
        local bRecusive = false
        if TigerDragonSymbol:isWildSymbol(nCurID) then
            if nStartReelId < SlotsGameLua.m_nReelCount - 1 then
                bRecusive = true
                self:GetReelWin(nCurID, deck, nStartReelId + 1, result)
            end
        end

        if not bRecusive then
            local nWays = 0
            local nMatches = 0

            local nReelSameSymbolNums = {}
            for x = nStartReelId + 1, SlotsGameLua.m_nReelCount - 1 do
                nReelSameSymbolNums[x] = 0
                for y = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey1 = SlotsGameLua.m_nRowCount * x + y
                    local nID = deck[nKey1]
                    if self:isSamekindSymbol(nCurID, nID)  then
                        nReelSameSymbolNums[x] = nReelSameSymbolNums[x] + 1
                    end
                end
            end

            nWays = 1
            nMatches = nStartReelId + 1
            for x = nStartReelId + 1, SlotsGameLua.m_nReelCount - 1 do
                if nReelSameSymbolNums[x] == 0 then
                    break
                end

                nWays = nWays * nReelSameSymbolNums[x]
                nMatches = nMatches + 1
            end

            self:GetElemWin(nCurID, nMatches, nWays, deck, result)
        end
    end

end

function TigerDragonFunc:GetElemWin(nCurID, nMatches, nWays, deck, result)
    local sd = SlotsGameLua:GetSymbol(nCurID)
    local nRewardBet = sd.m_fRewards[nMatches]
    if nMatches > 0 and nRewardBet > 0 then
        Debug.Assert(TigerDragonSymbol:IsNoLineAwardSymbolId(nCurID) == false)
        local fWinGold = nWays * nRewardBet * SceneSlotGame.m_nTotalBet / 100

        local winItem = WinItemPayWay:create(nCurID, nMatches, nWays, fWinGold)
        if result.m_mapWinItemPayWays[nCurID] then
            local curItem = result.m_mapWinItemPayWays[nCurID]
            curItem.m_nWays = curItem.m_nWays + nWays
            curItem.m_fWinGold = fWinGold
        else
            result.m_mapWinItemPayWays[nCurID] = winItem
        end

        result.m_fSpinWin = result.m_fSpinWin + fWinGold
        if self.m_bSimulationFlag then
            local result = SlotsGameLua.m_TestGameResult
            if result.m_mapTestPayWayWinItems[nCurID] == nil then
                result.m_mapTestPayWayWinItems[nCurID] = TestWinItem:create(nCurID)
            end

            local nMoneyCount = fWinGold
            result.m_mapTestPayWayWinItems[nCurID].Hit = result.m_mapTestPayWayWinItems[nCurID].Hit + 1
            result.m_mapTestPayWayWinItems[nCurID].WinGold = result.m_mapTestPayWayWinItems[nCurID].WinGold + nMoneyCount
        end
    end
end

--检查Wild 匹配
function TigerDragonFunc:isSamekindSymbol(nCurSymbolId, nSymbolId)
    if TigerDragonSymbol:isWildSymbol(nSymbolId) or TigerDragonSymbol:isWildSymbol(nCurSymbolId) then
        return true
    end

    if nCurSymbolId == nSymbolId then
        return true
    end
    
    return false
end

function TigerDragonFunc:CheckSpinWinPayWays(deck, result)
    result:ResetSpin()
    self:GetPayWaysWin(deck, result)
    
    if result.m_fSpinWin == 0.0 then
        self.m_nWin0Count = self.m_nWin0Count + 1
    else
        self.m_nWin0Count = 0
    end     

    self:CheckGameResult(deck, result)   
    if result:InReSpin() then
        if self.m_bSimulationFlag then
            self.m_nSimuReSpinTriggerMoneyCount = self.m_nSimuReSpinTriggerMoneyCount + result.m_fSpinWin
        end
    end 

    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinWinMoneyCount = self.m_nSimuFreeSpinWinMoneyCount + result.m_fSpinWin
        end
    end

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--仿真，把结果 输入到文本文件中
function TigerDragonFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function TigerDragonFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount

    self.m_nSimuFreeSpinTriggerCount = 0 
    self.m_nSimuFreeSpinCount = 0
    self.m_nSimuFreeSpinWinMoneyCount = 0

    self.m_nSimunTriggerBothBigSymbolCount = 0

    self.m_nSimuReSpinCount = 0
    self.m_nSimuReSpinTriggerCount = 0
    self.m_nSimuReSpinTriggerMoneyCount = 0

    local c = 0
    while true do
        local bFlag = rt:Spin()
        local bFreeSpinFlag = rt:HasFreeSpin()
        local bReSpinFlag = rt:HasReSpin()

        if c >= 2 * nSimulationCount then
            break
        end

        if c >= nSimulationCount and (not bFreeSpinFlag) and (not bReSpinFlag) then
            break
        end

        if bReSpinFlag then
            rt.m_nReSpinCount = rt.m_nReSpinCount + 1
            self.m_nSimuReSpinCount = self.m_nSimuReSpinCount + 1
        elseif bFreeSpinFlag then
            rt.m_nFreeSpinCount = rt.m_nFreeSpinCount + 1
            self.m_nSimuFreeSpinCount = self.m_nSimuFreeSpinCount + 1
        end

        local iDeck = self:GetDeck()
        self:CheckWildExpand(iDeck, rt)
        self:ReDeck(iDeck)
        self:CheckSpinWinPayWays(iDeck, rt)

        Debug.Assert(ReturnRateManager.m_enumReturnRateType == SlotsGameLua.m_enumSimRateType)
        Debug.Assert(SceneSlotGame.m_nTotalBet == 1)

        if not bReSpinFlag then
            c = c + 1
        end

        if c >= nSimulationCount then
            break
        end
    end 

    self.m_nSimulationCount = c
    SlotsGameLua.m_TestGameResult = rt
    SceneSlotGame.m_nTotalBet = nPreTotalBet  --下注 金额 还原
    ChoiceCommonFunc:CreateChoice()

end 

function TigerDragonFunc:WriteToFile()
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
    local fTotalUse = 1.0 * (self.m_nSimulationCount  - self.m_nSimuFreeSpinCount)
    local fTotalWin = rt.m_fGameWin
    local Ratio = fTotalWin / fTotalUse

    strFile = strFile.."Test SimulationCount:  "..SlotsGameLua.m_SimulationCount.."\n"
    strFile = strFile.."Actual SimulationCount:  "..self.m_nSimulationCount.."\n"
    strFile = strFile.."TotalBets : "..fTotalUse.."\n"
    strFile = strFile.."TotalWins : "..fTotalWin.."\n"
    strFile = strFile.."Return Rate: "..Ratio.."\n"
    strFile = strFile .. "\n"

    strFile = strFile .. "----------------------------------" .. "\n"
    local nSymbolCount = #SlotsGameLua.m_listSymbolLua
    for i = 1, nSymbolCount do
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

    strFile = strFile .. "\n"
    strFile = strFile.."FreeSpin 触发次数: "..self.m_nSimuFreeSpinTriggerCount.."\n"
    strFile = strFile.."FreeSpin 次数: "..self.m_nSimuFreeSpinCount.."\n"
    strFile = strFile.."FreeSpin 总赢钱数: "..self.m_nSimuFreeSpinWinMoneyCount.."\n"
    strFile = strFile .. "\n"
    strFile = strFile.."ReSpin 触发次数: "..self.m_nSimuReSpinTriggerCount.."\n"
    strFile = strFile.."ReSpin 次数: "..self.m_nSimuReSpinCount.."\n"
    strFile = strFile.."ReSpin 总赢钱数: "..self.m_nSimuReSpinTriggerMoneyCount.."\n"
    strFile = strFile .. "\n"
    strFile = strFile.."Wild 同时触发次数: "..self.m_nSimunTriggerBothBigSymbolCount.."\n"

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

---------------------------------------------------------------------------------------
function TigerDragonFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayWaysFunc(self, self.CheckSpinWinPayWays)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)
    SceneSlotGame.m_LevelUiTableParam = TigerDragonLevelUI
end

