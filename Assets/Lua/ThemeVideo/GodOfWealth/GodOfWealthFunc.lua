require("Lua/ThemeVideo/GodOfWealth/GodOfWealthConfig")
require("Lua/ThemeVideo/GodOfWealth/GodOfWealthCustomDeck")
require("Lua/ThemeVideo/GodOfWealth/GodOfWealthSymbol")
require("Lua/ThemeVideo/GodOfWealth/GodOfWealthLevelUI")

GodOfWealthFunc = {}

function GodOfWealthFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}
end 

function GodOfWealthFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function GodOfWealthFunc:OnStartSpin()
    self:CreateReelRandomSymbolList()
end

function GodOfWealthFunc:OnSpinEnd()
end

function GodOfWealthFunc:GetDeck()
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
    
    GodOfWealthCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    if rt:InFreeSpin() then
        local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")
        local nReelId = 5
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + i
            deck[nKey] = nWildSymbolId
        end
    end

    return deck
end

function GodOfWealthFunc:CreateReelRandomSymbolList()
    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local nContinueCount = 0
        local nContinueMaxCount = 0
        local nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
        local bHaveScatter = false
        for i = 1, cnt do
            if nContinueCount >= nContinueMaxCount then
                nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                nContinueCount = 0
                nContinueMaxCount = math.max(1, 5)
            end

            nContinueCount = nContinueCount + 1

            if bHaveScatter then
                nStackSymbolId = GodOfWealthSymbol:GetCommonSymbolIdByReelId(x)
            else
                bHaveScatter = true
            end

            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nStackSymbolId
        end
    end
end

function GodOfWealthFunc:isStopReel(nReelID)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        return nReelID == 5
    end
    return false
end

function GodOfWealthFunc:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]
end    

function GodOfWealthFunc:DoWildMerge(deck)
    local bHaveAni = false
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")

    for j = 0, SlotsGameLua.m_nRowCount - 1 do
        local nBeginReelId = -1
        local nEndReelId = -1
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if GodOfWealthSymbol:isWildSymbol(nSymbolId) then
                nEndReelId = i
                if nBeginReelId == -1 then
                    nBeginReelId = i
                end
            end
        end

        if nBeginReelId ~= nEndReelId and nBeginReelId >= 0 and nEndReelId >= 0 then
            bHaveAni = true
            for i = nBeginReelId + 1, nEndReelId - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = nWildSymbolId

                if not self.m_bSimulationFlag then
                    -- 做动画
                    local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                    local goEffect = GodOfWealthLevelUI:GetEffectByEffectPool("TXChangeElement")
                    goEffect.transform.position = goSymbol.transform.position
                    goEffect:SetActive(true)

                    LeanTween.delayedCall(2.0, function()
                        GodOfWealthLevelUI:RecycleEffectToEffectPool(goEffect)
                    end)

                    LeanTween.delayedCall(0.0, function()
                        local goSymbol = GodOfWealthLevelUI:FillSymbol(nWildSymbolId, i, j)
                        --goSymbol.transform.localScale = Unity.Vector3.zero
                        --LeanTween.scale(goSymbol, Unity.Vector3.one, 0.5):setEase(LeanTweenType.easeOutBack)
                        CoroutineHelper.waitForEndOfFrame(function()
                            SymbolObjectPool.m_mapSpinEffect[goSymbol]:PlayAnimation("xiaohehe", 0.0, false)
                        end)
                    end)

                end
            end
        end
    end

    if not self.m_bSimulationFlag then
        if bHaveAni then
            AudioHandler:PlayThemeSound("revealWild")
        end
    end

    return bHaveAni
end

function GodOfWealthFunc:PreCheckWin()
    if self:DoWildMerge(SlotsGameLua.m_listDeck) then
        LeanTween.delayedCall(2.5, function()
            CoroutineHelper.waitForEndOfFrame(function()
                SlotsGameLua:CheckWinEnd()
            end)
        end)
    else
        SlotsGameLua:CheckWinEnd()
    end
end

function GodOfWealthFunc:bCanTriggerWildStack(deck)
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

function GodOfWealthFunc:bCanTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if GodOfWealthSymbol:isScatterSymbol(nSymbolId) then
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

function GodOfWealthFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
end

function GodOfWealthFunc:CheckFreeSpin(deck, result)
    local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
    if bTrigger then
        local nFreeSpinCount = GodOfWealthConfig:GetFreeSpinCount(nScatterCount)
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end
    end
end

function GodOfWealthFunc:CheckSpinWinPayLines(deck, result)
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
function GodOfWealthFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if GodOfWealthSymbol:isWildSymbol(v) then
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
function GodOfWealthFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if GodOfWealthSymbol:IsNoLineAwardSymbolId(v) then
            break
        end
            
        if not GodOfWealthSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if GodOfWealthSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
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
function GodOfWealthFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function GodOfWealthFunc:GetTestResultByRate()
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
        if self:DoWildMerge(iDeck) then
            rt = self:CheckSpinWinPayLines(iDeck, rt)
        else
            rt = self:CheckSpinWinPayLines(iDeck, rt)
        end
        
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

function GodOfWealthFunc:WriteToFile()
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
function GodOfWealthFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = GodOfWealthLevelUI
end

