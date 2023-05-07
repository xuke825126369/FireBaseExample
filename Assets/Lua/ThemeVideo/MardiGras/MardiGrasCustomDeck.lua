MardiGrasCustomDeck = {}

function MardiGrasCustomDeck:ModifyDeckForStackWild(deck)
    local rt = SlotsGameLua.m_GameResult
    if MardiGrasFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if nSymbolId == nWildSymbolId then
                deck[nKey] = MardiGrasSymbol:GetCommonSymbolId(nKey)
            end
        end
    end 

    MardiGrasFunc.tableWildSymbol = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local bTrigger, nTargetIndex = MardiGrasConfig:orTriggerWildStackSymbol(i)
        if bTrigger then
            MardiGrasFunc.tableWildSymbol[i] = nTargetIndex
            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - 2)
            for j = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                if j == nTargetIndex then
                    deck[nKey] = nWildSymbolId
                else
                    deck[nKey] = nNullSymbolId
                end
            end
            
            for j = nStackEndIndex - 1, 0, -1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local nSymbolId = deck[nKey]
                local nPreSymbolID = deck[nKey + 1]
                if j == nStackEndIndex - 1 then
                    nPreSymbolID = nWildSymbolId
                end
                nSymbolId = MardiGrasSymbol:checkSymbolAdjacent(i, nSymbolId, nPreSymbolID)
                if MardiGrasSymbol:isWildSymbol(nSymbolId) then
                    nSymbolId = MardiGrasSymbol:GetCommonSymbolId(nKey)
                end
                deck[nKey] = nSymbolId
            end

            for j = nStackBeginIndex + 1, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local nSymbolId = deck[nKey]
                local nPreSymbolID = deck[nKey - 1]
                nSymbolId = MardiGrasSymbol:checkSymbolAdjacent(i, nSymbolId, nPreSymbolID)
                if MardiGrasSymbol:isWildSymbol(nSymbolId) then
                    nSymbolId = MardiGrasSymbol:GetCommonSymbolId(nKey)
                end
                deck[nKey] = nSymbolId
            end
        end
    end 

end 

function MardiGrasCustomDeck:ModifyDeckForWheelFeature(deck)
    local rt = SlotsGameLua.m_GameResult
    if MardiGrasFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end
    
    MardiGrasFunc.tableWheelKey = {}
    if not rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if MardiGrasSymbol:isCommonSymbolId(nSymbolId) then
                    if MardiGrasConfig:orTriggerWheel() then
                        table.insert(MardiGrasFunc.tableWheelKey, nKey)
                        break
                    end 
                end
            end
        end
    end

end