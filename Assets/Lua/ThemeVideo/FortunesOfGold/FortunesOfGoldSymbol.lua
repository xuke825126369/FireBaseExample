FortunesOfGoldSymbol = {}

-- 得到普通符号Id
function FortunesOfGoldSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

function FortunesOfGoldSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end

    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function FortunesOfGoldSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function FortunesOfGoldSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId
end

function FortunesOfGoldSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Scatter") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function FortunesOfGoldSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if self:isScatterSymbol(nSymbolId) then
        return true
    end
    return false
end
