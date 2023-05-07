require("Lua/ThemeVideo/RedHat/RedHatConfig")
require("Lua/ThemeVideo/RedHat/RedHatCustomDeck")
require("Lua/ThemeVideo/RedHat/RedHatSymbol")
require("Lua/ThemeVideo/RedHat/RedHatLevelUI")

RedHatFunc = {}

function RedHatFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.nCollectCount = 0
    self.nCollectFreeSpinCount = 0
    self.nFreeSpinFixedType = 0

    self.bBonusFeatureUnlock = false

    self.tableWildAddFreeSpinKeys = {}
    self.tableFreeSpinStickySymbol = {}
    self.nSpinCount = 0
    self.nSumTotalBetCount = 0
end 

function RedHatFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function RedHatFunc:OnStartSpin()
    RedHatFunc:AddAverageBet()
    RedHatLevelUI.mDeckResultPayLines:MatchLineHide()
    self:CreateReelRandomSymbolList()
    for k, v in pairs(RedHatLevelUI.tableFixedGoSymbol) do
        v:SetActive(true)
    end
end

function RedHatFunc:OnSpinEnd()
    RedHatLevelUI.mDeckResultPayLines:InitMatchLineShow()
    for k, v in pairs(RedHatLevelUI.tableFixedGoSymbol) do
        v:SetActive(false)
    end
end 

function RedHatFunc:GetDeck()
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

    RedHatCustomDeck:ModifyDeckForTriggerWild(deck)
    RedHatCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    RedHatCustomDeck:ModifyDeckForFreeSpinBigSymbol(deck)
    RedHatCustomDeck:ModifyDeckForWildAddFreeSpin(deck)
    return deck
end

function RedHatFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1
        
        local nContinueCount = 0
        local nContinueMaxCount = 0
        local nStackSymbolId = RedHatSymbol:GetCommonSymbolIdByReelId(x)
        for i = 1, cnt do
            if nContinueCount >= nContinueMaxCount then
                nStackSymbolId = RedHatSymbol:GetCommonSymbolIdByReelId(x)
                nContinueCount = 0
                nContinueMaxCount = math.max(1, 5)
            end
            nContinueCount = nContinueCount + 1
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nStackSymbolId
        end
    end
end

function RedHatFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]

    if not SlotsGameLua.m_GameResult:InFreeSpin() then
        if RedHatSymbol:isWildSymbol(nSymbolID) then
            if bResultDeck then
                local nAddFreeSpinCount = self.tableWildAddFreeSpinKeys[nDeckKey]
                local textTextMeshProAddFreeSpin = RedHatLevelUI:FindSymbolElement(go, "TextMeshProAddFreeSpin")
                textTextMeshProAddFreeSpin.text = nAddFreeSpinCount
                textTextMeshProAddFreeSpin.gameObject:SetActive(nAddFreeSpinCount > 0)
            else
                local textTextMeshProAddFreeSpin = RedHatLevelUI:FindSymbolElement(go, "TextMeshProAddFreeSpin")
                textTextMeshProAddFreeSpin.gameObject:SetActive(false)
            end
        end
    end
end  

function RedHatFunc:GetDeckFinishRandom(nReelId, nStopOffset)
    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nSymbolId = reel:GetRandom(false)
    return nSymbolId
end 

