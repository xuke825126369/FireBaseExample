GodOfWealthSymbol = {}

-- 得到普通符号Id
function GodOfWealthSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function GodOfWealthSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function GodOfWealthSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function GodOfWealthSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId
end

-- 是Scatter 符号吗 ？
function GodOfWealthSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Scatter") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function GodOfWealthSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if GodOfWealthSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
