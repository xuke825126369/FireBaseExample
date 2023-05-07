AfricaManiaCustomDeck = {}

function AfricaManiaCustomDeck:ModifyDeckForScatterStack(deck)
    local rt = SlotsGameLua.m_GameResult
    if AfricaManiaFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("scatter")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                deck[nKey] = AfricaManiaSymbol:GetCommonSymbolId(nKey)
            end
        end
    end     

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local bHaveStack, nTargetIndex  = AfricaManiaConfig:CheckWildStack(i)
        if bHaveStack then
            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - SlotsGameLua.m_nRowCount + 1)

            for j = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = nScatterSymbolId
            end
        end
    end
    
end

function AfricaManiaCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if AfricaManiaFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end
    
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("scatter")
    if rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = AfricaManiaSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
        return
    end 

    local bTrigger, nTriggerCount = AfricaManiaConfig:orTriggerFreeSpin()
    if bTrigger then
        local tableNoScatterKeys = {}
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if not AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tableNoScatterKeys, nKey)
                end
            end
        end

        local nNowScatterCount = 24 - #tableNoScatterKeys
        local nNeedCount = nTriggerCount - nNowScatterCount
        local nCount = 0
        while nCount < nNeedCount do
            nCount = nCount + 1
            local nKey = table.remove(tableNoScatterKeys, math.random(1, #tableNoScatterKeys))
            deck[nKey] = nScatterSymbolId
        end
    else
        local tableScatterKeys = {}
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tableScatterKeys, nKey)
                end
            end
        end 

        while #tableScatterKeys >= 10 do
            local nKey = table.remove(tableScatterKeys, math.random(1, #tableScatterKeys))
            deck[nKey] = AfricaManiaSymbol:GetCommonSymbolId(nKey)
        end
    end

end