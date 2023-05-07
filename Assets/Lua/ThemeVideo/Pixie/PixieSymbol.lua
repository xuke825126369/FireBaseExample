PixieSymbol = {}

-- 得到普通符号Id
function PixieSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
        
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function PixieSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function PixieSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function PixieSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId
end

-- 是Scatter 符号吗 ？
function PixieSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Scatter") == nSymbolId
end

-- 是Big 符号吗 ？
function PixieSymbol:isBigSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("PixieBlueA_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("PixieGreenB_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("PixieRedC_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("PixieYellowD_1") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function PixieSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if PixieSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
