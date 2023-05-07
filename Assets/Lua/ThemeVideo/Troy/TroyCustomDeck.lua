TroyCustomDeck = {}

function TroyCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if TroyFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 
    
    if rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if TroySymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = TroySymbol:GetCommonSymbolId(nKey)
                end
            end
        end
    else
        local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("scatter")
        local bTrigger, nTriggerCount = TroyConfig:orTriggerFreeSpin()
        if bTrigger then
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                for y = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = SlotsGameLua.m_nRowCount * x + y
                    local nSymbolId = deck[nKey]
                    if TroySymbol:isScatterSymbol(nSymbolId) then
                        deck[nKey] = TroySymbol:GetCommonSymbolId(nKey)
                    end
                end
            end 

            local tableReelId = {0, 1, 2, 3, 4}
            local nCount = 0
            while nCount < nTriggerCount do
                nCount = nCount + 1
                local nReelId = table.remove(tableReelId, math.random(1, #tableReelId))
                local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
                local nKey = SlotsGameLua.m_nRowCount * nReelId + nRowIndex
                deck[nKey] = nScatterSymbolId
            end
        else
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                local tableScatterRowIndex = {}
                for y = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = SlotsGameLua.m_nRowCount * x + y
                    local nSymbolId = deck[nKey]

                    if TroySymbol:isScatterSymbol(nSymbolId)  then
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
                            deck[nKey] = TroySymbol:GetCommonSymbolId(nKey)
                        end
                    end
                end
            end

            if TroyFunc:bCanTriggerFreeSpin(deck) then
                local tempDeck = {}
                for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
                    local nSymbolId = deck[nKey]
                    if TroySymbol:isScatterSymbol(nSymbolId) then
                        table.insert(tempDeck, nKey)
                    end
                end

                local nMinScatterCount = 3
                if rt:InFreeSpin() then
                    nMinScatterCount = 2
                end

                while #tempDeck >= nMinScatterCount do
                    local nKey = table.remove(tempDeck, math.random(1, #tempDeck))
                    deck[nKey] = TroySymbol:GetCommonSymbolId(nKey)
                end
            end

        end
    end

end 