function RedHatFunc:isReelCanStartDeck(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nIndex = reel.m_nReelRow + reel.m_nAddSymbolNums -1
    local nPreID = reel.m_curSymbolIds[nIndex]
    local nPreID1 = reel.m_curSymbolIds[nIndex - 1]

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if RedHatSymbol:isCommonSymbolId(nPreID) and RedHatSymbol:isCommonSymbolId(nPreID1) then
            return true
        else
            return false
        end
    else
        return true
    end
end

function RedHatFunc:ReDeckForFreeSpinBigSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if not rt:InFreeSpin() then
        return
    end
        
    local nWild2SymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild2")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if y < SlotsGameLua.m_nRowCount - 1 then
                if RedHatSymbol:isWildSymbol(nSymbolId) then
                    deck[nKey + 1] = nWild2SymbolId
                end
            end
        end
    end     

end

function RedHatFunc:PreCheckWin()
   RedHatFunc:ReDeckForFreeSpinBigSymbol(SlotsGameLua.m_listDeck)
   SlotsGameLua:CheckWinEnd()
end

function RedHatFunc:orBonusFeatureUnlock()
    if self.m_bSimulationFlag then
        return true
    else
        return self.bBonusFeatureUnlock
    end
end

function RedHatFunc:orInBonusFeatureFull()
    return self.nCollectCount >= self:GetBonusFeatureMaxCollectCount()
end

function RedHatFunc:orBonusFreeSpinFull()
    local bFull = self:GetBonusFeatureInitFreeSpinCount() + self.nCollectFreeSpinCount >= self:GetBonusFeatureFreeSpinMaxCount()
    local nMaxCollectFreeSpinCount = self:GetBonusFeatureFreeSpinMaxCount() - self:GetBonusFeatureInitFreeSpinCount()
    return bFull, nMaxCollectFreeSpinCount
end

function RedHatFunc:GetWildSymbolCount(deck)
    local nWildCollectCount = 0
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if RedHatSymbol:isWildSymbol(nSymbolId) then
                nWildCollectCount = nWildCollectCount + 1
            end
        end 
    end

    return nWildCollectCount
end

function RedHatFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    local nReelIdCount = 0
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        nReelIdCount = nReelIdCount + 1
        local bHaveScatter = false
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if RedHatSymbol:isScatterSymbol(nSymbolId)  then
                nScatterCount = nScatterCount + 1
                bHaveScatter = true
            end
        end 

        if not bHaveScatter then
            break
        end
    end

    return nScatterCount >= 4, nScatterCount
end

function RedHatFunc:AddAverageBet()
    RedHatFunc.nSpinCount = RedHatFunc.nSpinCount + 1
    RedHatFunc.nSumTotalBetCount = RedHatFunc.nSumTotalBetCount + SceneSlotGame.m_nTotalBet
    RedHatLevelUI:setDBCollectCount()
end

function RedHatFunc:ResetAverageBet()
    RedHatFunc.nSpinCount = 0
    RedHatFunc.nSumTotalBetCount = 0
    RedHatLevelUI:setDBCollectCount()
end

function RedHatFunc:GetAverageBet()
    if self.m_bSimulationFlag then
        return SceneSlotGame.m_nTotalBet
    else
        if RedHatFunc.nSpinCount > 0 then
            local fAverageBet = RedHatFunc.nSumTotalBetCount / RedHatFunc.nSpinCount
            return fAverageBet
        else
            return SceneSlotGame.m_nTotalBet
        end
    end
end

function RedHatFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
    self:CheckWildCollect(deck, result)
end

function RedHatFunc:GetBonusFeatureFreeSpinMaxCount()
    return RedHatConfig.TABLE_BONUS_MAX_FREE_SPIN_COUNT[self.nFreeSpinFixedType]
end

function RedHatFunc:GetBonusFeatureMaxCollectCount()
    if  GameConfig.Instance.m_nThemeTestType and GameConfig.Instance.m_nThemeTestType == 2 then
        return 10
    end

    return RedHatConfig.TABLE_BONUS_MAX_COLLECT_COUNT[self.nFreeSpinFixedType]
end

function RedHatFunc:GetBonusFeatureInitFreeSpinCount()
    return RedHatConfig.TABLE_BONUS_INIT_FREECOUNT[self.nFreeSpinFixedType]
end

function RedHatFunc:CheckFreeSpin(deck, result)
    if result:InFreeSpin() then
        if not self.m_bSimulationFlag then
            RedHatLevelUI:setDBFreeSpin()
        end
    end 

    local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
    if bTrigger then
        local nFreeSpinCount = RedHatConfig:GetFreeSpinCount(nScatterCount)
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        self.tableFreeSpinStickySymbol = {}
        if not self.m_bSimulationFlag then
            RedHatLevelUI:setDBFreeSpin()
        end

        if self.m_bSimulationFlag then
            RedHatLevelUI.mLeveData_6X5:SimuActive()
            self.m_nSimuNormalFreeSpinTriggerCount = self.m_nSimuNormalFreeSpinTriggerCount + 1
        end
    end
end

function RedHatFunc:SwitchBonusFeatureFixedWildType()
    self.nFreeSpinFixedType = self.nFreeSpinFixedType + 1
    self.nFreeSpinFixedType = (self.nFreeSpinFixedType - 1) % 9 + 1
    if not self.m_bSimulationFlag then
        for k, v in pairs(RedHatLevelUI.tableBonusFeatureGoFixedWildType) do
            v:SetActive(k == self.nFreeSpinFixedType)
        end
        RedHatLevelUI:setDBCollectCount()
    end
end

function RedHatFunc:CheckWildCollect(deck, result)
    if result:InFreeSpin() then
        return
    end 

    if not RedHatFunc:orBonusFeatureUnlock() then
        return
    end 

    local bHaveWild = false
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if RedHatSymbol:isWildSymbol(nSymbolId) then
                bHaveWild = true
                self.nCollectCount = self.nCollectCount + 1
                if self.nCollectCount > self:GetBonusFeatureMaxCollectCount() then
                    self.nCollectCount = self:GetBonusFeatureMaxCollectCount()
                end

                local nAddFreeSpinCount = self.tableWildAddFreeSpinKeys[nKey]
                if nAddFreeSpinCount > 0 then
                    self.nCollectFreeSpinCount = self.nCollectFreeSpinCount + nAddFreeSpinCount
                    local bFull, nMaxCollectFreeSpinCount = self:orBonusFreeSpinFull()
                    if bFull then
                        self.nCollectFreeSpinCount = nMaxCollectFreeSpinCount
                    end
                end

                if not self.m_bSimulationFlag then
                    local goSymbol = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y]
                    local oriPos = goSymbol.transform.position
                    local targetPos = RedHatLevelUI.goCollectTarget.transform.position

                    local goEffect = RedHatLevelUI:GetEffectByEffectPool("coinEffect")
                    goEffect.transform.position = oriPos
                    goEffect:SetActive(true)

                    LeanTween.move(goEffect, targetPos, 1.0):setEaseInQuad():setOnComplete(function()
                        RedHatLevelUI:RecycleEffectToEffectPool(goEffect)
                    end)

                    if nAddFreeSpinCount > 0 then
                        local textTextMeshProAddFreeSpin = RedHatLevelUI:FindSymbolElement(goSymbol, "TextMeshProAddFreeSpin")
                        textTextMeshProAddFreeSpin.gameObject:SetActive(false)

                        local strEffectName = "ExtraSpinEffect"..nAddFreeSpinCount
                        local oriPos = textTextMeshProAddFreeSpin.transform.position
                        local targetPos = RedHatLevelUI.goCollectFreeSpinTarget.transform.position
                        local goEffect = RedHatLevelUI:GetEffectByEffectPool(strEffectName)
                        goEffect.transform.position = oriPos
                        goEffect:SetActive(true)
                        LeanTween.move(goEffect, targetPos, 1.0):setEaseInQuad():setOnComplete(function()
                            RedHatLevelUI:RecycleEffectToEffectPool(goEffect)
                        end)

                    end
                end

            end
        end
    end     

    if self:orInBonusFeatureFull() then
        local nFreeSpinCount = self:GetBonusFeatureInitFreeSpinCount() + self.nCollectFreeSpinCount
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        self.tableFreeSpinStickySymbol = LuaHelper.DeepCloneTable(RedHatConfig.TABLE_BONUS_FEATURE_FIXED_WILD_KEYS[self.nFreeSpinFixedType])
        if not self.m_bSimulationFlag then
            RedHatLevelUI.goProgressFullEffect:SetActive(true)
            RedHatLevelUI:setDBFreeSpin()
        else
            RedHatLevelUI.mLeveData_6X5:SimuActive()
            self.m_nSimuSuperFreeSpinTriggerCount = self.m_nSimuSuperFreeSpinTriggerCount + 1
        end
    end

    if not self.m_bSimulationFlag then
        if bHaveWild then
            AudioHandler:PlayThemeSound("bonusCollectionFly")
            RedHatLevelUI:setDBCollectCount()
            LeanTween.delayedCall(1.0, function()
                AudioHandler:PlayThemeSound("bonusCollected")
                RedHatLevelUI:PlayCollectProgressBarAni()

                RedHatLevelUI.goFlyEndEffect:SetActive(true)
                LeanTween.delayedCall(2.0, function()
                    RedHatLevelUI.goFlyEndEffect:SetActive(false)
                end)
            end)
        end
    end

