PixieCustomDeck = {}

function PixieCustomDeck:ModifyDeckForBigSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if PixieFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            while PixieSymbol:isBigSymbol(nSymbolId) do
                nSymbolId = PixieSymbol:GetCommonSymbolId(nKey)
            end
            deck[nKey] = nSymbolId
        end
    end 

    PixieFunc.tableBigSymbol = {}
    if rt:InFreeSpin() then
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            if PixieFunc.tableFreeSpinStickyBigSymbol[i] then
                local nRowIndex = PixieFunc.tableFreeSpinStickyBigSymbol[i][1]
                local nSymbolId = PixieFunc.tableFreeSpinStickyBigSymbol[i][2]
                PixieFunc.tableBigSymbol[i] = {nRowIndex, nSymbolId}
            end
        end
    end

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local nBigSymbolId = PixieConfig:GetBigSymbolId()
        local bTrigger, nTargetIndex = PixieConfig:orTriggerBigSymbol(i)
        if PixieFunc.tableBigSymbol[i] then
            nTargetIndex = PixieFunc.tableBigSymbol[i][1]
            nBigSymbolId = PixieFunc.tableBigSymbol[i][2]
            bTrigger = true
        end
        
        if bTrigger then
            PixieFunc.tableBigSymbol[i] = {nTargetIndex, nBigSymbolId}
            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - 3)
            for j = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                if j == nTargetIndex then
                    deck[nKey] = nBigSymbolId
                else
                    deck[nKey] = nNullSymbolId
                end
            end
        end
    end

end

function PixieCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if PixieFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if rt:InFreeSpin() then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if PixieSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = PixieSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
        return
    end 

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local bTrigger = PixieConfig:orTriggerFreeSpin()
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if PixieSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = PixieSymbol:GetCommonSymbolId(nKey)
                end
            end
        end 
        
        local nTriggerCount = 3
        local tableReelId = {2, 3, 4}
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

                if PixieSymbol:isScatterSymbol(nSymbolId)  then
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
                        deck[nKey] = PixieSymbol:GetCommonSymbolId(nKey)
                    end
                end
            end
        end

        if PixieFunc:bCanTriggerFreeSpin(deck) then
            local tempDeck = {}
            for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
                local nSymbolId = deck[nKey]
                if PixieSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tempDeck, nKey)
                end
            end

            local nMinScatterCount = 3
            while #tempDeck >= nMinScatterCount do
                local nKey = table.remove(tempDeck, math.random(1, #tempDeck))
                deck[nKey] = PixieSymbol:GetCommonSymbolId(nKey)
            end
        end

    end 

end     

function PixieCustomDeck:ModifyDeckForWild(deck)
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if PixieSymbol:isWildSymbol(nSymbolId) then
                deck[nKey] = PixieSymbol:GetCommonSymbolId(nKey)
            end
        end
    end

    if PixieConfig:orTriggerWildSymbol() then
        local nReelId = 4
        local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
        local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
        deck[nKey] = nWildSymbolId
    end

end

