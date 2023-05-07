RedHatCustomDeck = {}

function RedHatCustomDeck:ModifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    local nScatter1SymbolId = -1
    local nScatter2SymbolId = -1
    if rt:InFreeSpin() then
        nScatter1SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter12_1")
        nScatter2SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter22_1")
    else
        nScatter1SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter1")
        nScatter2SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter2")
    end

    local bTrigger, nScatterCount = RedHatConfig:orTriggerFreeSpin()
    if not rt:InFreeSpin() then
        if RedHatFunc:GetWildSymbolCount(deck) + RedHatFunc.nCollectCount >= RedHatFunc:GetBonusFeatureMaxCollectCount() then
            bTrigger = false
        end
    end

    if bTrigger then
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if RedHatSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey] = RedHatSymbol:GetCommonSymbolId(nKey)
                end
            end
        end 

        local nMinReelCount = nScatterCount // SlotsGameLua.m_nRowCount
        if nScatterCount % SlotsGameLua.m_nRowCount ~= 0 then
            nMinReelCount = nMinReelCount + 1
        end

        local nMaxReelCount = math.min(nScatterCount, SlotsGameLua.m_nReelCount)
        local nTargetReelCount = math.random(nMinReelCount, nMaxReelCount)

        local tableKeys = {}
        for i = 0, nTargetReelCount - 1 do
            local nRowIndex = math.random(0, SlotsGameLua.m_nRowCount - 1)
            local nKey = i * SlotsGameLua.m_nRowCount + nRowIndex
            if math.random(1, 2) == 1 then
                deck[nKey] = nScatter1SymbolId
            else
                deck[nKey] = nScatter2SymbolId
            end

            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                if j ~= nRowIndex then
                    local nKey = i * SlotsGameLua.m_nRowCount + j
                    table.insert(tableKeys, nKey)
                end
            end
        end

        local nCount = nTargetReelCount
        while nCount < nScatterCount and #tableKeys > 0 do
            nCount = nCount + 1
            local nKey = table.remove(tableKeys, math.random(1, #tableKeys))
            if math.random(1, 2) == 1 then
                deck[nKey] = nScatter1SymbolId
            else
                deck[nKey] = nScatter2SymbolId
            end
        end
    else
        local nScatterCount = 0
        local nReelIdCount = 0
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            nReelIdCount = nReelIdCount + 1
            local bHaveScatter = false
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]
                if RedHatSymbol:isScatterSymbol(nSymbolId)  then
                    nScatterCount = nScatterCount + 1
                    bHaveScatter = true
                end
            end
            
            if nScatterCount >= 4 or (not bHaveScatter) then
                break
            end
        end

        if nScatterCount >= 4 then
            local nReelId = nReelIdCount
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * nReelId + y
                local nSymbolId = deck[nKey]
                if RedHatSymbol:isScatterSymbol(nSymbolId)  then
                    deck[nKey] = RedHatSymbol:GetCommonSymbolId(nKey)
                end
            end

            local tableKeys = {}
            for x = 0, nReelIdCount - 1 do
                for y = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = SlotsGameLua.m_nRowCount * x + y
                    local nSymbolId = deck[nKey]
                    if RedHatSymbol:isScatterSymbol(nSymbolId)  then
                        table.insert(tableKeys, nKey)
                    end
                end
            end

            while #tableKeys >= 4 do
                local nKey = table.remove(tableKeys, math.random(1, #tableKeys))
                deck[nKey] = RedHatSymbol:GetCommonSymbolId(nKey)
            end
        end
    end

end         

function RedHatCustomDeck:ModifyDeckForTriggerWild(deck)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if rt:InFreeSpin() then
        return
    end

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("WildCoin")

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if RedHatSymbol:isWildSymbol(nSymbolId) then
                deck[nKey] = RedHatSymbol:GetCommonSymbolId(nKey)
            end
        end
    end     

    local bTrigger, nWildCount = RedHatConfig:orTriggerWildSymbol()
    if bTrigger then
        local tempKeys = {}
        for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
            table.insert(tempKeys, nKey)
        end

        local nCount = 0
        while nCount < nWildCount do
            nCount = nCount + 1
            local nKey = table.remove(tempKeys, math.random(1, #tempKeys))
            deck[nKey] = nWildSymbolId
        end
    end

end 

function RedHatCustomDeck:ModifyDeckForFreeSpinBigSymbol(deck)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if not rt:InFreeSpin() then
        return
    end

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild2")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local bHaveFiexedSymbol = false

        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            if LuaHelper.tableContainsElement(RedHatFunc.tableFreeSpinStickySymbol, nKey) then
                deck[nKey] = nWildSymbolId
                bHaveFiexedSymbol = true

                for j = -1, 1 do
                    if j ~= 0 then
                        local y1 = y + j
                        if y1 >= 0 and y1 < SlotsGameLua.m_nRowCount then
                            local nKey1 = SlotsGameLua.m_nRowCount * x + y1
                            local nSymbolId1 = deck[nKey1]
                            if RedHatSymbol:isWildSymbol(nSymbolId1) or RedHatSymbol:isScatterSymbol(nSymbolId1) then
                                deck[nKey1] = RedHatSymbol:GetCommonSymbolId(nKey1)
                            end
                        end
                    end
                end
            end
        end
    end 

    local nSymbol_nullId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if y < SlotsGameLua.m_nRowCount - 1 then
                if RedHatSymbol:isWildSymbol(nSymbolId) or RedHatSymbol:isScatterSymbol(nSymbolId) then
                    deck[nKey + 1] = nSymbol_nullId
                end
            else
                deck[nKey] = RedHatSymbol:GetCommonSymbolId(nKey)
            end
        end
    end     

end

function RedHatCustomDeck:ModifyDeckForWildAddFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    RedHatFunc.tableWildAddFreeSpinKeys = {}
    if rt:InFreeSpin() then
        return
    end
    
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolId = deck[nKey]
            if RedHatSymbol:isWildSymbol(nSymbolId) then
                if RedHatFunc:orBonusFreeSpinFull() then
                    RedHatFunc.tableWildAddFreeSpinKeys[nKey] = 0
                else
                    RedHatFunc.tableWildAddFreeSpinKeys[nKey] = RedHatConfig:GetWildSymbolTriggerFreeSpinCount()
                end
            end
        end
    end     

end