end

function RedHatFunc:CheckSpinWinPayLines(deck, result)
    result:ResetSpin()
    if not result:InReSpin() then
        for i = 1, #SlotsGameLua.m_listLineLua do
            local iResult = {}
            local ld = SlotsGameLua:GetLine(i)
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                local nRowIndex = ld.Slots[x]
                local nKey =  x * SlotsGameLua.m_nRowCount + nRowIndex
                iResult[x] = deck[nKey]
            end

            local MatchCount = 0
            local nMaxMatchReelID = 0
            local bcond2 = false
            local nAwardMultuile = -1

            local bWildMatchSuccess = false
            local bIdMatchSuccess = false
            local bAnySymbolMatchSuccess = false

            local nSymbolId = -1
            local bMatchSuccess = false
            if not bMatchSuccess then
                bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = self:CheckLineSymbolIdSame(iResult)
                if bMatchSuccess then
                    bIdMatchSuccess = true
                    
                    --Debug.Log("ID 匹配成功")
                end
            end

            if not bMatchSuccess then
                bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = self:CheckLineWildMatch(iResult)
                if bMatchSuccess then
                    bWildMatchSuccess = true
                    
                    --Debug.Log("Wild 匹配成功")
                end
            end 

            local fCombReward = -1
            local nCombIndex = -1
            if bWildMatchSuccess or bIdMatchSuccess then
                fCombReward = SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount]
            end

            if fCombReward > 0.0 then
                self.m_nWin0Count = 0
                local nTotalBet = SceneSlotGame.m_nTotalBet
                local fLineBet = nTotalBet / #SlotsGameLua.m_listLineLua
                local LineWin = fCombReward * fLineBet
                table.insert(result.m_listWins, WinItem:create(i, nSymbolId, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if self.m_bSimulationFlag then  
                    if result.m_listTestWinSymbols[nSymbolId] == nil then
                        result.m_listTestWinSymbols[nSymbolId] = TestWinItem:create(nSymbolId)
                    end

                    result.m_listTestWinSymbols[nSymbolId].Hit = result.m_listTestWinSymbols[nSymbolId].Hit + 1
                    result.m_listTestWinSymbols[nSymbolId].WinGold = result.m_listTestWinSymbols[nSymbolId].WinGold + LineWin
                end

                if not self.m_bSimulationFlag then
                    self:refreshHitSymbols(i, nMaxMatchReelID)
                end
            end 
        end 
    end 
    
    self:CheckGameResult(deck, result)
    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        if self.m_bSimulationFlag then
            if self:orInBonusFeatureFull() then
                self.m_nSimuSuperFreeSpinWinMoneyCount = self.m_nSimuSuperFreeSpinWinMoneyCount + result.m_fSpinWin
            else
                self.m_nSimuNormalFreeSpinWinMoneyCount = self.m_nSimuNormalFreeSpinWinMoneyCount + result.m_fSpinWin
            end

            if not result:HasFreeSpin() then
                RedHatLevelUI.mLeveData_3X5:SimuActive()
                if self:orInBonusFeatureFull() then
                    RedHatFunc.nCollectCount = 0
                    RedHatFunc.nCollectFreeSpinCount = 0
                    RedHatFunc:SwitchBonusFeatureFixedWildType()
                    RedHatFunc.tableFreeSpinStickySymbol = {}
                end
            end
        end
    end     

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--检查Wild 匹配
function RedHatFunc:CheckLineWildMatch(iResult)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end     
    
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = -1
    if rt:InFreeSpin() then
        nSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild2")
    else
        nSymbolId = SlotsGameLua:GetSymbolIdByObjName("WildCoin")
    end

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if RedHatSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i

            if i == 1 then
                nSymbolId = v
            end
        else
            break
        end
    end     

    if MatchCount > 0 and nSymbolId > 0 and SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount] > 0  then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end

end 

--检查ID 是否相同
function RedHatFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if RedHatSymbol:IsNoLineAwardSymbolId(v) then
            break
        end
            
        if not RedHatSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if RedHatSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if nSymbolId > 0 and MatchCount > 0 and SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount] > 0  then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end 

