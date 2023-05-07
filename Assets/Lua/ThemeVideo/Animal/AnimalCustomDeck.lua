AnimalCustomDeck = {}

function AnimalCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if AnimalFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("SCATTER")
    local bTrigger, nTriggerCount = AnimalConfig:orTriggerFreeSpin()
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AnimalSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = AnimalSymbol:GetCommonSymbolId(nKey)
                end
            end
        end

        local tableKeys = {}
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                if nKey ~= 3 or nKey ~= 19 then
                    table.insert(tableKeys, nKey)
                end
            end
        end
        
        local nCount = 0
        while nCount < nTriggerCount and #tableKeys > 0 do
            nCount = nCount + 1
            local nKey = table.remove(tableKeys, math.random(1, #tableKeys))
            deck[nKey] = nScatterSymbolId
        end

    else
        local tableScatterKeys = {}
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AnimalSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tableScatterKeys, nKey)
                end
            end
        end

        local nTriggerFreeSpinMinScatter = 5
        while #tableScatterKeys >= nTriggerFreeSpinMinScatter do
            local nKey = table.remove(tableScatterKeys, math.random(1, #tableScatterKeys))
            deck[nKey] = AnimalSymbol:GetCommonSymbolId(nKey)
        end
    end     
    
end