ArabCustomDeck = {}

function ArabCustomDeck:ModifyDeckForWin0(deck)
    local rt = SlotsGameLua.m_GameResult
    if ArabFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if not bReSpinFlag then
        ArabFunc.m_nWin0Count = ArabFunc.m_nWin0Count + 1
    end     

    if ArabFunc.m_nWin0Count > 2 then
        if math.random() < 0.7 then
            self:CheckWin0Deck(deck)
        end
    end

end

function ArabCustomDeck:IsWin0Deck_payLines(deck)
    for i = 1, #SlotsGameLua.m_listLineLua do
        local iResult = {}
        local ld = SlotsGameLua:GetLine(i)
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            iResult[x] = deck[SlotsGameLua.m_nRowCount * x + ld.Slots[x]]
        end 

        local MatchCount = 0
        local nMaxMatchReelID = 0
        local bcond2 = false

        local bWildMatchSuccess = false
        local bIdMatchSuccess = false
        local bAnyBarMatchSuccess = false  
        local bAny7MatchSuccess = false 

        local nSymbolId = -1
        local bMatchSuccess = false

        if not bMatchSuccess then
             bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = ArabFunc:CheckLineSymbolIdSame(iResult)
             if bMatchSuccess then
                bIdMatchSuccess = true
                
                --Debug.Log("ID 匹配成功")
             end
        end

        if not bMatchSuccess then
            bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = ArabFunc:CheckLineWildMatch(iResult)
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
            return false
        end
    end

	return true
end

function ArabCustomDeck:CheckWin0Deck(deck)
    if self:IsWin0Deck_payLines(deck) then
        local nSymbolId = ArabSymbol:GetCommonSymbolId(0)
        
        if math.random() < 0.8 then
            local nMaxMatchReelId = math.random(2, 4)
            local nRandomLineIndex = math.random(1, #SlotsGameLua.m_listLineLua)
            local ld = SlotsGameLua.m_listLineLua[nRandomLineIndex]

            for i = 0, nMaxMatchReelId do
                local nKey = SlotsGameLua.m_nRowCount * i + ld.Slots[i]
                deck[nKey] = nSymbolId
            end
        else
            local nMaxMatchReelId = math.random(2, 3)
            for i = 0, nMaxMatchReelId do
                for j = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = SlotsGameLua.m_nRowCount * i + j
                    deck[nKey] = nSymbolId
                end
            end
        end

        if not ArabFunc.m_bSimulationFlag then
            Debug.Log("------------- win0 中奖: ---------------: "..nSymbolId)
        end
    end
end

--------------------------------------------------------------------------------------------------
function ArabCustomDeck:ModifyDeckForStackSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if ArabFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local tableContinueCountRate = {1, 2, 3, 4}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local nRowIndex = 0
        while nRowIndex < SlotsGameLua.m_nRowCount do
            local nStackSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(i)
            local nContinueCount = LuaHelper.GetIndexByRate(tableContinueCountRate)

            local nBeginRowIndex = nRowIndex
            local nEndRowIndex = nRowIndex + nContinueCount
            nEndRowIndex = math.min(SlotsGameLua.m_nRowCount - 1, nEndRowIndex)

            for j = nBeginRowIndex, nEndRowIndex do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = nStackSymbolId
            end

            nRowIndex = nRowIndex + nContinueCount
        end
    end

    if rt:InFreeSpin() then
        for x = 1, 3 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if ArabSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = ArabSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
    end

end 

function ArabCustomDeck:ModifyDeckForGemSymbol(deck)
    ArabFunc.tableGemInfo = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if ArabSymbol:isWildSymbol(nSymbolId) then
                local nTriggerType = ArabConfig:GetTriggerGemType()
                local bTrigger, nMultuile = ArabConfig:orTriggerGemMoney()
                if not bTrigger then
                    nMultuile = 0
                end 
                
                ArabFunc.tableGemInfo[nKey] = {nTriggerType, nMultuile}
            end
        end
    end

end

function ArabCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if ArabFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local bTrigger, nTriggerCount = ArabConfig:orTriggerFreeSpin()
    if rt:InFreeSpin() then
        bTrigger = false
    end

    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if ArabSymbol:isWildSymbol(nSymbolId) then
                    deck[nKey] = ArabSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
        
        for x = 1, 3 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                deck[nKey] = nScatterSymbolId
            end
        end
    else
        local bFull = true
        for x = 1, 3 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if not ArabSymbol:isScatterSymbol(nSymbolId) then
                    bFull = false
                    break
                end
            end
        end

        if bFull then
            local nKey = math.random(4, 16)
            deck[nKey] = ArabSymbol:GetCommonSymbolId(nKey)
        end
    end

end
