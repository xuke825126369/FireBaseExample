require("Lua/ThemeVideo/LuckyVegas/LuckyVegasConfig")
require("Lua/ThemeVideo/LuckyVegas/LuckyVegasSymbol")
require("Lua/ThemeVideo/LuckyVegas/LuckyVegasLevelUI")
require("Lua/ThemeVideo/LuckyVegas/LuckyVegasCustomDeck")

LuckyVegasFunc = {}

function LuckyVegasFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.nCollectGemCount = 0
    self.tableGemInfo = {}
    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}

    ---------------- 仿真相关 --------------------
    self.tableSimuJackPotInfo = {}

end 

function LuckyVegasFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function LuckyVegasFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()

    for k, v in pairs(LuckyVegasLevelUI.tableGoJackPotEffect) do
        v:SetActive(false)
    end

    if not SlotsGameLua.m_GameResult:InReSpin() and not SlotsGameLua.m_GameResult:InFreeSpin() then
        local bNeedResetJackPotValue = false
        for i = 1, #self.tableNowbGetJackPot do
            if self.tableNowbGetJackPot[i] then
                bNeedResetJackPotValue = true
                LuckyVegasLevelUI.mJackPotUI:ResetCurrentJackPot(i)
            end
        end         

        if bNeedResetJackPotValue then
            LuckyVegasLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            for i = 1, #self.tableNowbGetJackPot do
                self.tableNowbGetJackPot[i] = false
            end
        end
    end

end

function LuckyVegasFunc:OnSpinEnd()

end

function LuckyVegasFunc:GetDeck()
    local deck = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            deck[nKey] = nSymbolID
        end
    end

    LuckyVegasCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    LuckyVegasCustomDeck:ModifyDeckForFreeSpinWild(deck)
    
    if LuckyVegasConfig.m_bJackPotTest == true then
        deck[0] = 1
        deck[3] = 1
        deck[6] = 1
        deck[9] = 1
        deck[12] = 1

        deck[1] = 2
        deck[4] = 2
        deck[7] = 2
        deck[10] = 2
        deck[13] = 2

        deck[2] = 3
        deck[5] = 3
        deck[8] = 3
        deck[11] = 3
        deck[14] = 3
    end

    return deck
end

function LuckyVegasFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        for i = 1, cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end
end

function LuckyVegasFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]
end

function LuckyVegasFunc:isStopReel(nReelId)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        return nReelId == 4
    end

    return false
end

function LuckyVegasFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function LuckyVegasFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
    self:CheckFiveOfKindJackPot(deck, result)
end

function LuckyVegasFunc:bCanTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    if rt:InFreeSpin() then
        return nScatterCount >= 2, nScatterCount
    else
        return nScatterCount >= 3, nScatterCount
    end
end

function LuckyVegasFunc:CheckFreeSpin(deck, result)
    local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
    if bTrigger then
        local nFreeSpinCount = LuckyVegasConfig:GetFreeSpinCount(nScatterCount)
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end
    end
end

function LuckyVegasFunc:orHaveJackPot(nSymbolId)
    return nSymbolId >= 1 and nSymbolId <= 10
end

function LuckyVegasFunc:GetSymbolJackPotValue(nSymbolId)
    local nJackPotIndex = nSymbolId
    local nJackPotMoneyCount = self.tableNowJackPotMoneyCount[nJackPotIndex]
    return nJackPotIndex, nJackPotMoneyCount
end

function LuckyVegasFunc:CheckFiveOfKindJackPot(deck, result)
    self.tableNowJackPotMoneyCount = {}
    self.tableNowbGetJackPot = {}
    for i = 1, 10 do
        self.tableNowbGetJackPot[i] = false
        self.tableNowJackPotMoneyCount[i] = LuckyVegasLevelUI.mJackPotUI:GetTotalJackPotValue(i)
    end
    
    for k, v in pairs(self.tableFiveOfKindSymbolId) do
        local nSymbolId = v
        if self:orHaveJackPot(nSymbolId) then 
            local nJackPotIndex = nSymbolId
            self.tableNowbGetJackPot[nJackPotIndex] = true

            local nJackPotMoneyCount = self.tableNowJackPotMoneyCount[nJackPotIndex]
            result.m_fSpinWin = result.m_fSpinWin + nJackPotMoneyCount
            
            if not self.m_bSimulationFlag then
                SlotsGameLua.m_bSplashFlags[SplashType.Jackpot] = true
                LuckyVegasLevelUI.tableGoJackPotEffect[nJackPotIndex]:SetActive(true)

                local goAni1 = LuckyVegasLevelUI:FindSymbolElement(LuckyVegasLevelUI.tableGoJackPotEffect[nJackPotIndex], "ANI1")
                local goAni2 = LuckyVegasLevelUI:FindSymbolElement(LuckyVegasLevelUI.tableGoJackPotEffect[nJackPotIndex], "ANI2")
                goAni1.gameObject:SetActive(false)
                goAni2.gameObject:SetActive(false)

                goAni1.gameObject:SetActive(true)
            end 

            if self.m_bSimulationFlag then
                if not self.tableSimuJackPotInfo[nJackPotIndex] then
                    self.tableSimuJackPotInfo[nJackPotIndex] = {nCount = 0, nMoneyCount = 0}
                end
                self.tableSimuJackPotInfo[nJackPotIndex].nCount = self.tableSimuJackPotInfo[nJackPotIndex].nCount + 1
                self.tableSimuJackPotInfo[nJackPotIndex].nMoneyCount = self.tableSimuJackPotInfo[nJackPotIndex].nMoneyCount + nJackPotMoneyCount
            end
        end
    end

