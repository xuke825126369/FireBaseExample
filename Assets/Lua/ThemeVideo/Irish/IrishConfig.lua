IrishConfig = {}

IrishConfig.N_ANY_BAR_MULTUILE = 2
IrishConfig.N_ANY_7_MULTUILE = 5

IrishConfig.N_LEAF_1_MULTUILE = 5
IrishConfig.N_LEAF_2_MULTUILE = 15

IrishConfig.TABLE_JACKPOT_MIN_MULTUILE = {2, 5, 10, 25, 100, 2000} -- 最小倍数
IrishConfig.TABLE_JACKPOT_ADDCOEF = {0.001, 0.002, 0.003, 0.004, 0.005, 0.006} -- 增长系数

function IrishConfig:orRow0TriggerNullSymbol()
    local rt = SlotsGameLua.m_GameResult
    if IrishFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local fTriggerRate = 0.0
    if ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate =  0.7
    elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate =  0.8
    elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate =  0.9
    else
        Debug.Assert(false)
    end

    return math.random() < fTriggerRate
end

function IrishConfig:orTriggerJackPotSymbol()
    local tableTriggerCount = {20, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    if ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerCount = {50000, 500, 500, 500, 100, 80, 50, 30, 10, 1}
    elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerCount = {5000, 500, 500, 500, 100, 80, 50, 30, 10, 1}
    elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerCount = {5000, 500, 500, 500, 100, 80, 50, 30, 10, 1}
    else
        Debug.Assert(false)
    end
    
    local nTriggerCount = LuaHelper.GetIndexByRate(tableTriggerCount) - 1
    return nTriggerCount > 0, nTriggerCount
end

------------------- 测试 -------------------------
function IrishConfig:InitTestData()
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

IrishConfig:InitTestData()