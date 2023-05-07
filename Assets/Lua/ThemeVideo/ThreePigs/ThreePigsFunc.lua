require("Lua/ThemeVideo/ThreePigs/ThreePigsConfig")
require("Lua/ThemeVideo/ThreePigs/ThreePigsCustomDeck")
require("Lua/ThemeVideo/ThreePigs/ThreePigsSymbol")
require("Lua/ThemeVideo/ThreePigs/ThreePigsLevelUI")

ThreePigsFunc = {}

function ThreePigsFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.nCollectCount = 0
    self.nSelectFreeSpinType = 0

    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}
end 

function ThreePigsFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function ThreePigsFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()

    for k, v in pairs(ThreePigsLevelUI.tableCollectEffect) do
        ThreePigsLevelUI:RecycleEffectToEffectPool(v)
    end
    ThreePigsLevelUI.tableCollectEffect = {}

    if not SlotsGameLua.m_GameResult:InReSpin() and not SlotsGameLua.m_GameResult:InFreeSpin() then
        local bNeedResetJackPotValue = false
        for i = 1, #self.tableNowbGetJackPot do
            if self.tableNowbGetJackPot[i] then
                bNeedResetJackPotValue = true
                break
            end
        end         

        if bNeedResetJackPotValue then
            ThreePigsLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            for i = 1, #self.tableNowbGetJackPot do
                self.tableNowbGetJackPot[i] = false
            end
        end
    end

end

function ThreePigsFunc:OnSpinEnd()
end

function ThreePigsFunc:GetDeck()
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
    
    ThreePigsCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    return deck
end

function ThreePigsFunc:CreateReelRandomSymbolList()
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

function ThreePigsFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]
end     

function ThreePigsFunc:PreCheckWin()
    local fAniTime = ThreePigsFunc:CheckPigChangeToWild(SlotsGameLua.m_listDeck, SlotsGameLua.m_GameResult)
    LeanTween.delayedCall(fAniTime, function()
        SlotsGameLua:CheckWinEnd()
    end)
end

function ThreePigsFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if ThreePigsSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    return nScatterCount == 3
end

function ThreePigsFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
    self:CheckPigCollect(deck, result)
end

function ThreePigsFunc:CheckPigChangeToWild(deck, result)
    if not result:InFreeSpin() then
        return 0.0
    end

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")
    local nRedPigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig1")
    local nGreenPigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig2")
    local nBluePigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig3")

    local bHaveChangeWildAni = false
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]

            local bNeedChangeToWild = false
            if self.nSelectFreeSpinType == 1 then
                if nSymbolId == nRedPigSymbolId then
                    bNeedChangeToWild = true
                    deck[nKey] = nWildSymbolId
                end
            elseif self.nSelectFreeSpinType == 2 then
                if nSymbolId == nRedPigSymbolId or nSymbolId == nBluePigSymbolId then
                    bNeedChangeToWild = true
                    deck[nKey] = nWildSymbolId
                end
            elseif self.nSelectFreeSpinType == 3 then
                if nSymbolId == nRedPigSymbolId or nSymbolId == nGreenPigSymbolId or nSymbolId == nBluePigSymbolId then
                    bNeedChangeToWild = true
                    deck[nKey] = nWildSymbolId
                end
            end

            if bNeedChangeToWild then
                bHaveChangeWildAni = true
                if not self.m_bSimulationFlag then
                    local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                    SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j] = nil
                    LeanTween.scale(goSymbol, Unity.Vector3.zero, 0.6):setOnComplete(function()
                        SymbolObjectPool:Unspawn(goSymbol)
                    end)

                    local goWildSymbol = ThreePigsLevelUI:FillSymbol(nWildSymbolId, i, j)
                    goWildSymbol.transform.localScale = Unity.Vector3.zero
                    LeanTween.scale(goWildSymbol, Unity.Vector3.one, 0.6)
                end
            end

        end
    end

    if bHaveChangeWildAni then
        return 1.0
    else
        return 0.0
    end
end

