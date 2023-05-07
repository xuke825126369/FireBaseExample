RedHatSymbol = {}

-- 得到普通符号Id
function RedHatSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
        
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function RedHatSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function RedHatSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function RedHatSymbol:isWildSymbol(nSymbolId)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 
    
    if rt:InFreeSpin() then
        return SlotsGameLua:GetSymbolIdByObjName("Wild2") == nSymbolId or
            SlotsGameLua:GetSymbolIdByObjName("StickyWild_1") == nSymbolId
    else
        return SlotsGameLua:GetSymbolIdByObjName("WildCoin") == nSymbolId
    end
end

-- 是Scatter 符号吗 ？
function RedHatSymbol:isScatterSymbol(nSymbolId)
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 
    
    if rt:InFreeSpin() then
        return SlotsGameLua:GetSymbolIdByObjName("Scatter12_1") == nSymbolId or
            SlotsGameLua:GetSymbolIdByObjName("Scatter22_1") == nSymbolId
    else
        return SlotsGameLua:GetSymbolIdByObjName("Scatter1") == nSymbolId or
            SlotsGameLua:GetSymbolIdByObjName("Scatter2") == nSymbolId
    end

end

-- 是不能中奖的 符号吗 ？
function RedHatSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if RedHatSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
