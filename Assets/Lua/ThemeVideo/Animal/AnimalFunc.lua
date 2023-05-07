require("Lua/ThemeVideo/Animal/AnimalConfig")
require("Lua/ThemeVideo/Animal/AnimalCustomDeck")
require("Lua/ThemeVideo/Animal/AnimalSymbol")
require("Lua/ThemeVideo/Animal/AnimalLevelUI")

AnimalFunc = {}

function AnimalFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}
end 

function AnimalFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function AnimalFunc:OnStartSpin()
    AnimalLevelUI.mDeckResultPayWays:MatchLineHide()
    self:CreateReelRandomSymbolList()
end

function AnimalFunc:OnSpinEnd()
    AnimalLevelUI.mDeckResultPayWays:InitMatchLineShow()
end

function AnimalFunc:GetDeck()
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

    AnimalCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    return deck
end

function AnimalFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local bHaveScatter = false
        for i = 1, cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end
end

function AnimalFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function AnimalFunc:bCanTriggerWildStack(deck)
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

function AnimalFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if AnimalSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
            end
        end
    end
    return nScatterCount >= 5, nScatterCount
end

function AnimalFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
end

function AnimalFunc:CheckFreeSpin(deck, result)
    if result:InFreeSpin() then

        
    else
        local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
        if bTrigger then
            local nFreeSpinCount = AnimalConfig:GetFreeSpinCount(nScatterCount)
            result.m_nNewFreeSpinCount = nFreeSpinCount
            result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

            if self.m_bSimulationFlag then
                self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
            end
        end
    end

end

function AnimalFunc:CheckSpinWinPayWays(deck, result)
    result:ResetSpin()

    local nReel0RowNum = 3
    local nReelIndex = 0
    for row = 0, nReel0RowNum - 1 do
        local nCurID = deck[SlotsGameLua.m_nRowCount * nReelIndex + row]
        local Wild2XSymbolCount = 0
        local Wild3XSymbolCount = 0
        local nReelSameSymbolNums = {}
        for i = 1, SlotsGameLua.m_nReelCount - 1 do
            nReelSameSymbolNums[i] = 0
        end

        for x = 1, SlotsGameLua.m_nReelCount - 1 do
            local nCurReelRowNum = SlotsGameLua.m_listReelLua[x].m_nReelRow
            for y = 0, nCurReelRowNum - 1 do
                local nID = deck[SlotsGameLua.m_nRowCount * x + y]
                local bSameKindSymbolFlag = self:isSamekindSymbol(nCurID,nID)
                if bSameKindSymbolFlag then
                    nReelSameSymbolNums[x] = nReelSameSymbolNums[x] + 1
                end
            end
        end

        local nWays = 1
        local nMatches = 1
        for i = 1, SlotsGameLua.m_nReelCount - 1 do
            if nReelSameSymbolNums[i] == 0 then
                break
            end
            nWays = nWays * nReelSameSymbolNums[i]
            nMatches = i + 1
        end 
        
        local sd = SlotsGameLua:GetSymbol(nCurID)
        local nRewardBet = sd.m_fRewards[nMatches]
        if nMatches > 1 and nRewardBet > 0 then
            local fMultiplier = SceneSlotGame.m_nTotalBet / 100.0
            local fWinGold = nRewardBet * fMultiplier * nWays
            local winItem = WinItemPayWay:create(nCurID, nMatches, nWays, fWinGold)
            local bFlag = false
            for tkey in pairs(result.m_mapWinItemPayWays) do
                if tkey == nCurID then
                    bFlag = true
                    break
                end
            end

            if bFlag then
                local curItem = result.m_mapWinItemPayWays[nCurID]
                assert(curItem.m_nMatches == nMatches)
                curItem.m_nWays = curItem.m_nWays + nWays
                curItem.m_fWinGold = fWinGold
                result.m_mapWinItemPayWays[nCurID] = curItem
            else
                result.m_mapWinItemPayWays[nCurID] = winItem
            end

            result.m_fSpinWin = result.m_fSpinWin + fWinGold
            local nPayWayTestWinItemLength = 0
            for i in pairs(result.m_mapTestPayWayWinItems) do
                nPayWayTestWinItemLength = nPayWayTestWinItemLength + 1
            end
            if nPayWayTestWinItemLength ~= 0 then
                result.m_mapTestPayWayWinItems[nCurID].m_nHit = result.m_mapTestPayWayWinItems[nCurID].m_nHit  + nWays
                result.m_mapTestPayWayWinItems[nCurID].m_fWinGold  = result.m_mapTestPayWayWinItems[nCurID].m_fWinGold + fWinGold
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
function AnimalFunc:isSamekindSymbol(nCurSymbolId, nSymbolId)
    if AnimalSymbol:isWildSymbol(nSymbolId) or AnimalSymbol:isWildSymbol(nCurSymbolId) then
        return true
    end

    if nCurSymbolId == nSymbolId then
        return true
    end

    return false
end

--仿真，把结果 输入到文本文件中
function AnimalFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function AnimalFunc:GetTestResultByRate()
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
        rt = self:CheckSpinWinPayWays(iDeck, rt)

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

function AnimalFunc:WriteToFile()
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
        if rt.m_mapTestPayWayWinItems[i] ~= nil then
            nHit = rt.m_mapTestPayWayWinItems[i].Hit
            fWinGold = rt.m_mapTestPayWayWinItems[i].WinGold
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
function AnimalFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayWaysFunc(self, self.CheckSpinWinPayWays)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = AnimalLevelUI
end

