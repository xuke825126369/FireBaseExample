WitchSymbol = {}

-- 得到普通符号Id
function WitchSymbol:GetCommonSymbolId(nReelId)
    local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    while SlotsGameLua:GetSymbol(nSymbolId).type ~= SymbolType.Normal do
        nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelId)
    end
    return nSymbolId
end

-- 是ReSpin收集 符号吗 ？
function WitchSymbol:isReSpinCollectSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("ReSpinCollect") == nSymbolId
end

-- 是Scatter 符号吗 ？
function WitchSymbol:isScatterSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Scatter") == nSymbolId
end

-- 是Wild 符号吗 ？
function WitchSymbol:isWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId
end

-- 是不能中奖的 符号吗 ？
function WitchSymbol:IsNoLineAwardSymbolId(nSymbolId)
    if self:isScatterSymbol(nSymbolId) or self:isReSpinCollectSymbol(nSymbolId) then
        return true
    end
    
    return false
end

