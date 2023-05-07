require("Lua/ThemeVideo/Alice/AliceConfig")
require("Lua/ThemeVideo/Alice/AliceCustomDeck")
require("Lua/ThemeVideo/Alice/AliceSymbol")
require("Lua/ThemeVideo/Alice/AliceLevelUI")

AliceFunc = {}

function AliceFunc:InitVariable()
    self.m_nWin0Count = 0
    self.m_bSimulationFlag = false
    self.m_listHitSymbols = {}

    --1: Free Spin Bonus X3 
    --2: Cat Feature
    --3: Alice Feature
    self.nPickQueenFeature = 0
    self.tableAliceSymbol = {}
    self.tableFixedAliceSymbol = {}
end 

function AliceFunc:refreshHitSymbols(nLineId, nMaxMatchId)
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

function AliceFunc:OnStartSpin()
    AliceLevelUI.mDeckResultPayLines:MatchLineHide()
    self:CreateReelRandomSymbolList()

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if self.nPickQueenFeature == 3 then
            local nWildAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")
            for k, v in pairs(self.tableFixedAliceSymbol) do
                local nReelId = k
                local nRowIndex = v
                AliceLevelUI:FixedAliceSymbol(nWildAliceSymbolId, nReelId, nRowIndex)
            end

            for k, v in pairs(AliceLevelUI.tableFixedGoSymbol) do
                v:SetActive(true)
            end
        end
    end 

end

function AliceFunc:OnSpinEnd()
    for k, v in pairs(AliceLevelUI.tableFixedGoSymbol) do
        v:SetActive(false)
    end
    AliceLevelUI.mDeckResultPayLines:InitMatchLineShow()
end

function AliceFunc:GetDeck()
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

    AliceCustomDeck:ModifyDeckForScatter(deck)
    AliceCustomDeck:ModifyDeckForAlice(deck)
    AliceCustomDeck:ModifyDeckForStackWild(deck)
    AliceCustomDeck:ModifyDeckForTriggerFreeSpin(deck)

    if not self.m_bSimulationFlag then
        if rt:InFreeSpin() and self.nPickQueenFeature == 2 and AliceFunc:bCanTriggerWildStack(deck) then
            CoroutineHelper.waitForEndOfFrame(function()
                SceneSlotGame.m_btnSpin.interactable = false
                SlotsGameLua.m_listReelLua[0].m_fRotateDistance = SlotsGameLua.m_fRotateDistance * 100
                local goEffect = AliceLevelUI:GetEffectByEffectPool("catFeatureEffect")
                goEffect:SetActive(true)
                
                if AliceLevelUI.cacheCatSpine == nil then
                    AliceLevelUI.cacheCatSpine = SpineEffect:create(goEffect)
                end
                AliceLevelUI.cacheCatSpine:PlayAnimation("animation", 0.0, false)

                LeanTween.delayedCall(3.0, function()
                    SceneSlotGame.m_btnSpin.interactable = true
                    SlotsGameLua.m_listReelLua[0].m_fRotateDistance = 0
                    AliceLevelUI.cacheCatSpine:StopActiveAnimation()
                    AliceLevelUI:RecycleEffectToEffectPool(goEffect)
                end)
            end)
        end
    end 

    return deck
end

function AliceFunc:CreateReelRandomSymbolList()
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("SCATTER")
    local nWildAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    local cnt = 30
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        local bHaveScatter = false
        for i = 1, cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            if nSymbolId == nWildAliceSymbolId then
                nSymbolId = AliceSymbol:GetCommonSymbolIdByReelId(x)
            elseif nSymbolId == nScatterSymbolId then
                if bHaveScatter then
                    nSymbolId = AliceSymbol:GetCommonSymbolIdByReelId(x)
                else
                    bHaveScatter = true
                end
            end
            
            if i >= 5 and math.random() < 0.01 then
                nSymbolId = nWildAliceSymbolId
                local bPreExistWildAliceSymbol = false
                for k = i - 4, i - 1 do
                    if SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[k] == nWildAliceSymbolId then
                        nSymbolId = AliceSymbol:GetCommonSymbolIdByReelId(x)
                        bPreExistWildAliceSymbol = true
                    end
                end

                if not bPreExistWildAliceSymbol then
                    for k = i - 4, i - 1 do
                        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[k] = nNullSymbolId
                    end
                end
            end

            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end
end

