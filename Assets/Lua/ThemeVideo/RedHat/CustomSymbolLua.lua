local SymbolLua = {}

function SymbolLua:create(nSymbolID, symbol)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    
    o:Init(nSymbolID, symbol)
    return o
end

function SymbolLua:Init(nSymbolID, symbol)
    self.m_nSymbolID = nSymbolID
    self.prfab = self:getSymbolPrefab(symbol.m_strPrefabName)
    self.type = symbol.m_nSymbolType

    self.m_frequency50 = {}
    self.m_frequency95 = {}
    self.m_frequency200 = {}
    self.m_fRewards = {}
        
    for i = 1, #symbol.m_fRewards do
        if symbol.m_frequency50[i] then
            self.m_frequency50[i] = symbol.m_frequency50[i]
        else
            self.m_frequency50[i] = symbol.m_frequency50[#symbol.m_frequency50]
        end

        if symbol.m_frequency95[i] then
            self.m_frequency95[i] = symbol.m_frequency95[i]
        else
            self.m_frequency95[i] = symbol.m_frequency95[#symbol.m_frequency95]
        end

        if symbol.m_frequency200[i] then
            self.m_frequency200[i] = symbol.m_frequency200[i]
        else
            self.m_frequency200[i] = symbol.m_frequency200[#symbol.m_frequency200]
        end 

        Debug.Assert(symbol.m_fRewards[i] ~= nil)
        self.m_fRewards[i] = symbol.m_fRewards[i]
    end
    
end

function SymbolLua:getSymbolPrefab(strName)
    local assetPath = "SymbolPrefab2/"..strName..".prefab"
	local prefabRes = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    return prefabRes
end

function SymbolLua:GetSymbolRateByReturnType(returnType, nReelIndex)
    if returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        return self.m_frequency95[nReelIndex + 1]
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        return self.m_frequency50[nReelIndex + 1]
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        return self.m_frequency200[nReelIndex + 1]
    end

    return -1
end

return SymbolLua
