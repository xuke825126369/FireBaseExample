local VideoSlotSymbolRandomChoice = {}

function VideoSlotSymbolRandomChoice:New()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--@Virtual
function VideoSlotSymbolRandomChoice:Init(rateInfo, m_nReelCount)
    self.mapSymbolRateInfo = rateInfo
    self.nMaxSymbolId = -1
    self.m_nReelCount = m_nReelCount
    for k, v in pairs(self.mapSymbolRateInfo) do
        if k > self.nMaxSymbolId then
            self.nMaxSymbolId = k
        end
    end
    
    self.mapReturnRateToRandomChoice = {}
    for k, v in pairs(enumReturnRateTYPE) do
        local nReturnType = v
        if nReturnType ~= enumReturnRateTYPE.enumReturnType_None then
            self.mapReturnRateToRandomChoice[nReturnType] = self:GetReturnTypeRandomChoice(nReturnType)
        end
    end 

end

function VideoSlotSymbolRandomChoice:GetReturnTypeRandomChoice(returnType)
    local m_randomChoices = {}
    for i = 0, self.m_nReelCount - 1 do
        m_randomChoices[i] = {}

        for j = 1, self.nMaxSymbolId do
            if self.mapSymbolRateInfo[j] then
                m_randomChoices[i][j] = self:GetSymbolRateByReturnType(self.mapSymbolRateInfo[j], returnType, i)
            else
                m_randomChoices[i][j] = 0
            end
        end
    end 

    return m_randomChoices
end

function VideoSlotSymbolRandomChoice:GetSymbolRateByReturnType(rateInfo, returnType, nReelIndex)
    if returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        return rateInfo.m_frequency95[nReelIndex + 1]
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        return rateInfo.m_frequency50[nReelIndex + 1]
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        return rateInfo.m_frequency200[nReelIndex + 1]
    else
        Debug.Assert(false, tostring(returnType))
    end

    return 0
end

function VideoSlotSymbolRandomChoice:ChoiceSymbolId(nReelId)
    local nReturnType = ReturnRateManager.m_enumReturnRateType
    local randomChoice = self.mapReturnRateToRandomChoice[nReturnType]
    local tableRate = randomChoice[nReelId]
    local nIndex = LuaHelper.GetIndexByRate(tableRate)
    Debug.Assert(nIndex >= 1)
    return nIndex
end

------------------------------------------------- 兼容2020某些关卡 -------------------------------------------------
function VideoSlotSymbolRandomChoice:ModifySymbolRate(nReelId, nSymbolId, fAddRate)
    local nReturnType = ReturnRateManager.m_enumReturnRateType
    local randomChoice = self.mapReturnRateToRandomChoice[nReturnType]
    local tableRate = randomChoice[nReelId]
    tableRate[nSymbolId] = tableRate[nSymbolId] + fAddRate
end

function VideoSlotSymbolRandomChoice:SetSymbolRate(nReelId, nSymbolId, fSymbolRate)
    local nReturnType = ReturnRateManager.m_enumReturnRateType
    local randomChoice = self.mapReturnRateToRandomChoice[nReturnType]
    local tableRate = randomChoice[nReelId]
    tableRate[nSymbolId] = fSymbolRate
end

function VideoSlotSymbolRandomChoice:GetReelIdRateInfo(nReelId)
    local nReturnType = ReturnRateManager.m_enumReturnRateType
    local tableInfo = {}
    tableInfo.ValueTotal = 0
    local randomChoice = self.mapReturnRateToRandomChoice[nReturnType]
    local tableRate = randomChoice[nReelId]
    
    Debug.Assert(tableRate, "tableRate == nil: "..nReelId)
    if tableRate == nil then
        Debug.LogError("bInit: "..tostring(self.bInit))
    end

    for k, v in pairs(tableRate) do
        tableInfo.ValueTotal = tableInfo.ValueTotal + v
    end
    tableInfo.Values = tableRate
    return tableInfo
end

return VideoSlotSymbolRandomChoice
