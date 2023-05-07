LuckyVegasSymbol = {}

-- 得到普通符号Id
function LuckyVegasSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function LuckyVegasSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function LuckyVegasSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function LuckyVegasSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("wild") == nSymbolId
end

-- 是Scatter 符号吗 ？
function LuckyVegasSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("scatter") == nSymbolId
end

function LuckyVegasSymbol:isAnyBarSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("bar1") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("bar2") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("bar3") == nSymbolId
end

function LuckyVegasSymbol:isAny7Symbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("7red") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("7blue") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("7green") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function LuckyVegasSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
