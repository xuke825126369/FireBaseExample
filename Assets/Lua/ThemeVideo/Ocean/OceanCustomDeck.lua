OceanCustomDeck = {}

function OceanCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if OceanFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if OceanSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = OceanSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
        
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if OceanSymbol:isWildSymbol(nSymbolId) then
                    local bTrigger, nWildSymbolId = OceanConfig:orTriggerWildX2()
                    if bTrigger then
                        deck[nKey] = nWildSymbolId
                    end
                end
            end
        end
        return
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Scatter")
    local bTrigger, nTriggerCount = OceanConfig:orTriggerFreeSpin()
    if OceanFunc:bCanTriggerBonusGame(deck) then
        return false
    end
    
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if OceanSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = OceanSymbol:GetCommonSymbolId(nKey)
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

                if OceanSymbol:isScatterSymbol(nSymbolId)  then
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
                        deck[nKey] = OceanSymbol:GetCommonSymbolId(nKey)
                    end
                end
            end
        end
        
        if OceanFunc:bCanTriggerFreeSpin(deck) then
            local tempDeck = {}
            for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
                local nSymbolId = deck[nKey]
                if OceanSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tempDeck, nKey)
                end
            end
            
            local nMinScatterCount = 3
            while #tempDeck >= nMinScatterCount do
                local nKey = table.remove(tempDeck, math.random(1, #tempDeck))
                deck[nKey] = OceanSymbol:GetCommonSymbolId(nKey)
            end
        end

    end

end 

function OceanCustomDeck:ModifyDeckForBonusGame(deck)
    local rt = SlotsGameLua.m_GameResult
    if OceanFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if OceanSymbol:isBonusSymbol(nSymbolId) then
                    deck[nKey] = OceanSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
        return
    end

    local nBonusSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Bonus")
    local bTrigger = OceanConfig:orTriggerBonusGame()
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if OceanSymbol:isBonusSymbol(nSymbolId) then
                    deck[nKey] = nBonusSymbolId
                end
            end
        end

        local nReelId = 4
        for nRowIndex = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
            deck[nKey] = nBonusSymbolId
        end
    else
        local bFullBonus = true
        local nReelId = 4
        for nRowIndex = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
            local nSymbolId = deck[nKey]
            if not OceanSymbol:isBonusSymbol(nSymbolId) then
                bFullBonus = false
                break
            end
        end

        if bFullBonus then
            local nIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
            local nKey = nReelId * SlotsGameLua.m_nRowCount + nIndex
            deck[nKey] = OceanSymbol:GetCommonSymbolIdByReelId(nReelId)
        end
    end

end

