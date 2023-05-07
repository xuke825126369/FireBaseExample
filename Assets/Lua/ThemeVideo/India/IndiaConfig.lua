IndiaConfig = {}

function IndiaConfig:GetSymbolReward(nSymbolId, nMatchCount)
    local strSymbolName = SlotsGameLua:GetSymbol(nSymbolId).prfab.name
    if strSymbolName == "Cow" or strSymbolName == "CowDouble" then
        return {0, 0, 8, 12, 15, 25, 40, 80, 100, 150}
    elseif strSymbolName == "Girl" or strSymbolName == "GirlDouble" then
        return {0, 0, 10, 15, 30, 50, 80, 100, 150, 300}
    elseif strSymbolName == "Hat" or strSymbolName == "HatDouble" then
        return {0, 0, 5, 7, 12, 20, 35, 55, 80, 100}
    elseif strSymbolName == "Pipa" or strSymbolName == "PipaDouble" then
        return {0, 0, 5, 7, 12, 20, 35, 55, 80, 100}
    elseif strSymbolName == "Tiger" or strSymbolName == "TigerDouble" then
        return {0, 0, 8, 12, 15, 25, 40, 80, 100, 150}
    elseif strSymbolName == "Symbol_A" then
        return {0, 0, 3, 6, 9, 12, 15, 30, 50, 0}
    elseif strSymbolName == "Symbol_K" then
        return {0, 0, 3, 6, 9, 12, 15, 30, 50, 0}
    elseif strSymbolName == "Symbol_Q" then
        return {0, 0, 2, 3, 5, 8, 10, 15, 30, 0}
    elseif strSymbolName == "Symbol_J" then
        return {0, 0, 2, 3, 5, 8, 10, 15, 30, 0}
    elseif strSymbolName == "Symbol_10" then
        return {0, 0, 2, 3, 5, 8, 10, 15, 30, 0}
    elseif strSymbolName == "Wild" or strSymbolName == "WildDouble" then
        return {0, 0, 20, 40, 80, 150, 300, 500, 1000, 2000}
    elseif strSymbolName == "scatter" then
        return {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    else
        Debug.Assert(false)
    end
end

function IndiaConfig:GetFreeSpinCount(nScatterCount)    
    if nScatterCount == 3 then
        return 15
    elseif nScatterCount == 4 then
        return 25
    elseif nScatterCount == 5 then
        return 40
    else
        Debug.Assert(false)
    end
end

function IndiaConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.0
    local tableTriggerScatterCountRate = {0, 0, 1, 1, 1}
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.005
        tableTriggerScatterCountRate = {0, 0, 100, 50, 10}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.01
        tableTriggerScatterCountRate = {0, 0, 100, 50, 10}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.02
        tableTriggerScatterCountRate = {0, 0, 100, 50, 10}
    end 
    
    if self.m_bFreeSpinTest then
        fTriggerRate = 0.5
    end

    local bTrigger = math.random() < fTriggerRate
    local nScatterCount = LuaHelper.GetIndexByRate(tableTriggerScatterCountRate)
    return bTrigger, nScatterCount
end

------------------- 测试 -------------------------
function IndiaConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    self.m_bFreeSpinTest = false
    self.m_bBonusGameTest = false

    if self.m_nThemeTestType == 1 then
        self.m_bFreeSpinTest = true
    end     
end    

IndiaConfig:InitTestData()