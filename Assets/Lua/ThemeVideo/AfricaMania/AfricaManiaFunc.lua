require("Lua/ThemeVideo/AfricaMania/AfricaManiaConfig")
require("Lua/ThemeVideo/AfricaMania/AfricaManiaCustomDeck")
require("Lua/ThemeVideo/AfricaMania/AfricaManiaSymbol")
require("Lua/ThemeVideo/AfricaMania/AfricaManiaLevelUI")

AfricaManiaFunc = {}

function AfricaManiaFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
end

function AfricaManiaFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()
end

function AfricaManiaFunc:GetDeck()
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

    AfricaManiaCustomDeck:ModifyDeckForScatterStack(deck)
    AfricaManiaCustomDeck:ModifyDeckForTriggerFreeSpin(deck)

    return deck
end

function AfricaManiaFunc:CreateReelRandomSymbolList()
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("scatter")

    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local nContinueCount = 0
        local nMaxContinueCount = 0
        for i = 1, cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            if nContinueCount < nMaxContinueCount then
                nSymbolId = nScatterSymbolId
                nContinueCount = nContinueCount + 1
            else
                if math.random() < 0.05 then
                    nContinueCount = 0
                    nMaxContinueCount = math.random(1, 10)
                end
            end

            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

end

function AfricaManiaFunc:SymbolCustomHandler(nReelId, nRowIndex, bResultDeck, nDeckKey)

end 

function AfricaManiaFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function AfricaManiaFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
end

function AfricaManiaFunc:CheckFreeSpin(deck, result)
    local nScatterCount = 0
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
            end
        end
    end

    local nFreeSpinCount = AfricaManiaConfig:GetFreeSpinCount(nScatterCount)
    if nFreeSpinCount > 0 then
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end
    end

end     

function AfricaManiaFunc:GetPayWaysWin(deck, result)
    self:GetReelWin(0, deck, 0, result)
end

function AfricaManiaFunc:GetReelWin(nPreID, deck, nStartReelId, result)
    local bScatterPreWin = true
    for k = 0, SlotsGameLua.m_nRowCount - 1 do
        local nKey = SlotsGameLua.m_nRowCount * nStartReelId + k
        local nCurID = deck[nKey]
        if not AfricaManiaSymbol:IsNoLineAwardSymbolId(nCurID) then
            bScatterPreWin = false
            break
        end
    end 

    for k = 0, SlotsGameLua.m_nRowCount - 1 do
        local nKey = SlotsGameLua.m_nRowCount * nStartReelId + k
        local nCurID = deck[nKey]
        local bRecusive = false
        if AfricaManiaSymbol:isWildSymbol(nCurID) then
            if nStartReelId < SlotsGameLua.m_nReelCount - 1 then
                bRecusive = true
                self:GetReelWin(nCurID, deck, nStartReelId + 1, result)
            end
        end

        if not bRecusive then
            local nWays = 0
            local nMatches = 0

            if AfricaManiaSymbol:IsNoLineAwardSymbolId(nCurID) then
                if nPreID > 0 and bScatterPreWin then
                    nWays = 1
                    nMatches = nStartReelId
                    nCurID = nPreID 

                    bScatterPreWin = false
                end
            else
                local nReelSameSymbolNums = {}
                for x = nStartReelId + 1, SlotsGameLua.m_nReelCount - 1 do
                    nReelSameSymbolNums[x] = 0
                    for y = 0, SlotsGameLua.m_nRowCount - 1 do
                        local nKey1 = SlotsGameLua.m_nRowCount * x + y
                        local nID = deck[nKey1]
                        if  self:isSamekindSymbol(nCurID, nID)  then
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
            end

            self:GetElemWin(nCurID, nMatches, nWays, deck, result)
        end
    end

end

function AfricaManiaFunc:GetElemWin(nCurID, nMatches, nWays, deck, result)
    local sd = SlotsGameLua:GetSymbol(nCurID)
    local nRewardBet = sd.m_fRewards[nMatches]
    if nMatches > 0 and nRewardBet > 0 then
        Debug.Assert(AfricaManiaSymbol:IsNoLineAwardSymbolId(nCurID) == false)
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

function AfricaManiaFunc:isSamekindSymbol(nSymbolId, nResultId)
    if AfricaManiaSymbol:IsNoLineAwardSymbolId(nSymbolId) or AfricaManiaSymbol:IsNoLineAwardSymbolId(nResultId) then
        return false
    end
    
    if nSymbolId == nResultId or AfricaManiaSymbol:isWildSymbol(nSymbolId) or AfricaManiaSymbol:isWildSymbol(nResultId) then
        return true
    end

    return false
end

function AfricaManiaFunc:CheckSpinWinPayWays(deck, result)
    result:ResetSpin()
    self:GetPayWaysWin(deck, result)

    if result.m_fSpinWin == 0.0 then
        self.m_nWin0Count = self.m_nWin0Count + 1
    else
        self.m_nWin0Count = 0
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


--仿真，把结果 输入到文本文件中
function AfricaManiaFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function AfricaManiaFunc:GetTestResultByRate()
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

function AfricaManiaFunc:WriteToFile()
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
function AfricaManiaFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)
    
    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayWaysFunc(self,self.CheckSpinWinPayWays)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = AfricaManiaLevelUI
end

