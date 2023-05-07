require("Lua/ThemeVideo/Pixie/PixieConfig")
require("Lua/ThemeVideo/Pixie/PixieCustomDeck")
require("Lua/ThemeVideo/Pixie/PixieSymbol")
require("Lua/ThemeVideo/Pixie/PixieLevelUI")

PixieFunc = {}

function PixieFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.tableBigSymbol = {}
    self.tableFreeSpinStickyBigSymbol = {}
    self.nFreeSpinSelectBigSymbolId = -1

    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}
end 

function PixieFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function PixieFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()
    PixieLevelUI.mDeckResultPayLines:MatchLineHide()

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            if PixieLevelUI.tableFixedGoSymbol[x] and PixieLevelUI.tableFixedGoSymbol[x][y] then
                local goFixedSymbol = PixieLevelUI.tableFixedGoSymbol[x][y]
                Debug.Assert(PixieLevelUI.tableCachePos[x][y], "PixieLevelUI.tableCachePos[x][y] == nil")
                goFixedSymbol.transform.position = PixieLevelUI.tableCachePos[x][y]
            end
        end
    end
    
end

function PixieFunc:OnSpinEnd()
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            if PixieLevelUI.tableFixedGoSymbol[x] and PixieLevelUI.tableFixedGoSymbol[x][y] then
                local goFixedSymbol = PixieLevelUI.tableFixedGoSymbol[x][y]
                goFixedSymbol.transform.position = Unity.Vector3(990000, 0, 0)
            end
        end
    end
end 

function PixieFunc:GetDeck()
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

    PixieCustomDeck:ModifyDeckForWild(deck)
    PixieCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    PixieCustomDeck:ModifyDeckForBigSymbol(deck)
    return deck
end

function PixieFunc:CreateReelRandomSymbolList()
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")

    local cnt = 100
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1
        
        local nContinueCount = 0
        local nContinueMaxCount = 0
        local bHaveScatter = false
        local nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
        for i = 1, cnt do
            if nContinueCount >= nContinueMaxCount then
                nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                nContinueCount = 0
                nContinueMaxCount = math.max(1, 5)
            end
            nContinueCount = nContinueCount + 1

            if PixieSymbol:isBigSymbol(nStackSymbolId) then
                for j = 1, 4 do
                    local nSymbolId1 = SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - j]
                    if PixieSymbol:isBigSymbol(nSymbolId1) then
                        nStackSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(x)
                    end 
                end
            end

            if PixieSymbol:isBigSymbol(nStackSymbolId) then
                for j = 1, 3 do
                    if i - j >= 1 then
                        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - j] = nNullSymbolId
                    end
                end
            end

            if PixieSymbol:isScatterSymbol(nStackSymbolId) then
                if bHaveScatter then
                    nStackSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(x)
                else
                    bHaveScatter = true
                end
            end

            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nStackSymbolId
        end
    end

end

function PixieFunc:GetDeckFinishRandom(nReelId, nStopOffset)
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")

    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nSymbolId = reel:GetRandom(false)
    if PixieSymbol:isBigSymbol(nSymbolId) or nSymbolId == nNullSymbolId then
        nSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(nReelId)
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

function PixieFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]

    if PixieSymbol:isBigSymbol(nSymbolID) then
        PixieLevelUI:SetModifyLayer(go, -26)
        
        if SlotsGameLua.m_GameResult:InFreeSpin() then
            if self.tableFreeSpinStickyBigSymbol[nReelID] then
                local goWildInfo = PixieLevelUI:FindSymbolElement(go, "wildInfo")
                goWildInfo:SetActive(true)
            else
                local goWildInfo = PixieLevelUI:FindSymbolElement(go, "wildInfo")
                goWildInfo:SetActive(false)
            end
        else
            local goWildInfo = PixieLevelUI:FindSymbolElement(go, "wildInfo")
            goWildInfo:SetActive(false)
        end
    end
    
end  

