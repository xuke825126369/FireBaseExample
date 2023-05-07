require("Lua/ThemeVideo/Arab/ArabConfig")
require("Lua/ThemeVideo/Arab/ArabCustomDeck")
require("Lua/ThemeVideo/Arab/ArabSymbol")
require("Lua/ThemeVideo/Arab/ArabLevelUI")

ArabFunc = {}
function ArabFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.nCollectGemCount = 0
    self.tableGemInfo = {}

    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}
end 

function ArabFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function ArabFunc:OnStartSpin()
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
            ArabLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            for i = 1, #self.tableNowbGetJackPot do
                self.tableNowbGetJackPot[i] = false
            end
        end
    end

end

function ArabFunc:OnSpinEnd()
end

function ArabFunc:GetDeck()
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
    
    ArabCustomDeck:ModifyDeckForStackSymbol(deck)
    ArabCustomDeck:ModifyDeckForWin0(deck)
    ArabCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    ArabCustomDeck:ModifyDeckForGemSymbol(deck)
    return deck
end

function ArabFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local nContinueCount = 0
        local nContinueMaxCount = 0
        local nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
        for i = 1, cnt do
            if nContinueCount >= nContinueMaxCount then
                nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                nContinueCount = 0
                nContinueMaxCount = math.max(1, 10)
            end

            nContinueCount = nContinueCount + 1
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nStackSymbolId
        end
    end
end

function ArabFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]

    if ArabSymbol:isWildSymbol(nSymbolID) then
        if bResultDeck then
            local nTriggerType = self.tableGemInfo[nDeckKey][1]
            local nMultuile = self.tableGemInfo[nDeckKey][2]
            ArabLevelUI:RefreshCollectSymbol(go, nTriggerType, nMultuile)
        else
            local nTriggerType = math.random(1, 3)
            local nMultuile = 0
            if math.random() < 0.5 then
                local nIndex = math.random(1, #ArabConfig.TABLE_GEM_MONEY_MULTUILE)
                nMultuile = ArabConfig.TABLE_GEM_MONEY_MULTUILE[nIndex]
            end

            ArabLevelUI:RefreshCollectSymbol(go, nTriggerType, nMultuile)
        end
    end

end     

function ArabFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function ArabFunc:bCanTriggerWildStack(deck)
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if nSymbolId == nWildSymbolId then
                return true
            end
        end
    end

    return false
end

function ArabFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    for i = 1, 3 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if ArabSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
            end
        end
    end
    return nScatterCount == 12
end

function ArabFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
    self:CheckGemCollect(deck, result)
end

function ArabFunc:CheckGemCollect(deck, result)
    if result:InFreeSpin() then
        return
    end

    for i = 1, 3 do
        self.tableNowbGetJackPot[i] = false
        self.tableNowJackPotMoneyCount[i] = ArabLevelUI.mJackPotUI:GetTotalJackPotValue(i)
    end

    local nGemCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if ArabSymbol:isWildSymbol(nSymbolId) then
                local nGemType = self.tableGemInfo[nKey][1]
                nGemCount = nGemCount + nGemType

                if not self.m_bSimulationFlag then
                    local goEffect = nil
                    if nGemType == 1 then
                        goEffect = ArabLevelUI:GetEffectByEffectPool("gem1CollectEffect")
                    elseif nGemType == 2 then
                        goEffect = ArabLevelUI:GetEffectByEffectPool("gem2CollectEffect")
                    elseif nGemType == 3 then
                        goEffect = ArabLevelUI:GetEffectByEffectPool("gem3CollectEffect")
                    end

                    goEffect:SetActive(true)
                    local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                    goEffect.transform.position = goSymbol.transform.position
                    goEffect.transform.localScale = Unity.Vector3.one * 1.1
                    
                    AudioHandler:PlayThemeSound("bonusCollectionFly")
                    LeanTween.move(goEffect, ArabLevelUI.goGenFlyEndPos.transform.position, 0.6)
                    LeanTween.scale(goEffect, Unity.Vector3.one * 0.3, 0.6)
                    LeanTween.delayedCall(0.7, function()
                        ArabLevelUI:RecycleEffectToEffectPool(goEffect)
                        AudioHandler:PlayThemeSound("bonusCollected")
                    end)
                end

            end
        end
    end

    self.nCollectGemCount = self.nCollectGemCount + nGemCount
    if self.nCollectGemCount >= ArabConfig.N_MAX_COLLECT_GEM_COUNT then
        if not self.m_bSimulationFlag then
            SlotsGameLua.m_bSplashFlags[SplashType.Bonus] = true
        else
            self.n_nSimuCollectGemFullCount = self.n_nSimuCollectGemFullCount + 1

            self.tableCollectGemType = {}
            while true do
                local nGemType = ArabConfig:GetBonusGameTriggerGemType()
                if not self.tableCollectGemType[nGemType] then
                    self.tableCollectGemType[nGemType] = 0
                end
                self.tableCollectGemType[nGemType] = self.tableCollectGemType[nGemType] + 1

                if self.tableCollectGemType[nGemType] >= 3 then
                    local fAddMoneyCount = ArabFunc.tableNowJackPotMoneyCount[nGemType]
                    ArabLevelUI.mJackPotUI:ResetCurrentJackPot(nGemType)
                    result.m_fSpinWin = result.m_fSpinWin + fAddMoneyCount
                    self.nCollectGemCount = 0

                    self.n_nSimuBonusGameWinMoneyCount = self.n_nSimuBonusGameWinMoneyCount + fAddMoneyCount
                    break
                end
            end
        end
    end     

    if not self.m_bSimulationFlag then
        ArabLevelUI:setDBCollectGemCount()

        LeanTween.delayedCall(1.0, function()
            AudioHandler:PlayThemeSound("bonusCollectionFilled")
            ArabLevelUI:PlayGemProgressAni()
        end)
    end

end 

function ArabFunc:CheckFreeSpin(deck, result)
    if result:InFreeSpin() then

    else
        local bTrigger = self:bCanTriggerFreeSpin(deck)
        if bTrigger then
            local nFreeSpinCount = 8
            result.m_nNewFreeSpinCount = nFreeSpinCount
            result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

            if self.m_bSimulationFlag then
                self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
            end
        end
    end

end

function ArabFunc:CheckSpinWinPayLines(deck, result)
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

                for x = 0, MatchCount - 1 do
                    local nRowIndex = ld.Slots[x]
                    local nKey = x * SlotsGameLua.m_nRowCount + nRowIndex
                    local nSymbolId = deck[nKey]
                    if ArabSymbol:isWildSymbol(nSymbolId) then
                        local nMultuile = self.tableGemInfo[nKey][2]
                        if nMultuile > 0 then
                            local nMoneyCount = SceneSlotGame.m_nTotalBet * nMultuile
                            LineWin = LineWin + nMoneyCount
                        end
                    end
                end

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
            self.m_nSimuFreeSpinWinMoneyCount = self.m_nSimuFreeSpinWinMoneyCount + result.m_fSpinWin
        end
    end     
    
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--检查Wild 匹配
function ArabFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = -1
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if ArabSymbol:isWildSymbol(v) then
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
function ArabFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if ArabSymbol:IsNoLineAwardSymbolId(v) then
            break
        end
            
        if not ArabSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if ArabSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
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
function ArabFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function ArabFunc:GetTestResultByRate()
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

    self.n_nSimuCollectGemFullCount = 0
    self.n_nSimuBonusGameWinMoneyCount = 0

    local pretableJackPotAddSumMoneyCount = ArabLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount
    ArabLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = {0, 0, 0}
    local preCollectGemCount = self.nCollectGemCount
    self.nCollectGemCount = 0

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

        if not bFreeSpinFlag then
            ArabLevelUI.mJackPotUI:addJackPotValue()
        end
        
        local iDeck = self:GetDeck()
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

    ArabLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = pretableJackPotAddSumMoneyCount
    self.nCollectGemCount = preCollectGemCount

end 

function ArabFunc:WriteToFile()
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
    strFile = strFile.."BonusGame 次数: "..self.n_nSimuCollectGemFullCount.."\n"
    strFile = strFile.."BonusGame 总赢钱数: "..self.n_nSimuBonusGameWinMoneyCount.."\n"
    strFile = strFile .. "\n"
    
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
function ArabFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = ArabLevelUI
end

