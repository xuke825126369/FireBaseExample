require("Lua/ThemeVideo/MardiGras/MardiGrasConfig")
require("Lua/ThemeVideo/MardiGras/MardiGrasSymbol")
require("Lua/ThemeVideo/MardiGras/MardiGrasLevelUI")
require("Lua/ThemeVideo/MardiGras/MardiGrasCustomDeck")

MardiGrasFunc = {}

function MardiGrasFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    self.tableWildSymbol = {}
    self.tableWheelKey = {}
    self.tableWinKey = {}

    self.tableNowbGetJackPot = {}
    self.tableNowJackPotMoneyCount = {}

    self.nFreeSpinBeginMoneyCount = 0

    ---------------- 仿真相关 --------------------
end 

function MardiGrasFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function MardiGrasFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()

    for k, v in pairs(MardiGrasLevelUI.tableGoWheelEffect) do
        MardiGrasLevelUI:RecycleEffectToEffectPool(v)
    end
    MardiGrasLevelUI.tableGoWheelEffect = {}

end

function MardiGrasFunc:OnSpinEnd()
    MardiGrasFunc:CheckWildSymbolHightEffect()
end

function MardiGrasFunc:GetDeck()
    local nNullSymbolID = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    local deck = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local nKey = x * 3
        local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
        if MardiGrasConfig:orRow0TriggerNullSymbol() then
            nSymbolId = nNullSymbolID
        else
            nSymbolId = MardiGrasSymbol:checkSymbolAdjacent(x, nSymbolId, nNullSymbolID)
        end
        deck[nKey] = nSymbolId
    end 

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 1, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            local nPreSymbolID = deck[nKey - 1]
            local id = MardiGrasSymbol:checkSymbolAdjacent(x, nSymbolId, nPreSymbolID)
            deck[nKey] = id
        end
    end
    
    MardiGrasCustomDeck:ModifyDeckForStackWild(deck)
    MardiGrasCustomDeck:ModifyDeckForWheelFeature(deck)
    return deck
end

function MardiGrasFunc:CreateReelRandomSymbolList()
    local nNullSymbolID = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1")

    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local i = 0
        while i < cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            if i == 1 then
                if MardiGrasConfig:orRow0TriggerNullSymbol() then
                    nSymbolId = nNullSymbolID
                else
                    nSymbolId = MardiGrasSymbol:checkSymbolAdjacent(x, nSymbolId, nNullSymbolID)
                end
            else
                local nPreSymbolID = SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - 1]
                nSymbolId = MardiGrasSymbol:checkSymbolAdjacent(x, nSymbolId, nPreSymbolID)

                if nSymbolId == nWildSymbolId then
                    local bHaveWild = false
                    for j = 1, 3 do
                        local nId = SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - j]
                        if nId == nWildSymbolId then
                            bHaveWild = true
                        end
                    end

                    if bHaveWild then
                        nSymbolId = MardiGrasSymbol:GetCommonSymbolIdByReelId(x)
                    end
                end

                if nSymbolId == nWildSymbolId then
                    SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - 1] = nNullSymbolID
                    SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i - 2] = nNullSymbolID
                end
            end 

            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
            i = i + 1
        end
    end

end

function MardiGrasFunc:GetDeckFinishRandom(nReelId, nStopOffset)
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")

    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nSymbolId = reel:GetRandom(false)

    local nIndex = SlotsGameLua.m_listReelLua[nReelId].m_nReelRow + SlotsGameLua.m_listReelLua[nReelId].m_nAddSymbolNums - 1
    local nPreID = SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nIndex]

    if self.tableWildSymbol[nReelId] and self.tableWildSymbol[nReelId] >= SlotsGameLua.m_nRowCount then
        local nRowIndex = self.tableWildSymbol[nReelId]
        if nStopOffset + SlotsGameLua.m_nRowCount == nRowIndex then
            nSymbolId = nWildSymbolId
        elseif nStopOffset + SlotsGameLua.m_nRowCount > nRowIndex then
            if nPreID == nNullSymbolId then
                nSymbolId = MardiGrasSymbol:GetCommonSymbolIdByReelId(nReelId)
            else
                nSymbolId = nNullSymbolId --self:GetRandom(true)
            end
        elseif nStopOffset + SlotsGameLua.m_nRowCount < nRowIndex then
            nSymbolId = nNullSymbolId
        end
    else
        if nPreID == nNullSymbolId then
            nSymbolId = MardiGrasSymbol:GetCommonSymbolIdByReelId(nReelId)
        else
            nSymbolId = nNullSymbolId --self:GetRandom(true)
        end
    end 

    return nSymbolId
