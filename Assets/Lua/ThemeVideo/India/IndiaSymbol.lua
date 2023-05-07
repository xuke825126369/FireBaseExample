IndiaSymbol = {}

-- 得到普通符号Id
function IndiaSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function IndiaSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function IndiaSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function IndiaSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("WildDouble") == nSymbolId
end

-- 是Scatter 符号吗 ？
function IndiaSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("scatter") == nSymbolId
end

function IndiaSymbol:isCanDoubleSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Cow") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Girl") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Hat") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Pipa") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Tiger") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId
end

-- 是Double 符号吗 ？
function IndiaSymbol:isDoubleSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("CowDouble") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("GirlDouble") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("HatDouble") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("PipaDouble") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("TigerDouble") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("WildDouble") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function IndiaSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if IndiaSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
