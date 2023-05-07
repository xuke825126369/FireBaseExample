MardiGrasConfig = {}

MardiGrasConfig.N_ANY_BAR_MULTUILE = 2
MardiGrasConfig.N_ANY_MARIDGRASWHEEL_MULTUILE = 5

MardiGrasConfig.N_LEAF_1_MULTUILE = 5
MardiGrasConfig.N_LEAF_2_MULTUILE = 15

MardiGrasConfig.TABLE_JACKPOT_MIN_MULTUILE = {2, 5, 10, 25, 100, 2000} -- 最小倍数
MardiGrasConfig.TABLE_JACKPOT_ADDCOEF = {0.001, 0.002, 0.003, 0.004, 0.005, 0.006} -- 增长系数

function MardiGrasConfig:orRow0TriggerNullSymbol()
    local rt = SlotsGameLua.m_GameResult
    if MardiGrasFunc.m_bSimulationFlag then
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

-- 触发 FreeSpin Wild Stack 的概率
function MardiGrasConfig:orTriggerWildStackSymbol(nReelId)
    local tableTriggerRowRate = {9, 9, 9, 9, 9, 9}
    local tableTriggerReelRate = {0, 0, 0, 0, 0} -- 5列 分别的触发概率

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.12, 0.12, 0.12, 0.12, 0.12}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.3, 0.3, 0.3, 0.3, 0.3}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.45, 0.45, 0.45, 0.45, 0.45}
    end
    
    local bTrigger =  math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

function MardiGrasConfig:orTriggerWheel()
    local fTriggerRate = 0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.005
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.01
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.02
    end
    
    if self.m_bFreeSpinTest then
        fTriggerRate = 0.8
    end
    
    local bTrigger = math.random() < fTriggerRate
    return bTrigger
end

------------------- 测试 -------------------------
function MardiGrasConfig:InitTestData()
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

MardiGrasConfig:InitTestData()