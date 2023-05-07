OceanSymbol = {}

-- 得到普通符号Id
function OceanSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
    
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function OceanSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function OceanSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function OceanSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Wild") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Symbol_Wildx2") == nSymbolId or  
        SlotsGameLua:GetSymbolIdByObjName("Symbol_Wildx3") == nSymbolId
end

-- 是Scatter 符号吗 ？
function OceanSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Scatter") == nSymbolId
end

-- 是Bonus 符号吗 ？
function OceanSymbol:isBonusSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Bonus") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function OceanSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if OceanSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
