TigerDragonCustomDeck = {}

function TigerDragonCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if TigerDragonFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 
    
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local bTrigger = TigerDragonConfig:orTriggerFreeSpin()
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = TigerDragonSymbol:GetCommonSymbolId(nKey)
                end
            end
        end       

        local tableReelId = {0, 2, 4}
        local nCount = 0
        local nTriggerCount = 3
        while nCount < nTriggerCount do
            nCount = nCount + 1
            local nReelId = table.remove(tableReelId, math.random(1, #tableReelId))
            local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 2)
            local nKey = SlotsGameLua.m_nRowCount * nReelId + nRowIndex
            deck[nKey] = nScatterSymbolId
        end
    else
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local tableScatterRowIndex = {}
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]

                if TigerDragonSymbol:isScatterSymbol(nSymbolId)  then
                    table.insert(tableScatterRowIndex, y)
                end
            end

            if #tableScatterRowIndex > 1 then
                local nHaveScatterIndex = tableScatterRowIndex[math.random(1, #tableScatterRowIndex)]
                for j = 1, #tableScatterRowIndex do
                    local nRowIndex = tableScatterRowIndex[j]
                    local nKey = SlotsGameLua.m_nRowCount * x + nRowIndex

                    local nSymbolId = deck[nKey]
                    if nRowIndex ~= nHaveScatterIndex then
                        deck[nKey] = TigerDragonSymbol:GetCommonSymbolId(nKey)
                    end
                end
            end
        end

        if TigerDragonFunc:bCanTriggerFreeSpin(deck) then
            local tempDeck = {}
            for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
                local nSymbolId = deck[nKey]
                if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tempDeck, nKey)
                end
            end
            
            local nMinScatterCount = 3
            while #tempDeck >= nMinScatterCount do
                local nKey = table.remove(tempDeck, math.random(1, #tempDeck))
                deck[nKey] = TigerDragonSymbol:GetCommonSymbolId(nKey)
            end
        end

    end
end 

function TigerDragonCustomDeck:ModifyDeckForBigSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if TigerDragonFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if TigerDragonSymbol:isWildSymbol(nSymbolId) then
                nSymbolId = TigerDragonSymbol:GetCommonSymbolId(nKey)
            end
            deck[nKey] = nSymbolId
        end
    end  

    local nNanWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("nanxiaWild_1")
    local nNvWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("nvxiaWild_1")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")
    
    TigerDragonFunc.tableBigSymbol = {}
    if rt:InReSpin() then
        TigerDragonFunc.tableBigSymbol[0] = {2, nNanWildSymbolId}
        TigerDragonFunc.tableBigSymbol[4] = {2, nNvWildSymbolId}
        deck[0] = nNullSymbolId
        deck[1] = nNullSymbolId
        deck[16] = nNullSymbolId
        deck[17] = nNullSymbolId
    else
        if not TigerDragonFunc:bCanTriggerFreeSpin(deck) then
            for i = 0, SlotsGameLua.m_nReelCount - 1 do
                if i == 0 or i == 4 then
                    local nWildSymbolId = -1
                    if i == 0 then
                        nWildSymbolId = nNanWildSymbolId
                    elseif i == 4 then
                        nWildSymbolId = nNvWildSymbolId
                    end

                    local bTrigger, nTargetIndex = TigerDragonConfig:orTriggerWildSymbol()
                    if bTrigger then
                        TigerDragonFunc.tableBigSymbol[i] = {nTargetIndex, nWildSymbolId}
                        local nStackBeginIndex = math.min(3, nTargetIndex)
                        local nStackEndIndex = math.max(0, nTargetIndex - 2)
                        for j = nStackBeginIndex, nStackEndIndex, -1 do
                            local nKey = i * SlotsGameLua.m_nRowCount + j
                            if j == nTargetIndex then
                                deck[nKey] = nWildSymbolId
                            else
                                deck[nKey] = nNullSymbolId
                            end
                        end
                    end
                end
            end 
        end
    end

end