function ThreePigsFunc:CheckPigCollect(deck, result)
    if result:InFreeSpin() then
        return
    end

    local nRedPigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig1")
    local nGreenPigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig2")
    local nBluePigSymbolId = SlotsGameLua:GetSymbolIdByObjName("pig3")

    local bHaveRedPig = false
    local bHaveGreenPig = false
    local bHaveBluePig = false
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if nSymbolId == nRedPigSymbolId then
                bHaveRedPig = true
            elseif nSymbolId == nGreenPigSymbolId then
                bHaveGreenPig = true
            elseif nSymbolId == nBluePigSymbolId then
                bHaveBluePig = true
            end
        end
    end 

    if bHaveRedPig and bHaveGreenPig and bHaveBluePig then
        self.nCollectCount = self.nCollectCount + 1
        if self.nCollectCount >= ThreePigsConfig.N_COLLECT_MAX_COUNT then
            if not self.m_bSimulationFlag then
                ThreePigsLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            end

            local nJackPotIndex = 1
            self.tableNowbGetJackPot[nJackPotIndex] = true
            self.tableNowJackPotMoneyCount[nJackPotIndex] = ThreePigsLevelUI.mJackPotUI:GetTotalJackPotValue(nJackPotIndex)

            local nAddJackPotMoneyCount = self.tableNowJackPotMoneyCount[nJackPotIndex]
            ThreePigsLevelUI.mJackPotUI:ResetCurrentJackPot(nJackPotIndex)
            self.nCollectCount = 0
            result.m_fSpinWin = result.m_fSpinWin + nAddJackPotMoneyCount

            if not self.m_bSimulationFlag then
                SlotsGameLua.m_bSplashFlags[SplashType.Jackpot] = true
            else
                self.m_nSimuJackPotTriggerCount = self.m_nSimuJackPotTriggerCount + 1
                self.m_nSimuJackPotTriggerMoneyCount = self.m_nSimuJackPotTriggerMoneyCount + nAddJackPotMoneyCount
            end
        end

        if not self.m_bSimulationFlag then
            ThreePigsLevelUI:setDBCollectCount()
            SlotsGameLua.m_bAnimationTime = true
            for i = 0, SlotsGameLua.m_nReelCount - 1 do
                for j = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = i * SlotsGameLua.m_nRowCount + j
                    local nSymbolId = deck[nKey]
                    if nSymbolId == nRedPigSymbolId or nSymbolId == nGreenPigSymbolId or nSymbolId == nBluePigSymbolId then
                        local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                        local pos = goSymbol.transform.position
                        
                        local goEffect1 = ThreePigsLevelUI:GetEffectByEffectPool("preCollectEffect")
                        goEffect1.transform.position = pos
                        goEffect1:SetActive(true)
                        table.insert(ThreePigsLevelUI.tableCollectEffect, goEffect1)

                        local obj = Unity.Object.Instantiate(ThreePigsLevelUI.goLinePrefab)
                        obj.transform:SetParent(ThreePigsLevelUI.goLinePrefab.transform.parent, false)
                        obj.transform.position = pos

                        local XXX = Unity.Vector3(SlotsGameLua.m_fCentBoardX, SlotsGameLua.m_fCentBoardY, 0) - pos
                        local fZAngle = 0
                        if XXX.x == 0 then
                            if XXX.y >= 0 then
                                fZAngle =  90
                            else
                                fZAngle =  -90
                            end
                        else
                            fZAngle = math.abs(math.atan(XXX.y / XXX.x) / math.pi * 180)
                            if XXX.x >= 0 then
                                if XXX.y >= 0 then
                                    fZAngle =  fZAngle
                                else
                                    fZAngle =  -fZAngle
                                end
                            else
                                if XXX.y >= 0 then
                                    fZAngle =  180 - fZAngle
                                else
                                    fZAngle =  -(180 - fZAngle)
                                end
                            end
                        end

                        obj.transform.localEulerAngles = Unity.Vector3(0, 0, fZAngle)
                        local fScaleX = math.sqrt(XXX.x * XXX.x + XXX.y * XXX.y) / SlotsGameLua.m_fSymbolWidth
                        obj.transform.localScale = Unity.Vector3(0, 1, 1)
                        obj:SetActive(true)

                        LeanTween.value(0.0, fScaleX, 0.6):setOnUpdate(function(fValue)
                            obj.transform.localScale = Unity.Vector3(fValue, 1, 1)
                        end):setOnComplete(function()
                            Unity.Object.Destroy(obj)
                        end)
                    end 
                end
            end

            LeanTween.delayedCall(0.0, function()
                local goEffect1 = ThreePigsLevelUI:GetEffectByEffectPool("CollectPigEffect")
                goEffect1:SetActive(true)
                LeanTween.delayedCall(1.5, function()
                    ThreePigsLevelUI:UpdateCollectInfo()
                end)

                LeanTween.delayedCall(2.0, function()
                    ThreePigsLevelUI:RecycleEffectToEffectPool(goEffect1)
                end)

                LeanTween.delayedCall(1.0, function()
                    SlotsGameLua.m_bAnimationTime = false
                end)
            end)
        end
    end 

