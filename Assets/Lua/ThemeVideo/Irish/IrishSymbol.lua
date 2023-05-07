IrishSymbol = {}

-- 得到普通符号Id
function IrishSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
    
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function IrishSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function IrishSymbol:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
    if IrishSymbol:isNullSymbol(nPreSymbolID) then
        while IrishSymbol:isNullSymbol(nSymbolID) do
            nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelID)
        end
    else
        nSymbolID = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    end
    
    return nSymbolID
end

-- 是 普通 符号Id 吗 ？
function IrishSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function IrishSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Wild") == nSymbolId
end

function IrishSymbol:isNullSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_null") == nSymbolId
end

function IrishSymbol:isLeafSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_4Leaf") == nSymbolId
end

function IrishSymbol:isJackPotSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Gem") == nSymbolId
end

function IrishSymbol:isAnyBarSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_1Bar") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Symbol_2Bar") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Symbol_3Bar") == nSymbolId
end

function IrishSymbol:isAny7Symbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_7Green") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Symbol_7Red") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function IrishSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if IrishSymbol:isNullSymbol(nSymbolId) then
        return true
    end
    
    if IrishSymbol:isJackPotSymbol(nSymbolId) then
        return true
    end

    return false
end
