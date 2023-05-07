OceanConfig = {}

OceanConfig.TABLE_JACKPOT_MIN_MULTUILE = {20, 50, 100, 500} -- 最小倍数
OceanConfig.TABLE_JACKPOT_ADDCOEF = {0.001, 0.002, 0.003, 0.004} -- 增长系数

function OceanConfig:GetFreeSpinCount(nScatterCount)
    return 5 * (nScatterCount - 1)
end

function OceanConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.0
    local tableTriggerScatterCountRate = {0, 0, 100, 50, 10}
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.005
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.01
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.02
    end

    if self.m_bFreeSpinTest then
        fTriggerRate = 0.5
    end

    local bTrigger = math.random() < fTriggerRate
    local nScatterCount = LuaHelper.GetIndexByRate(tableTriggerScatterCountRate)
    return bTrigger, nScatterCount
end

function OceanConfig:orTriggerBonusGame()
    local fTriggerRate = 0.0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.005
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.01
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.02
    end

    if self.m_bBonusGameTest then
        fTriggerRate = 0.5
    end
    
    local bTrigger = math.random() < fTriggerRate
    return bTrigger
end

function OceanConfig:GetJackPotIndex()
    local tableJackPotIndexRate = {100, 50, 20, 1}
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableJackPotIndexRate = {100, 50, 20, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableJackPotIndexRate = {100, 50, 20, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableJackPotIndexRate = {100, 50, 20, 1}
    end

    local nIndex = LuaHelper.GetIndexByRate(tableJackPotIndexRate)
    return nIndex
end

function OceanConfig:orTriggerWildX2()
    local fTriggerRate = 0.0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.2
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.4
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.6
    end
        
    local nWildSymbolId = -1
    local tableSymbolIdRate = {2, 1}
    local nIndex = LuaHelper.GetIndexByRate(tableSymbolIdRate)
    if nIndex == 1 then
        nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Wildx2")
    elseif nIndex == 2 then
        nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_Wildx3")
    end

    local bTrigger = math.random() < fTriggerRate
    return bTrigger, nWildSymbolId
end

------------------- 测试 -------------------------
function OceanConfig:InitTestData()
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

    if self.m_nThemeTestType == 2 then
        self.m_bBonusGameTest = true
    end 
end    

OceanConfig:InitTestData()