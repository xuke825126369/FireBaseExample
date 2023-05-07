TroyConfig = {}

function TroyConfig:GetFreeSpinCount(nScatterCount)
    if nScatterCount == 3 then
        return 7
    elseif nScatterCount == 4 then
        return 15
    elseif nScatterCount == 5 then
        return 25
    end
end

function TroyConfig:orTriggerFreeSpin()   
    local fTriggerRate = 0.0
    local tableTriggerScatterCountRate = {0, 0, 1, 1, 1}
    
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

------------------- 测试 -------------------------
function TroyConfig:InitTestData()
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

TroyConfig:InitTestData()