end

function MardiGrasFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolId = reel.m_curSymbolIds[nRowIndex]
    
    if MardiGrasSymbol:isCommonSymbolId(nSymbolId) then
        local goRedWheel = MardiGrasLevelUI:FindSymbolElement(go, "redWheel")
        local goYellowWheel = MardiGrasLevelUI:FindSymbolElement(go, "yellowWheel")
        local goGreenWheel = MardiGrasLevelUI:FindSymbolElement(go, "greenWheel")
        goRedWheel:SetActive(false)
        goYellowWheel:SetActive(false)
        goGreenWheel:SetActive(false)

        if bResultDeck then
            if LuaHelper.tableContainsElement(self.tableWheelKey, nDeckKey) then
                if nReelID == 0 then
                    goYellowWheel:SetActive(true)
                elseif nReelID == 1 then
                    goRedWheel:SetActive(true)
                elseif nReelID == 2 then
                    goGreenWheel:SetActive(true)
                end
            end
        end
    end

end

function MardiGrasFunc:ReDeckWildSymbol(deck)
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1")

    for k, v in pairs(self.tableWildSymbol) do
        local nReelId = k
        local nTargetIndex = v
        local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
        local nStackEndIndex = math.max(0, nTargetIndex - 2)
        for j = nStackBeginIndex, nStackEndIndex, -1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + j
            deck[nKey] = nWildSymbolId
        end
    end
end

function MardiGrasFunc:PreCheckWin()
    self:ReDeckWildSymbol(SlotsGameLua.m_listDeck)
    SlotsGameLua:CheckWinEnd()
end

function MardiGrasFunc:CheckGameResult(deck, result)
    self:CheckWheelFeature(deck, result)
end

function MardiGrasFunc:CheckWheelFeature(deck, result)       
    if #self.tableWheelKey >= 3 then 
        MardiGrasFunc.nSelectedYellowMultuile = 0
        MardiGrasFunc.nSelectedRedMultuile = 0
        MardiGrasFunc.nSelectedGreenMultuile = 0
        MardiGrasLevelUI.mWheelUI:SetMultuile()
        
        local nFreeSpinCount = MardiGrasFunc.nSelectedRedMultuile
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if not self.m_bSimulationFlag then
            MardiGrasLevelUI:setDBFreeSpin()
            LevelDataHandler:addNewFreeSpinCount(ThemeLoader.themeKey, SlotsGameLua.m_GameResult.m_nNewFreeSpinCount)
            LevelDataHandler:addTotalFreeSpinCount(ThemeLoader.themeKey, SlotsGameLua.m_GameResult.m_nNewFreeSpinCount)
        else
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end 
    end

end

function MardiGrasFunc:CheckWildSymbolHightEffect()   
    for k, v in pairs(self.tableWildSymbol) do
        local nReelId = k
        local nTargetIndex = v
        local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
        local nStackEndIndex = math.max(0, nTargetIndex - 2)
        
        local goSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nTargetIndex]
        local goHighEffect1 = MardiGrasLevelUI:FindSymbolElement(goSymbol, "highLightMask1")
        local goHighEffect2 = MardiGrasLevelUI:FindSymbolElement(goSymbol, "highLightMask2")
        local goHighEffect3 = MardiGrasLevelUI:FindSymbolElement(goSymbol, "highLightMask3")
        goHighEffect1:SetActive(false)
        goHighEffect2:SetActive(false)
        goHighEffect3:SetActive(false)
        SymbolObjectPool.m_mapMultiClipEffect[goSymbol]:playAniByPlayMode(1)

        for j = nStackBeginIndex, nStackEndIndex, -1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + j

            if LuaHelper.tableContainsElement(self.tableWinKey, nKey) then
                if j == nTargetIndex then
                    goHighEffect3:SetActive(true)
                elseif j == nTargetIndex - 1 then
                    goHighEffect2:SetActive(true)
                elseif j == nTargetIndex - 2 then
                    goHighEffect1:SetActive(true)
                end
            end
        end

    end