function AliceFunc:isReelCanStartDeck(nReelId)
    local nWildAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nIndex = reel.m_nReelRow + reel.m_nAddSymbolNums - 1
    local nPreID = reel.m_curSymbolIds[nIndex]
    if nPreID == nNullSymbolId or nPreID == nWildAliceSymbolId then
        return false
    end

    return true
end 

function AliceFunc:GetDeckFinishRandom(nReelId, nStopOffset)
    local nWildAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    local reel = SlotsGameLua.m_listReelLua[nReelId]
    local nSymbolId = reel:GetRandom(false)
    if nSymbolId == nWildAliceSymbolId or nSymbolId == nNullSymbolId then
        nSymbolId = AliceSymbol:GetCommonSymbolIdByReelId(nReelId)
    end

    local nTargetRowIndex = self.tableAliceSymbol[nReelId]
    if nTargetRowIndex and nTargetRowIndex >= SlotsGameLua.m_nRowCount then
        if nStopOffset + SlotsGameLua.m_nRowCount < nTargetRowIndex then
            nSymbolId = nNullSymbolId
        elseif nStopOffset + SlotsGameLua.m_nRowCount == nTargetRowIndex then
            nSymbolId = nWildAliceSymbolId
        end
    end 

    return nSymbolId
end

function AliceFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
    if AliceSymbol:isScatterSymbol(nSymbolID) then
        local goCanvas = AliceLevelUI:FindSymbolElement(go, "Canvas")
        goCanvas:SetActive(false)
    end
end 

function AliceFunc:ReDeckForAlice(deck)
    local nWildAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")

    for k, v in pairs(self.tableAliceSymbol) do
        local nReelId = k
        local nTargetIndex = v

        local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
        local nStackEndIndex = math.max(0, nTargetIndex - SlotsGameLua.m_nRowCount + 1)
        for j = nStackBeginIndex, nStackEndIndex, -1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + j
            deck[nKey] = nWildAliceSymbolId
        end
    end

end

function AliceFunc:PreCheckWin()
    self:ReDeckForAlice(SlotsGameLua.m_listDeck)
    SlotsGameLua:CheckWinEnd()
end

function AliceFunc:bCanTriggerWildStack(deck)
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

function AliceFunc:bCanTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end
    
    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if AliceSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    if rt:InFreeSpin() then
        return nScatterCount >= 2
    else
        return nScatterCount >= 3
    end

end

function AliceFunc:CheckGameResult(deck, result)
    self:CheckFreeSpin(deck, result)
    self:CheckFreeSpinFeatureAlice(deck, result)
end

function AliceFunc:CheckFreeSpin(deck, result)
    if self:bCanTriggerFreeSpin(deck) then
        local nFreeSpinCount = 7
        result.m_nNewFreeSpinCount = nFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCount

        if result.m_nFreeSpinCount == 0 then
            self.nPickQueenFeature = AliceConfig:GetTriggerFreeSpinFeatureType()
        end

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        else
            AliceLevelUI:setDBFreeSpin()
        end
    end
end   

function AliceFunc:CheckFreeSpinFeatureAlice(deck, result)
    if result:InFreeSpin() and self.nPickQueenFeature == 3 then
        self.tableFixedAliceSymbol = self.tableAliceSymbol
        AliceLevelUI:setDBFreeSpin()
    end
end

function AliceFunc:CheckSpinWinPayLines(deck, result)
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
        Debug.Assert(self.nPickQueenFeature >= 1 and self.nPickQueenFeature <= 3)

        if self.nPickQueenFeature == 1 then
            result.m_fSpinWin = result.m_fSpinWin * 3
        end

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinWinMoneyCount = self.m_nSimuFreeSpinWinMoneyCount + result.m_fSpinWin
        end
    end     

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--检查Wild 匹配
function AliceFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nSymbolId = -1
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if AliceSymbol:isWildSymbol(v) then
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
function AliceFunc:CheckLineSymbolIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if AliceSymbol:IsNoLineAwardSymbolId(v) then
            break
        end

        if not AliceSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if AliceSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
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
function AliceFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function AliceFunc:GetTestResultByRate()
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
        self:ReDeckForAlice(iDeck)
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

function AliceFunc:WriteToFile()
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
function AliceFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)

    SlotsGameLua:setAllReelStopAudioHandleFunc(self, self.AllReelStopAudioHandle)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = AliceLevelUI
end