function PixieFunc:isReelCanStartDeck(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nIndex = reel.m_nReelRow + reel.m_nAddSymbolNums -1
    local nPreID = reel.m_curSymbolIds[nIndex]

    if PixieSymbol:isCommonSymbolId(nPreID) then
        return true
    end

    return false
end

function PixieFunc:PreCheckWin()
    local fAniTime = PixieFunc:CheckWild(SlotsGameLua.m_listDeck)
    LeanTween.delayedCall(fAniTime, function()
        SlotsGameLua:CheckWinEnd()
        PixieLevelUI.mDeckResultPayLines:InitMatchLineShow()
    end)
end

function PixieFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    for i = 2, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if PixieSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    return nScatterCount == 3, nScatterCount
end

function PixieFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
end

function PixieFunc:CheckFreeSpin(deck, result)
    if result:InFreeSpin() then
        for nReelId = 0, SlotsGameLua.m_nReelCount - 1 do
            if (not PixieFunc.tableFreeSpinStickyBigSymbol[nReelId]) and PixieFunc.tableBigSymbol[nReelId] then
                local nRowIndex = PixieFunc.tableBigSymbol[nReelId][1]
                local nSymbolId = PixieFunc.tableBigSymbol[nReelId][2]
                if nSymbolId == PixieFunc.nFreeSpinSelectBigSymbolId then
                    self.tableFreeSpinStickyBigSymbol[nReelId] = {nRowIndex, nSymbolId}
                    if not self.m_bSimulationFlag then
                        local goFixedSymbol = PixieLevelUI:FixedBigSymbol(nSymbolId, nReelId, nRowIndex)
                        goFixedSymbol.transform.localPosition = Unity.Vector3(990000, 0, 0)
                    end
                end
            end
        end
        
        if not self.m_bSimulationFlag then
            PixieLevelUI:setDBFreeSpin()
        end
    else
        local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
        if bTrigger then
            local nFreeSpinCount = PixieConfig:GetFreeSpinCount(nScatterCount)
            result.m_nNewFreeSpinCount = nFreeSpinCount
            result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

            self.nFreeSpinSelectBigSymbolId = -1
            self.tableFreeSpinStickyBigSymbol = {}

            if not self.m_bSimulationFlag then
                PixieLevelUI:setDBFreeSpin()
            end

            if self.m_bSimulationFlag then
                self.nFreeSpinSelectBigSymbolId = PixieFunc:GetRandomBigSymbolId()
                self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
            end
        end
    end

end

function PixieFunc:GetRandomBigSymbolId()
    local tableSymbolRate = {1, 1, 1, 1}
    local nIndex = LuaHelper.GetIndexByRate(tableSymbolRate)
    if nIndex == 1 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieBlueA_1")
    elseif nIndex == 2 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieGreenB_1")
    elseif nIndex == 3 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieRedC_1")
    elseif nIndex == 4 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieYellowD_1")
    else
        Debug.Assert(false)
    end
end

function PixieFunc:CheckWild(deck)
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")

    local bHaveWild = false
    local nReekId = 4
    for y = 0, SlotsGameLua.m_nRowCount - 1 do
        local nKey = SlotsGameLua.m_nRowCount * nReekId + y
        local nSymbolId = deck[nKey]
        if PixieSymbol:isWildSymbol(nSymbolId) then
            bHaveWild = true
        end
    end

    local fAniTime = 0.0
    if bHaveWild then
        local bHaveBigSymbol = false
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            if self.tableBigSymbol[i] then
                bHaveBigSymbol = true
                local nReelId = i
                local nTargetIndex = self.tableBigSymbol[i][1]
                local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
                local nStackEndIndex = math.max(0, nTargetIndex - 2)
                for j = nStackBeginIndex, nStackEndIndex, -1 do
                    local nKey = nReelId * SlotsGameLua.m_nRowCount + j
                    deck[nKey] = nWildSymbolId
                end
            end
        end 

        if not self.m_bSimulationFlag and bHaveBigSymbol then
            fAniTime = 3.0
            local goFlyEffect = PixieLevelUI:GetEffectByEffectPool("TXWildFly")
            goFlyEffect:SetActive(true)
            LeanTween.delayedCall(3.0, function()
                PixieLevelUI:RecycleEffectToEffectPool(goFlyEffect)
            end)    

            for i = SlotsGameLua.m_nReelCount - 1, 0, -1 do
                local nIndex = SlotsGameLua.m_nReelCount - 1 - i
                LeanTween.delayedCall(nIndex * 0.6, function()
                    if self.tableBigSymbol[i] then
                        local nReelId = i
                        local nTargetIndex = self.tableBigSymbol[i][1]
                        local goSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nTargetIndex]
                        local goWildInfo = PixieLevelUI:FindSymbolElement(goSymbol, "wildInfo")
                        goWildInfo:SetActive(true)
                        CoroutineHelper.waitForEndOfFrame(function()
                            PixieLevelUI:SetModifyLayer(goSymbol, -26, true)
                        end)
                    end
                end)
            end
        end
    end
    
    return fAniTime
end

function PixieFunc:CheckSpinWinPayLines(deck, result)
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
            self.m_nSimuFreeSpinWinMoneyCount = self.m_nSimuFreeSpinWinMoneyCount + result.m_fSpinWin
        end
    end     

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--检查Wild 匹配
function PixieFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1
    
    local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if PixieSymbol:isWildSymbol(v) then
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
function PixieFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if PixieSymbol:IsNoLineAwardSymbolId(v) then
            break
        end
            
        if not PixieSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if PixieSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
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
function PixieFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function PixieFunc:GetTestResultByRate()
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
        self:CheckWild(iDeck)
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
end 

function PixieFunc:WriteToFile()
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
function PixieFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = PixieLevelUI
end