end

function LuckyVegasFunc:CheckSpinWinPayLines(deck, result)
    self.tableFiveOfKindSymbolId = {}

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
            local bAnyBarMatchSuccess = false
            local bAny7MatchSuccess = false

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

            if not bMatchSuccess then
                bMatchSuccess, MatchCount, nMaxMatchReelID = self:CheckLineAnyBarSame(iResult)
                if bMatchSuccess then
                    bAnyBarMatchSuccess = true

                    --Debug.Log("Wild 匹配成功")
                end
            end 

            if not bMatchSuccess then
                bMatchSuccess, MatchCount, nMaxMatchReelID = self:CheckLineAny7Same(iResult)
                if bMatchSuccess then
                    bAny7MatchSuccess = true
                    
                    --Debug.Log("Wild 匹配成功")
                end
            end 

            local fCombReward = -1
            if bWildMatchSuccess or bIdMatchSuccess then
                fCombReward = SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount]
            elseif bAnyBarMatchSuccess then
                fCombReward = LuckyVegasConfig.TABLE_ANY_BAR_MULTUILE[MatchCount]
                nSymbolId = #SlotsGameLua.m_listSymbolLua + 1
            elseif bAny7MatchSuccess then
                fCombReward = LuckyVegasConfig.TABLE_ANY_7_MULTUILE[MatchCount]
                nSymbolId = #SlotsGameLua.m_listSymbolLua + 2
            end

            if fCombReward > 0.0 then
                self.m_nWin0Count = 0
                local nTotalBet = SceneSlotGame.m_nTotalBet
                local fLineBet = nTotalBet / #SlotsGameLua.m_listLineLua
                local LineWin = fCombReward * fLineBet

                table.insert(result.m_listWins, WinItem:create(i, nSymbolId, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if MatchCount >= 5 and self:orHaveJackPot(nSymbolId) then
                    if result:InFreeSpin() then
                        if not LuaHelper.tableContainsElement(self.tableFiveOfKindSymbolId, nSymbolId) then
                            table.insert(self.tableFiveOfKindSymbolId, nSymbolId)
                        end
                    else
                        local bHaveWild = false
                        for i = 0, SlotsGameLua.m_nReelCount - 1 do
                            local nSymbolId = iResult[i]
                            if LuckyVegasSymbol:isWildSymbol(nSymbolId) then
                                bHaveWild = true
                                break
                            end
                        end

                        if not bHaveWild then
                            if not LuaHelper.tableContainsElement(self.tableFiveOfKindSymbolId, nSymbolId) then
                                table.insert(self.tableFiveOfKindSymbolId, nSymbolId)
                            end
                        end
                    end
                end
                
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
function LuckyVegasFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if LuckyVegasSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i

            if i == 1 then
                nSymbolId = v
            end
        else
            break
        end
    end 

    if MatchCount > 0 and nSymbolId > 0 and SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount] > 0 then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end

end 

--检查ID 是否相同
function LuckyVegasFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]

        if LuckyVegasSymbol:IsNoLineAwardSymbolId(v) then
            break
        end

        if not LuckyVegasSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if LuckyVegasSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if MatchCount > 0 and nSymbolId > 0 and SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount] > 0 then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end 

end

function LuckyVegasFunc:CheckLineAnyBarSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if LuckyVegasSymbol:isAnyBarSymbol(v) or LuckyVegasSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if MatchCount >= 3 then
        return true, MatchCount, nMaxMatchReelID
    else
        return false
    end
end

function LuckyVegasFunc:CheckLineAny7Same(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if LuckyVegasSymbol:isAny7Symbol(v) or LuckyVegasSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if MatchCount >= 3 then
        return true, MatchCount, nMaxMatchReelID
    else
        return false
    end
end 

--仿真，把结果 输入到文本文件中
function LuckyVegasFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function LuckyVegasFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local pretableJackPotAddSumMoneyCount = LuckyVegasLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount
    LuckyVegasLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

    local nSimulationCount = SlotsGameLua.m_SimulationCount
    self.tableSimuJackPotInfo = {}
    self.nSimuLeafTriggerCount = 0
    self.m_nSimuFreeSpinCount = 0
    self.m_nSimuReSpinCount = 0

    self.m_nSimuFreeSpinTriggerCount = 0
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

    LuckyVegasLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = pretableJackPotAddSumMoneyCount

end 

function LuckyVegasFunc:WriteToFile()
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
    for i = 1, nSymbolCount + 2 do
        local name = ""
        if i <= nSymbolCount then
            name = SlotsGameLua.m_listSymbolLua[i].prfab.name
        elseif i == nSymbolCount + 1 then
            name = "Any Bar"
        elseif i == nSymbolCount + 2 then
            name = "Any 7"
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
    strFile = strFile.."FreeSpin 赢钱数: "..self.m_nSimuFreeSpinWinMoneyCount.."\n"

    strFile = strFile .. "\n"
    for i = 1, 10 do
        if self.tableSimuJackPotInfo[i] then
            strFile = strFile.."JackPot["..i.."] 触发次数: "..self.tableSimuJackPotInfo[i].nCount.." | "..self.tableSimuJackPotInfo[i].nMoneyCount.."\n"
        end
    end 
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
function LuckyVegasFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = LuckyVegasLevelUI
end

