ArabConfig = {}
ArabConfig.TABLE_JACKPOT_ADDCOEF = {0.001, 0.002, 0.003}
ArabConfig.TABLE_JACKPOT_MIN_MULTUILE = {100, 200, 500}

ArabConfig.N_MAX_COLLECT_GEM_COUNT = 800
ArabConfig.TABLE_GEM_MONEY_MULTUILE = {0.2, 0.4, 0.6, 0.8, 1.0}

function ArabConfig:orTriggerGemMoney()
    local fTriggerRate = 0.5
    local tableMultuileRate = {1, 1, 1, 1, 1}
    
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.1
        tableMultuileRate = {5, 4, 3, 2, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.35
        tableMultuileRate = {5, 4, 3, 2, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.5
        tableMultuileRate = {5, 4, 3, 2, 1}
    end
    
    local bTrigger = math.random() < fTriggerRate
    local nIndex = LuaHelper.GetIndexByRate(tableMultuileRate)
    local nMultuile = self.TABLE_GEM_MONEY_MULTUILE[nIndex]
    return bTrigger, nMultuile
end

function ArabConfig:GetTriggerGemType()
    local tableTypeRate = {1, 1, 1}
    local nGemType = LuaHelper.GetIndexByRate(tableTypeRate)
    return nGemType
end

function ArabConfig:GetBonusGameTriggerGemType()
    local tableTypeRate = {1, 1, 1}
    local nGemType = LuaHelper.GetIndexByRate(tableTypeRate)
    return nGemType
end

function ArabConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.0
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
    return bTrigger
end

------------------- 测试 -------------------------
function ArabConfig:InitTestData()
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
    elseif self.m_nThemeTestType == 2 then
        self.m_bBonusGameTest = true
    end 

    if self.m_bBonusGameTest then
        self.N_MAX_COLLECT_GEM_COUNT = 20
    end

end    

ArabConfig:InitTestData()