end 

function ThreePigsFunc:CheckFreeSpin(deck, result)
    local bTrigger = self:bCanTriggerFreeSpin(deck)
    if bTrigger then
        if result:InFreeSpin() then
            local nFreeSpinCount = ThreePigsFunc:GetFreeSpinCount()
            result.m_nNewFreeSpinCount = result.m_nNewFreeSpinCount + nFreeSpinCount
            result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

            if self.m_bSimulationFlag then
                self.m_nSimuFreeSpinAgainTriggerCount = self.m_nSimuFreeSpinAgainTriggerCount + 1
            end
        else
            if not self.m_bSimulationFlag then
                SlotsGameLua.m_bSplashFlags[SplashType.FreeSpin] = true
            else
                self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
                ThreePigsFunc:SetFreeSpin(math.random(1, 3))
            end
        end
    end
end

function ThreePigsFunc:GetFreeSpinCount()
    local nFreeSpinCount = 0
    if self.nSelectFreeSpinType == 1 then
        nFreeSpinCount = 20
    elseif self.nSelectFreeSpinType == 2 then
        nFreeSpinCount = 10
    elseif self.nSelectFreeSpinType == 3 then
        nFreeSpinCount = 5
    else
        Debug.Assert(false)
    end
    return nFreeSpinCount
end

function ThreePigsFunc:SetFreeSpin(nSelectFreeSpinType)
    local rt = SlotsGameLua.m_GameResult
    if ThreePigsFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 
    
    self.nSelectFreeSpinType = nSelectFreeSpinType
    local nFreeSpinCount = ThreePigsFunc:GetFreeSpinCount()
    rt.m_nFreeSpinTotalCount = rt.m_nFreeSpinTotalCount + nFreeSpinCount
    if not self.m_bSimulationFlag then
        ThreePigsLevelUI:setDBCollectCount()
        LevelDataHandler:addNewFreeSpinCount(ThemeLoader.themeKey, nFreeSpinCount)
        LevelDataHandler:addTotalFreeSpinCount(ThemeLoader.themeKey, nFreeSpinCount)
    end

end

function ThreePigsFunc:CheckSpinWinPayLines(deck, result)
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
function ThreePigsFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if ThreePigsSymbol:isWildSymbol(v) then
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
function ThreePigsFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if ThreePigsSymbol:IsNoLineAwardSymbolId(v) then
            break
        end
            
        if not ThreePigsSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if ThreePigsSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
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
function ThreePigsFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function ThreePigsFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount

    self.m_nSimuFreeSpinTriggerCount = 0 
    self.m_nSimuFreeSpinAgainTriggerCount = 0 
    self.m_nSimuFreeSpinCount = 0
    self.m_nSimuFreeSpinWinMoneyCount = 0
    
    self.m_nSimuJackPotTriggerCount = 0 
    self.m_nSimuJackPotTriggerMoneyCount = 0

    local pretableJackPotAddSumMoneyCount = ThreePigsLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount
    ThreePigsLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = {0}
    
    local prenCollectCount = ThreePigsFunc.nCollectCount
    ThreePigsFunc.nCollectCount = 0

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
        self:CheckPigChangeToWild(iDeck, rt)
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
    ThreePigsLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = pretableJackPotAddSumMoneyCount
    ThreePigsFunc.nCollectCount = prenCollectCount

end 

function ThreePigsFunc:WriteToFile()
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
    strFile = strFile.."FreeSpin Begin 触发次数: "..self.m_nSimuFreeSpinTriggerCount.."\n"
    strFile = strFile.."FreeSpin Again 触发次数: "..self.m_nSimuFreeSpinAgainTriggerCount.."\n"
    strFile = strFile.."FreeSpin 次数: "..self.m_nSimuFreeSpinCount.."\n"
    strFile = strFile.."FreeSpin 总赢钱数: "..self.m_nSimuFreeSpinWinMoneyCount.."\n"
    strFile = strFile .. "\n"
    
    strFile = strFile.."JackPot 触发次数: "..self.m_nSimuJackPotTriggerCount.."\n"
    strFile = strFile.."JackPot 总赢钱数: "..self.m_nSimuJackPotTriggerMoneyCount.."\n"

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
function ThreePigsFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = ThreePigsLevelUI
end

