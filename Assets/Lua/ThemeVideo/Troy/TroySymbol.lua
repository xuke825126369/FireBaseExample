TroySymbol = {}

-- 得到普通符号Id
function TroySymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
    
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function TroySymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function TroySymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function TroySymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("normalWild") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("nvshenWild") == nSymbolId
end

-- 是Scatter 符号吗 ？
function TroySymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("scatter") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function TroySymbol:IsNoLineAwardSymbolId(nSymbolId)
    if TroySymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