end

function MardiGrasFunc:CheckSpinWinPayLines(deck, result)
    self.tableWinKey = {}
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
            local bAnyMardiGrasWheelSymbolMatchSuccess = false

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
                bMatchSuccess, MatchCount, nMaxMatchReelID = self:CheckLineAnyMardiGrasWheelSymbolSame(iResult)
                if bMatchSuccess then
                    bAnyMardiGrasWheelSymbolMatchSuccess = true

                    --Debug.Log("Wild 匹配成功")
                end
            end 

            local fCombReward = -1
            if bWildMatchSuccess or bIdMatchSuccess then
                fCombReward = SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount]
            elseif bAnyBarMatchSuccess then
                fCombReward = MardiGrasConfig.N_ANY_BAR_MULTUILE
                nSymbolId = #SlotsGameLua.m_listSymbolLua + 1
            elseif bAnyMardiGrasWheelSymbolMatchSuccess then
                fCombReward = MardiGrasConfig.N_ANY_MARIDGRASWHEEL_MULTUILE
                nSymbolId = #SlotsGameLua.m_listSymbolLua + 2
            end

            if fCombReward > 0.0 then
                self.m_nWin0Count = 0
                local nTotalBet = SceneSlotGame.m_nTotalBet
                local fLineBet = nTotalBet / #SlotsGameLua.m_listLineLua
                local LineWin = fCombReward * fLineBet
                if result:InFreeSpin() then
                    LineWin = LineWin * self.nSelectedGreenMultuile
                end

                table.insert(result.m_listWins, WinItem:create(i, nSymbolId, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                for i = 0, SlotsGameLua.m_nReelCount - 1 do
                    local nRowIndex = ld.Slots[i]
                    local nKey = i * SlotsGameLua.m_nRowCount + nRowIndex
                    if not LuaHelper.tableContainsElement(self.tableWinKey, nKey) then
                        table.insert(self.tableWinKey, nKey)
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
function MardiGrasFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if MardiGrasSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i

            if i == 1 then
                nSymbolId = v
            end
        else
            break
        end
    end 

    if MatchCount == 3 then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end

end 

--检查ID 是否相同
function MardiGrasFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nMardigrasSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Mardigras")

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]

        if MardiGrasSymbol:IsNoLineAwardSymbolId(v) then
            break
        end

        if not MardiGrasSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if v ~= nMardigrasSymbolId and MardiGrasSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        elseif v == nMardigrasSymbolId and nSymbolId == nMardigrasSymbolId then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     
    
    if MatchCount == 3 and nSymbolId > 0 then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end 

end

function MardiGrasFunc:CheckLineAnyBarSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if MardiGrasSymbol:isAnyBarSymbol(v) or MardiGrasSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if MatchCount == 3 then
        return true, MatchCount, nMaxMatchReelID
    else
        return false
    end
end

function MardiGrasFunc:CheckLineAnyMardiGrasWheelSymbolSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if MardiGrasSymbol:isAnyMardiGrasWheelSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end     

    if MatchCount == 3 then
        return true, MatchCount, nMaxMatchReelID
    else
        return false
    end
end 

--仿真，把结果 输入到文本文件中
function MardiGrasFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function MardiGrasFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount
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
        self:ReDeckWildSymbol(iDeck)
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

function MardiGrasFunc:WriteToFile()
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
function MardiGrasFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = MardiGrasLevelUI
end

