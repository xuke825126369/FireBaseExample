RedHatFreeSpinSymbol = {}

-- 得到普通符号Id
function RedHatFreeSpinSymbol:GetCommonSymbolId(nKey)
    local nReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)

    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

function RedHatFreeSpinSymbol:GetCommonSymbolIdByReelId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    
    return nSymbolId
end

-- 是 普通 符号Id 吗 ？
function RedHatFreeSpinSymbol:isCommonSymbolId(nSymbolId)
    return SlotsGameLua:GetSymbol(nSymbolId).type == SymbolType.Normal
end

-- 是Wild 符号吗 ？
function RedHatFreeSpinSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild2") == nSymbolId
        SlotsGameLua:GetSymbolIdByObjName("StickyWild_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("StickyWild_2") == nSymbolId
end

-- 是Scatter 符号吗 ？
function RedHatFreeSpinSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Scatter12_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Scatter12_2") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Scatter22_1") == nSymbolId or
        SlotsGameLua:GetSymbolIdByObjName("Scatter22_2") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function RedHatFreeSpinSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if RedHatFreeSpinSymbol:isScatterSymbol(nSymbolId) then
        return true
    end

    return false
end
