MardiGrasSymbol = {}

-- 得到普通符号Id
function MardiGrasSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function MardiGrasSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function MardiGrasSymbol:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
    if MardiGrasSymbol:isNullSymbol(nPreSymbolID) then
        while MardiGrasSymbol:isNullSymbol(nSymbolID) do
            nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelID)
        end
    else
        nSymbolID = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
    end
    
    return nSymbolID
end

-- 是 普通 符号Id 吗 ？
function MardiGrasSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function MardiGrasSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_2") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_3") == nSymbolId
end

function MardiGrasSymbol:isNullSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_null") == nSymbolId
end

function MardiGrasSymbol:isAnyBarSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_1Bar") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Symbol_2Bar") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Symbol_3Bar") == nSymbolId
end

function MardiGrasSymbol:isAnyMardiGrasWheelSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Symbol_Mardigras") == nSymbolId or 
        SlotsGameLua:GetSymbolIdByObjName("Symbol_1X3Wild_1") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function MardiGrasSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if MardiGrasSymbol:isNullSymbol(nSymbolId) then
        return true
    end

    return false
end
