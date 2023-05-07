WitchCustomDeck = {}

function WitchCustomDeck:ModifyDeckForWin0(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if not bReSpinFlag then
        WitchFunc.m_nWin0Count = WitchFunc.m_nWin0Count + 1
    end 

    if WitchFunc.m_nWin0Count > 3 then
        if math.random() < 0.9 then
            self:CheckWin0Deck(deck)
        end
    end
        
end

function WitchCustomDeck:IsWin0Deck_payLines(deck)
    for i = 1, #SlotsGameLua.m_listLineLua do
        local iResult = {}
        local ld = SlotsGameLua:GetLine(i)
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            iResult[x] = deck[SlotsGameLua.m_nRowCount * x + ld.Slots[x]]
        end 

        local MatchCount = 0
        local nMaxMatchReelID = 0
        local bcond2 = false

        local bWildMatchSuccess = false
        local bIdMatchSuccess = false
        local bAnyBarMatchSuccess = false  
        local bAny7MatchSuccess = false 

        local nSymbolId = -1

        local bMatchSuccess = false
        if not bMatchSuccess then
             bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = WitchFunc:CheckLineSymboltIdSame(iResult)
             if bMatchSuccess then
                bIdMatchSuccess = true
                
                --Debug.Log("ID 匹配成功")
             end
        end

        if not bMatchSuccess then
            bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = WitchFunc:CheckLineWildMatch(iResult)
            if bMatchSuccess then
               bWildMatchSuccess = true
                
               --Debug.Log("Wild 匹配成功")
            end
        end

        local fCombReward = -1
        local nCombIndex = -1

        if bWildMatchSuccess or bIdMatchSuccess then
            fCombReward = SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[MatchCount]
        end 

        if fCombReward > 0.0 then
            return false
        end
    end

	return true
end

function WitchCustomDeck:CheckWin0Deck(deck)
    if self:IsWin0Deck_payLines(deck) then
        local nSymbolId = WitchSymbol:GetCommonSymbolId(0)

        local nRandomLineIndex = math.random(1, #SlotsGameLua.m_listLineLua)
        local ld = SlotsGameLua.m_listLineLua[nRandomLineIndex]

        for i = 0, 2 do
            local nKey = SlotsGameLua.m_nRowCount * i + ld.Slots[i]
            deck[nKey] = nSymbolId
        end
        
        if not WitchFunc.m_bSimulationFlag then
            Debug.Log("------------- win0 中奖: ---------------: "..nSymbolId)
        end

        return true
    end

    return false
end


-------------------------------- 修正 FreeSpin --------------------------------
function WitchCustomDeck:modifyDeckForTriggerFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if bFreeSpinFlag or bReSpinFlag then
        return
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")

    local bTriggerFreeSpin, nTriggerCount = WitchConfig:orFreeSpinTrigger()    
    if bTriggerFreeSpin then
        for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = deck[nKey]
            if WitchSymbol:isScatterSymbol(nSymbolId) then
                local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
                deck[nKey] = WitchSymbol:GetCommonSymbolId(nReelId)
            end
        end

        local tempTable = {}
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            table.insert(tempTable, i)
        end

        local nCount = 0
        while nCount < nTriggerCount do
            nCount = nCount + 1

            local nReelId = table.remove(tempTable, math.random(1, #tempTable))
            local nRowIndex = math.random(0 , SlotsGameLua.m_nRowCount - 1)
            local nKey = SlotsGameLua.m_nRowCount * nReelId + nRowIndex
            deck[nKey] = nScatterSymbolId   
            
        end

    else
        -- 1列 保持一个Scatter
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local tableScatterRowIndex = {}
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = SlotsGameLua.m_nRowCount * x + y
                local nSymbolId = deck[nKey]

                if nSymbolId == nScatterSymbolId then
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
                        deck[nKey] = WitchSymbol:GetCommonSymbolId(x)
                    end
                end
            end
        end

        local tempTable = {} 
        for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
            if WitchSymbol:isScatterSymbol(deck[nKey]) then
                table.insert(tempTable, nKey)
            end
        end

        while #tempTable >= WitchConfig.N_FREESPIN_TRIGGER_MIN_SCATTERCOUNT do
            local nKey = table.remove(tempTable, math.random(1, #tempTable))
            local nReelId = math.floor( nKey / SlotsGameLua.m_nRowCount)
            deck[nKey] = WitchSymbol:GetCommonSymbolId(nReelId)
        end 

    end

    return deck
end

function WitchCustomDeck:modifyDeckForFreeSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if not bFreeSpinFlag then
        return
    end

    if bReSpinFlag then
        return
    end

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nReSpinCollectSymbolId = SlotsGameLua:GetSymbolIdByObjName("ReSpinCollect")

    local nTargetSymbolId = WitchSymbol:GetCommonSymbolId(2)

    local bTriggerFreeSpin, nFreeSpinTriggerCount = WitchConfig:orFreeSpinTrigger()  
    local bTriggerReSpin, nReSpinTriggerCount = WitchConfig:orReSpinTrigger()
    if rt:InFreeSpin() and not rt:HasFreeSpin() then
        bTriggerReSpin = false
    end  

    if bTriggerFreeSpin then
        nTargetSymbolId = nScatterSymbolId

        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                if i >= 1 and i <= 3 then
                    deck[nKey] = nTargetSymbolId
                else
                    deck[nKey] = WitchSymbol:GetCommonSymbolId(2)
                end
            end
        end

        if nFreeSpinTriggerCount > 3 then
            local tableReel = {0, SlotsGameLua.m_nReelCount - 1}

            for k, v in pairs(tableReel) do
                local nReelId = v
                for nRowIndex = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
                    deck[nKey] = WitchSymbol:GetCommonSymbolId(2)
                end
            end 

            local tempTable = {0, SlotsGameLua.m_nReelCount - 1}

            local nCount = 0
            while nCount < nFreeSpinTriggerCount - 3 do
                nCount = nCount + 1

                local nReelId = table.remove(tempTable, math.random(1, #tempTable))
                local nRowIndex = math.random(0 , SlotsGameLua.m_nRowCount - 1)
                local nKey = SlotsGameLua.m_nRowCount * nReelId + nRowIndex
                deck[nKey] = nTargetSymbolId
            end

        end
        
    elseif bTriggerReSpin then
        nTargetSymbolId = nReSpinCollectSymbolId

        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                if i >= 1 and i <= 3 then
                    deck[nKey] = nTargetSymbolId
                else
                    deck[nKey] = WitchSymbol:GetCommonSymbolId(2)
                end
            end
        end

    else
        for i = 1, 3 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                deck[nKey] = nTargetSymbolId
            end
        end
        
    end

end

-------------------------------- 修正 ReSpin -------------------------------- 
function WitchCustomDeck:ModifyReSpinCollectElementProb(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    local nReSpinCollectSymbolId = SlotsGameLua:GetSymbolIdByObjName("ReSpinCollect")

    if bReSpinFlag then 
        for nKey = 0, SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = deck[nKey]
            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) and not WitchFunc.tableReSpinFixedCollectSymbol[nKey] then
                local nReeId = math.floor(nKey / SlotsGameLua.m_nRowCount)
                deck[nKey] = WitchSymbol:GetCommonSymbolId(nReeId)
            end
        end     

        --增加收集 的概率
        local bAddCollectElement, nAddCollectCount = WitchConfig:orReSpinAddCollectElem()
        
        if bAddCollectElement then
            local tempRandomTable = {}
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                for y = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = x * SlotsGameLua.m_nRowCount + y
                    local nSymbolId = deck[nKey]
                    
                    if not WitchFunc.tableReSpinFixedCollectSymbol[nKey] then
                        table.insert(tempRandomTable, nKey)
                    end

                end
            end 

            nAddCollectCount = math.min(nAddCollectCount, #tempRandomTable)
            if not WitchLevelUI.mJackPotUI:orUnlockGrand() then
                if LuaHelper.tableSize(WitchFunc.tableReSpinFixedCollectSymbol) + nAddCollectCount >= SlotsGameLua.m_nRowCount * SlotsGameLua.m_nReelCount then
                    nAddCollectCount = SlotsGameLua.m_nRowCount * SlotsGameLua.m_nReelCount - LuaHelper.tableSize(WitchFunc.tableReSpinFixedCollectSymbol) - 1
                end
            end
            
            local nCount = 0
            while #tempRandomTable > 0 and nCount < nAddCollectCount do
                local nAddKey = tempRandomTable[math.random(1, #tempRandomTable)]
                deck[nAddKey] =  nReSpinCollectSymbolId

                nCount = nCount + 1
            end
                
        end

    end

end

-- 修正ReSpin 触发的Deck
function WitchCustomDeck:ModifyDeckForTriggerRespin(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()

    if bReSpinFlag or bFreeSpinFlag then
        return
    end

    local nReSpinCollectSymbolId = SlotsGameLua:GetSymbolIdByObjName("ReSpinCollect")

    local bTriggerReSpin, nTriggerCount = WitchConfig:orReSpinTrigger()
    if rt:InFreeSpin() and not rt:HasFreeSpin() then
        bTriggerReSpin = false
    end     

    if bTriggerReSpin then
        for nKey = 0, SlotsGameLua.m_nReelCount *  SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = deck[nKey]
            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
                deck[nKey] = WitchSymbol:GetCommonSymbolId(nReelId)
            end
        end

        local tempTable = {}
        for nKey = 0, SlotsGameLua.m_nReelCount *  SlotsGameLua.m_nRowCount - 1 do
            table.insert(tempTable, nKey)
        end

        local nCount = 0
        while nCount < nTriggerCount do
            nCount = nCount + 1

            local nKey = table.remove(tempTable, math.random(1, #tempTable))
            deck[nKey] = nReSpinCollectSymbolId
        end
    else
        local tempTable = {}
        for nKey = 0, SlotsGameLua.m_nReelCount *  SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = deck[nKey]
            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                table.insert(tempTable, nKey)
            end
        end

        while #tempTable >= WitchConfig.N_RESPIN_TRIGGER_MIN_COLLECTCOUNT do
            local nKey = table.remove(tempTable, math.random(1, #tempTable))
            local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
            deck[nKey] = WitchSymbol:GetCommonSymbolId(nReelId)
        end

    end 

end

function WitchCustomDeck:RespinReStoreCollectRecord(deck)
    WitchFunc.tableCollectElementType = {}
    WitchFunc:ReDeckForReSpinFixedSymbol(deck)
end

function WitchCustomDeck:DoRespinCollectRecord(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bTriggerOrInReSpin = rt:InReSpin() or WitchFunc:bCanTriggerReSpin(deck)
    if bTriggerOrInReSpin then
        -- ReSpin 期间去掉Scatter
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = x * SlotsGameLua.m_nRowCount + y
                local nSymbolId = deck[nKey]

                if WitchSymbol:isScatterSymbol(nSymbolId) or WitchSymbol:isWildSymbol(nSymbolId) then
                    deck[nKey] = WitchSymbol:GetCommonSymbolId(x)
                end

            end
        end
    end 
    
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local nSymbolId = deck[nKey]

            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) and (not WitchFunc.tableReSpinFixedCollectSymbol[nKey]) then
                local nType = 0
                local nMoneyMultuile = 0

                if bTriggerOrInReSpin then
                    nType, nMoneyMultuile = WitchConfig:GetReSpinCollectType()
                else
                    nType, nMoneyMultuile = WitchFunc:GetRandomReSpinCollectType()
                end
                
                if rt:InFreeSpin() then
                    if nKey == SlotsGameLua.m_nRowCount * 2 + 1 then
                        nType, nMoneyMultuile = WitchConfig:GetFreeSpinReSpinMiddleCollectType()
                    end
                end

                WitchFunc.tableCollectElementType[nKey] = {nSymbolId, nType, nMoneyMultuile}
            end

        end 
    end
    
end

-------------------------------- 修正 Wild 成列 符号 --------------------------------
function WitchCustomDeck:modifyDeckForWildStack(deck)
    for nKey = 0, SlotsGameLua.m_nRowCount * SlotsGameLua.m_nReelCount - 1 do
        local nSymbolId = deck[nKey]
        if WitchSymbol:isWildSymbol(nSymbolId) then
            local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
            deck[nKey] = WitchSymbol:GetCommonSymbolId(nReelId)
        end
    end

    local nTargetStackSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        local bHaveStack, nTargetIndex  = WitchConfig:orTriggeWildStack(x)
        if bHaveStack then
            local nStackBeginIndex = math.min(SlotsGameLua.m_nRowCount - 1, nTargetIndex)
            local nStackEndIndex = math.max(0, nTargetIndex - 2)
            
            for y = nStackBeginIndex, nStackEndIndex, -1 do
                local nKey = x * SlotsGameLua.m_nRowCount + y
                deck[nKey] = nTargetStackSymbolId
            end
        end
    end

end