end

--仿真，把结果 输入到文本文件中
function RedHatFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function RedHatFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount
    self.m_nSimuReSpinCount = 0
    self.m_nSimuFreeSpinCount = 0

    self.m_nSimuNormalFreeSpinTriggerCount = 0 
    self.m_nSimuNormalFreeSpinCount = 0
    self.m_nSimuNormalFreeSpinWinMoneyCount = 0

    self.m_nSimuSuperFreeSpinTriggerCount = 0 
    self.m_nSimuSuperFreeSpinCount = 0
    self.m_nSimuSuperFreeSpinWinMoneyCount = 0

    local prenCollectCount = RedHatFunc.nCollectCount
    local prenCollectFreeSpinCount = RedHatFunc.nCollectFreeSpinCount
    local prenFreeSpinFixedType = RedHatFunc.nFreeSpinFixedType
    RedHatFunc.nCollectCount = 0
    RedHatFunc.nCollectFreeSpinCount = 0
    RedHatFunc.nFreeSpinFixedType = 0
    self:SwitchBonusFeatureFixedWildType()

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

            if self:orInBonusFeatureFull() then
                self.m_nSimuSuperFreeSpinCount = self.m_nSimuSuperFreeSpinCount + 1
            else
                self.m_nSimuNormalFreeSpinCount = self.m_nSimuNormalFreeSpinCount + 1
            end
        end

        local iDeck = self:GetDeck()
        self:ReDeckForFreeSpinBigSymbol(iDeck)
        rt = self:CheckSpinWinPayLines(iDeck, rt)

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
    
    RedHatFunc.nCollectCount = prenCollectCount
    RedHatFunc.nCollectFreeSpinCount = prenCollectFreeSpinCount
    RedHatFunc.nFreeSpinFixedType = prenFreeSpinFixedType
    RedHatLevelUI.mLeveData_3X5:SimuActive()

end 

function RedHatFunc:WriteToFile()
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
    strFile = strFile.."Normal FreeSpin 触发次数: "..self.m_nSimuNormalFreeSpinTriggerCount.."\n"
    strFile = strFile.."Normal FreeSpin 次数: "..self.m_nSimuNormalFreeSpinCount.."\n"
    strFile = strFile.."Normal FreeSpin 总赢钱数: "..self.m_nSimuNormalFreeSpinWinMoneyCount.."\n"
    strFile = strFile .. "\n"
    strFile = strFile.."Super FreeSpin 触发次数: "..self.m_nSimuSuperFreeSpinTriggerCount.."\n"
    strFile = strFile.."Super FreeSpin 次数: "..self.m_nSimuSuperFreeSpinCount.."\n"
    strFile = strFile.."Super FreeSpin 总赢钱数: "..self.m_nSimuSuperFreeSpinWinMoneyCount.."\n"

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
function RedHatFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = RedHatLevelUI
end

