AnimalConfig = {}

function AnimalConfig:GetFreeSpinCount(nScatterCount)
    return (nScatterCount - 4) * 5
end

function AnimalConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.0
    local tableCountRate = {
        0, 0, 0, 0, 0,
        4096, 2046, 1024, 512, 256,
        128, 64, 32, 16, 8,
        4, 2, 1,
    }

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
    local nScatterCount = LuaHelper.GetIndexByRate(tableCountRate)
    return bTrigger, nScatterCount
end

------------------- 测试 -------------------------
function AnimalConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end
    
    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    local bit1 = self.m_nThemeTestType & (1) -- 1: FreeSpin 测试
    self.m_bFreeSpinTest = false

    if bit1 ~= 0 then
        self.m_bFreeSpinTest = true
    end
end    

AnimalConfig:InitTestData()