IrishCustomDeck = {}

function IrishCustomDeck:ModifyDeckForJackPotSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if IrishFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nJackPotSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Gem")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if IrishSymbol:isJackPotSymbol(nSymbolId) then
                deck[nKey] = IrishSymbol:GetCommonSymbolId(nKey)
            end
        end
    end
    
    local bTrigger, nTriggerCount = IrishConfig:orTriggerJackPotSymbol()
    if bTrigger then
        local tempTable = {}
        local nWildCount = 0
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if IrishSymbol:isWildSymbol(nSymbolId) then
                    nWildCount = nWildCount + 1
                else
                    table.insert(tempTable, nKey)
                end
            end
        end     

        local nCount = nWildCount
        while nCount < nTriggerCount and #tempTable > 0 do
            nCount = nCount + 1
            local nKey = table.remove(tempTable, math.random(1, #tempTable))
            deck[nKey] = nJackPotSymbolId
        end
    end 

end