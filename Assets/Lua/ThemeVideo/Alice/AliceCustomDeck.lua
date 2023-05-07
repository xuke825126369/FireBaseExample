AliceCustomDeck = {}

function AliceCustomDeck:ModifyDeckForAlice(deck)
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nAliceSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild_Alice")
    local nNullSymbolId = SlotsGameLua:GetSymbolIdByObjName("NullSymbol")

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if nSymbolId == nAliceSymbolId then
                deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
            end
        end
    end       
    
    local bCanTriggerFreeSpin = AliceFunc:bCanTriggerFreeSpin(deck) 
    AliceFunc.tableAliceSymbol = {}

    if not bCanTriggerFreeSpin then
        for i = 1, 3 do
            local bTrigger, nTargetIndex  = AliceConfig:orTriggerAliceSymbol(i)
            if bTrigger then
                AliceFunc.tableAliceSymbol[i] = nTargetIndex

                local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
                local nStackEndIndex = math.max(0, nTargetIndex - SlotsGameLua.m_nRowCount + 1)

                for j = nStackBeginIndex, nStackEndIndex, -1 do
                    local nKey = i * SlotsGameLua.m_nRowCount + j
                    if j == nTargetIndex then
                        deck[nKey] = nAliceSymbolId
                    else
                        deck[nKey] = nNullSymbolId 
                    end
                end
            end
        end 
    end

    if rt:InFreeSpin() and AliceFunc.nPickQueenFeature == 3 then
        for k, v in pairs(AliceFunc.tableFixedAliceSymbol) do
            local nReelId = k
            local nTargetIndex = v
            
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = nReelId * SlotsGameLua.m_nRowCount + j
                deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
            end

            AliceFunc.tableAliceSymbol[nReelId] = nTargetIndex
            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - SlotsGameLua.m_nRowCount + 1)

            for j = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = nReelId * SlotsGameLua.m_nRowCount + j
                if j == nTargetIndex then
                    deck[nKey] = nAliceSymbolId
                else
                    deck[nKey] = nNullSymbolId 
                end
            end
        end
    end

end

function AliceCustomDeck:ModifyDeckForScatter(deck)
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("SCATTER")
    local tableScatterReelIds = {0, 2, 4}
    if rt:InFreeSpin() then
        tableScatterReelIds = {0, 4}
    end     

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        if not LuaHelper.tableContainsElement(tableScatterReelIds, i) then
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local nSymbolId = deck[nKey]
                if AliceSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
                end
            end
        end
    end

end

function AliceCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("SCATTER")
    local bTrigger, nTriggerCount = AliceConfig:orTriggerFreeSpin() 
    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AliceSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
                end
            end
        end

        if rt:InFreeSpin() then
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                if x ~= 1 and x ~= 2 and x ~= 3 then
                    if not AliceFunc.tableAliceSymbol[x] then
                        local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
                        local nKey = SlotsGameLua.m_nRowCount * x + nRowIndex
                        deck[nKey] = nScatterSymbolId
                    end
                end
            end
        else
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                if x ~= 1 and x ~= 3 then
                    if AliceFunc.tableAliceSymbol[x] then
                        AliceFunc.tableAliceSymbol[x] = nil
                        for j = 0, SlotsGameLua.m_nRowCount - 1 do
                            local nKey = x * SlotsGameLua.m_nRowCount + j
                            deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
                        end
                    end

                    local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
                    local nKey = SlotsGameLua.m_nRowCount * x + nRowIndex
                    deck[nKey] = nScatterSymbolId
                end
            end
        end

    else

        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AliceSymbol:isScatterSymbol(nSymbolId) and AliceFunc.tableAliceSymbol[x] then
                    deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
                end
            end
        end

        local tableScatterKeys = {}
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if AliceSymbol:isScatterSymbol(nSymbolId) then
                    table.insert(tableScatterKeys, nKey)
                end
            end
        end

        local nTriggerFreeSpinMinScatter = 3
        if rt:InFreeSpin() then
            nTriggerFreeSpinMinScatter = 2
        end

        while #tableScatterKeys >= nTriggerFreeSpinMinScatter do
            local nKey = table.remove(tableScatterKeys, math.random(1, #tableScatterKeys))
            deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
        end
    end 

end

function AliceCustomDeck:ModifyDeckForStackWild(deck)
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]
            if nSymbolId == nWildSymbolId then
                deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
            end
        end
    end

    if not rt:InFreeSpin() then
        return
    end

    if AliceFunc.nPickQueenFeature ~= 2 then
        return
    end

    if AliceFunc:bCanTriggerFreeSpin(deck) then
        return
    end

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local bTrigger, nTargetIndex = AliceConfig:orTriggerWildStackSymbol(i)
        if bTrigger then
            AliceFunc.tableAliceSymbol[i] = nil
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = AliceSymbol:GetCommonSymbolId(nKey)
            end

            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - SlotsGameLua.m_nRowCount + 1)

            for j = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = nWildSymbolId
            end
        end
    end 

end 